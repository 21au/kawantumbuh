import pandas as pd
import numpy as np
import logging
from datetime import datetime
from prophet import Prophet
from supabase import create_client, Client
from pygrowup import Calculator
import warnings

warnings.filterwarnings('ignore')
logging.getLogger('cmdstanpy').setLevel(logging.WARNING)

# =====================================================================
# 1. KONFIGURASI SUPABASE & WHO Z-SCORE
# =====================================================================
# TODO: Masukkan URL dan KEY Supabase milik Bunda di sini
SUPABASE_URL = "https://xejvpubnotnpevkbpwoh.supabase.co"
SUPABASE_KEY = "sb_publishable_zPfByaKLPEKN7h-oJSRgtQ_jvHdwaJN"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Inisialisasi Kalkulator Z-Score WHO (pygrowup)
cg = Calculator(adjust_height_data=False, adjust_weight_scores=False)

# =====================================================================
# 2. FUNGSI KLASIFIKASI STATUS GIZI (Berdasarkan Permenkes No.2 / 2020)
# =====================================================================
def klasifikasi_status_gizi(z_score, indikator):
    if z_score is None: return "Tidak Diketahui"
    
    if indikator == 'BB/U': # Berat Badan menurut Umur
        if z_score < -3: return "Gizi Buruk (Severely Underweight)"
        elif -3 <= z_score < -2: return "Gizi Kurang (Underweight)"
        elif -2 <= z_score <= 1: return "Berat Badan Normal"
        elif z_score > 1: return "Risiko Berat Badan Lebih"
        
    elif indikator == 'TB/U': # Tinggi Badan menurut Umur
        if z_score < -3: return "Sangat Pendek (Severely Stunted)"
        elif -3 <= z_score < -2: return "Pendek (Stunted)"
        elif -2 <= z_score <= 3: return "Normal"
        elif z_score > 3: return "Tinggi"
        
    elif indikator == 'LK/U': # Lingkar Kepala (Standar WHO)
        if z_score < -2: return "Mikrosefali"
        elif -2 <= z_score <= 2: return "Normal"
        elif z_score > 2: return "Makrosefali"
        
    return "Tidak Diketahui"

# =====================================================================
# 3. AMBIL DATA DARI SUPABASE
# =====================================================================
print("Menarik data dari Supabase...")
# Ambil data profil anak (untuk tahu jenis kelamin dan tanggal lahir)
response_anak = supabase.table('anak').select("*").execute()
df_anak = pd.DataFrame(response_anak.data)

# Ambil data riwayat pertumbuhan
response_pertumbuhan = supabase.table('pertumbuhan').select("*").execute()
df_pertumbuhan = pd.DataFrame(response_pertumbuhan.data)

if df_anak.empty or df_pertumbuhan.empty:
    print("Data anak atau pertumbuhan kosong di Supabase. Proses dihentikan.")
    exit()

# Gabungkan data pertumbuhan dengan profil anak berdasarkan anak_id
df = pd.merge(df_pertumbuhan, df_anak, left_on='anak_id', right_on='id', suffixes=('_ukur', '_anak'))
df['tanggal_pengukuran'] = pd.to_datetime(df['tanggal_pengukuran'])
df['tanggal_lahir'] = pd.to_datetime(df['tanggal_lahir'])

# Hitung umur saat pengukuran (dalam bulan, format desimal untuk pygrowup)
df['umur_bulan'] = (df['tanggal_pengukuran'] - df['tanggal_lahir']).dt.days / 30.4375

# Sesuaikan format Gender untuk pygrowup ('M' untuk laki-laki, 'F' untuk perempuan)
# Asumsi di database Bunda: 'L' = Laki-laki, 'P' = Perempuan
df['gender'] = df['jenis_kelamin'].map({'L': 'M', 'P': 'F', 'Laki-laki': 'M', 'Perempuan': 'F'})

# =====================================================================
# 4. LOOP PREDIKSI DENGAN PROPHET & PUSH KE SUPABASE
# =====================================================================
daftar_anak_id = df['anak_id'].unique()
indikator_map = {'berat_badan': 'wefa', 'tinggi_badan': 'lefa'} # wefa=Weight for Age, lefa=Length for Age

