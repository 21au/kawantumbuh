import pandas as pd
import numpy as np
import logging
import sys
from datetime import datetime
from prophet import Prophet
from supabase import create_client, Client
from pygrowup import Calculator
import warnings

warnings.filterwarnings('ignore')
logging.getLogger('cmdstanpy').setLevel(logging.WARNING)

# =====================================================================
# 1. KONFIGURASI SUPABASE & WHO/KEMENKES Z-SCORE
# =====================================================================
SUPABASE_URL = "https://xejvpubnotnpevkbpwoh.supabase.co"
# GANTI DENGAN SERVICE ROLE KEY KAMU (bukan anon/publishable)
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlanZwdWJub3RucGV2a2Jwd29oIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjY4NzEyMiwiZXhwIjoyMDg4MjYzMTIyfQ.scoeBgoU2bTIZBcIRrZ4o3G-aOi_Uu_5YvzAe25699g" 

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# pygrowup menggunakan data LMS WHO 2006, yang secara resmi 
# diadopsi oleh Kemenkes RI dalam Permenkes No 2 Tahun 2020.
cg = Calculator(adjust_height_data=False, adjust_weight_scores=False)

# =====================================================================
# 2. FUNGSI KLASIFIKASI (STANDAR PERMENKES NO. 2 TAHUN 2020)
# =====================================================================
def klasifikasi_status_gizi(z_score, indikator):
    if z_score is None: return "Tidak Diketahui"
    
    # Standar BB/U (Berat Badan menurut Umur)
    if indikator == 'BB/U': 
        if z_score < -3.0: 
            return "Berat Badan Sangat Kurang (Gizi Buruk)"
        elif -3.0 <= z_score < -2.0: 
            return "Berat Badan Kurang (Gizi Kurang)"
        elif -2.0 <= z_score <= 1.0: 
            return "Berat Badan Normal"
        else: 
            return "Risiko Berat Badan Lebih"
        
    # Standar TB/U atau PB/U (Tinggi/Panjang Badan menurut Umur)
    elif indikator == 'TB/U': 
        if z_score < -3.0: 
            return "Sangat Pendek (Severely Stunted)"
        elif -3.0 <= z_score < -2.0: 
            return "Pendek (Stunted)"
        elif -2.0 <= z_score <= 3.0: 
            return "Normal"
        else: 
            return "Tinggi"
        
    return "Normal"

# =====================================================================
# 3. AMBIL DATA
# =====================================================================
try:
    res_anak = supabase.table('anak').select("*").execute()
    df_anak = pd.DataFrame(res_anak.data)

    res_tumbuh = supabase.table('pertumbuhan').select("*").execute()
    df_pertumbuhan = pd.DataFrame(res_tumbuh.data)
except Exception as e:
    print(f"❌ Error Supabase: {e}")
    sys.exit()

if df_anak.empty or df_pertumbuhan.empty:
    print("💡 Data masih kosong.")
    sys.exit()

# Format Tanggal
df_pertumbuhan['tanggal_pengukuran'] = pd.to_datetime(df_pertumbuhan['tanggal_pengukuran'])
df_anak['tanggal_lahir'] = pd.to_datetime(df_anak['tanggal_lahir'])

# Gabung Data
df = pd.merge(df_pertumbuhan, df_anak[['id', 'nama', 'tanggal_lahir', 'jenis_kelamin']], left_on='anak_id', right_on='id')

# Standarisasi Gender
df['gender_who'] = df['jenis_kelamin'].str.upper().map({
    'L': 'M', 'P': 'F', 'LAKI-LAKI': 'M', 'PEREMPUAN': 'F'
}).fillna('M')

# =====================================================================
# 4. PROSES ANALISIS & PREDIKSI (MINIMAL 3 DATA)
# =====================================================================
indikator_map = {'berat_badan': 'wfa', 'tinggi_badan': 'hfa'}
hasil_db = []

for anak_id in df['anak_id'].unique():
    df_s = df[df['anak_id'] == anak_id].sort_values('tanggal_pengukuran')
    nama_anak = df_s['nama'].iloc[0]
    gender = df_s['gender_who'].iloc[0]
    tgl_lahir = df_s['tanggal_lahir'].iloc[0]

    print(f"\nAnalisis: {nama_anak} (Jumlah Data: {len(df_s)})")

    # SYARAT UTAMA: Minimal 3 Data
    if len(df_s) < 3:
        print(f"⚠️ Skip! {nama_anak} baru punya {len(df_s)} data. Sistem butuh minimal 3 data untuk dihitung sesuai Buku KIA.")
        continue

    for m_db, m_who in indikator_map.items():
        if m_db not in df_s.columns or df_s[m_db].isnull().all(): continue

        # Karena sudah pasti >= 3 data, langsung jalankan Prophet
        try:
            df_p = df_s[['tanggal_pengukuran', m_db]].rename(columns={'tanggal_pengukuran':'ds', m_db:'y'})
            model = Prophet(yearly_seasonality=False, weekly_seasonality=False, daily_seasonality=False)
            model.fit(df_p)
            future = model.make_future_dataframe(periods=30)
            forecast = model.predict(future)
            
            val_pred = round(forecast.iloc[-1]['yhat'], 2)
            tgl_pred = forecast.iloc[-1]['ds']
        except Exception as e:
            print(f"   [!] Prophet gagal: {e}. Menggunakan data terakhir.")
            val_pred = df_s[m_db].iloc[-1]
            tgl_pred = df_s['tanggal_pengukuran'].iloc[-1]

        # Hitung Umur & Z-Score
       # Hitung Umur & Z-Score
        umur_bln = (tgl_pred - tgl_lahir).days / 30.4375
        
        try:
            # --- PERBAIKAN: Panggil fungsi asli pygrowup (wfa dan lhfa) ---
            if m_who == 'wfa':
                z = cg.wfa(measurement=float(val_pred), age_in_months=float(umur_bln), sex=gender)
            elif m_who == 'hfa':
                z = cg.lhfa(measurement=float(val_pred), age_in_months=float(umur_bln), sex=gender)
            else:
                z = 0.0
            # -------------------------------------------------------------

            if z is not None:
                lbl = 'BB/U' if m_who == 'wfa' else 'TB/U'
                status = klasifikasi_status_gizi(z, lbl)
            else:
                z, status = 0.0, "Luar Jangkauan Umur (> 5 Tahun)"
                
        except Exception as e:
            z, status = 0.0, "Gagal Hitung"
            print(f"   [!] DETAIL ERROR: {e}")

        hasil_db.append({
            'anak_id': int(anak_id),
            'metrik': m_db,
            'tanggal_prediksi': tgl_pred.strftime('%Y-%m-%d'),
            'nilai_prediksi': float(val_pred),
            'z_score': float(round(z, 2)) if z else 0.0,
            'status_gizi': status,
            'created_at': datetime.now().isoformat()
        })
        print(f" > {m_db}: {status} (Z-Score: {round(z,2) if z else 0})")

# =====================================================================
# 5. PUSH KE SUPABASE
# =====================================================================
if hasil_db:
    try:
        supabase.table('prediksi_pertumbuhan').insert(hasil_db).execute()
        print("\n✅ Berhasil Update Database Kemenkes/Buku KIA!")
    except Exception as e:
        print(f"\n❌ Gagal menyimpan ke database: {e}")
else:
    print("\n💡 Tidak ada data baru yang diproses (Semua anak datanya masih di bawah 3).")