print("\n🚀 Memulai Analisis dan Prediksi...")
hasil_prediksi_untuk_db = []

for anak_id in daftar_anak_id:
    df_spesifik = df[df['anak_id'] == anak_id].copy().sort_values('tanggal_pengukuran')
    nama_anak = df_spesifik['nama'].iloc[0]
    gender = df_spesifik['gender'].iloc[0]
    
    # Kita butuh minimal 3 data untuk Prophet bisa bekerja logis
    if len(df_spesifik) < 3:
        print(f"Data {nama_anak} kurang dari 3 pengukuran. Skip prediksi.")
        continue

    print(f"\nMemproses anak: {nama_anak}...")
    
    for metrik_db, metrik_who in indikator_map.items():
        if metrik_db not in df_spesifik.columns or df_spesifik[metrik_db].isnull().all():
            continue
            
        # Siapkan data untuk Prophet
        df_prophet = df_spesifik[['tanggal_pengukuran', metrik_db]].rename(
            columns={'tanggal_pengukuran': 'ds', metrik_db: 'y'}
        ).dropna()
        
        # Training Prophet
        model = Prophet(yearly_seasonality=False, weekly_seasonality=False, daily_seasonality=False)
        model.fit(df_prophet)
        
        # Buat prediksi 1 bulan (30 hari) ke depan
        future = model.make_future_dataframe(periods=30)
        forecast = model.predict(future)
        
        # Ambil baris prediksi terakhir (30 hari dari sekarang)
        prediksi_terakhir = forecast.iloc[-1]
        tanggal_prediksi = prediksi_terakhir['ds']
        nilai_prediksi = round(prediksi_terakhir['yhat'], 2)
        
        # Hitung prediksi umur dalam bulan pada tanggal tersebut
        tgl_lahir = df_spesifik['tanggal_lahir'].iloc[0]
        prediksi_umur_bulan = (tanggal_prediksi - tgl_lahir).days / 30.4375
        
        # HITUNG Z-SCORE RIIL (STANDAR WHO) PADA NILAI PREDIKSI
        try:
            if metrik_who == 'wefa':
                z_score = cg.zscore_for_age(indicator=metrik_who, measurement=nilai_prediksi, age_in_months=prediksi_umur_bulan, sex=gender)
                kode_ind = 'BB/U'
            else: # lefa
                z_score = cg.zscore_for_age(indicator=metrik_who, measurement=nilai_prediksi, age_in_months=prediksi_umur_bulan, sex=gender)
                kode_ind = 'TB/U'
            
            status_gizi = klasifikasi_status_gizi(z_score, kode_ind)
            
        except Exception as e:
            z_score = 0.0
            status_gizi = "Tidak dapat dihitung"
            print(f"Error Z-score: {e}")

        # Simpan ke dalam list (untuk dimasukkan ke Supabase)
        hasil_prediksi_untuk_db.append({
            'anak_id': anak_id,
            'metrik': 'berat_badan' if metrik_db == 'berat_badan' else 'tinggi_badan',
            'tanggal_prediksi': tanggal_prediksi.strftime('%Y-%m-%d'),
            'nilai_prediksi': float(nilai_prediksi),
            'z_score': float(round(z_score, 2)),
            'status_gizi': status_gizi,
            'created_at': datetime.now().isoformat()
        })
        
        print(f"[{kode_ind}] Prediksi {tanggal_prediksi.strftime('%Y-%m-%d')}: {nilai_prediksi} | Z-Score: {round(z_score,2)} ({status_gizi})")

# =====================================================================
# 5. PUSH DATA KE SUPABASE (Tabel prediksi_pertumbuhan)
# =====================================================================
if hasil_prediksi_untuk_db:
    print("\nMenyimpan data prediksi ke Supabase...")
    # Hapus prediksi lama supaya tidak menumpuk (opsional, tergantung kebutuhan Bunda)
    # supabase.table('prediksi_pertumbuhan').delete().neq('id', 0).execute() 
    
    # Masukkan prediksi baru
    data, count = supabase.table('prediksi_pertumbuhan').insert(hasil_prediksi_untuk_db).execute()
    print("✅ Berhasil menyimpan prediksi ke database!")
else:
    print("Tidak ada prediksi yang dihasilkan.")