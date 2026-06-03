# 💰 MoneyApp - xValeGroup

Aplikasi pengelolaan keuangan internal (Money Management) berbasis mobile yang modern, cepat, dan responsif. Aplikasi ini dibangun menggunakan **Flutter** sebagai *framework frontend* dan **Supabase** sebagai *backend-as-a-service* untuk sinkronisasi data cloud secara real-time.

---

## ✨ Fitur Utama

- **📂 Entity Management (Folder/Kategori Utama):**
  - Membuat, mengedit, dan menghapus entitas/projek keuangan (misal: "Tugas Onsite Bali", "Kebutuhan Bulanan").
  - Menetapkan rentang tanggal pelaksanaan/durasi projek.

- **💸 Transaction Tracking (Pemasukan & Pengeluaran):**
  - Mencatat transaksi keuangan secara detail (Judul, Jumlah, Kategori, Tanggal, Catatan).
  - Memisahkan tipe transaksi: **Pemasukan** (Pemasukan) dan **Pengeluaran** (Pengeluaran).
  - Kalkulasi otomatis Saldo Akhir, Total Pemasukan, dan Total Pengeluaran per entitas projek.

- **📸 Upload & Lihat Struk:**
  - Melampirkan bukti transaksi/struk langsung dari **Kamera** atau **Galeri** perangkat Anda.
  - Fitur peninjau (*previewer*) interaktif untuk memperbesar/memperkecil struk belanja.

- **📑 Filter Interaktif:**
  - Memfilter transaksi berdasarkan rentang tanggal (Dari - Sampai).
  - Menyaring transaksi berdasarkan kategori tertentu.

- **📄 Ekspor Laporan ke PDF:**
  - Menghasilkan laporan rekap transaksi format PDF profesional.
  - Pilihan untuk **Mengunduh PDF** secara lokal atau **Membagikan PDF** langsung ke aplikasi lain (WhatsApp, Email, dll.).

- **🔔 Umpan Balik Premium (Floating Notifications):**
  - Dilengkapi notifikasi melayang (*floating SnackBar*) kustom untuk setiap aksi CRUD (sukses simpan, edit, hapus, atau validasi error).

---

## 🛠️ Tech Stack & Arsitektur

- **Frontend:** [Flutter](https://flutter.dev/) (Dart) dengan arsitektur bersih (*Clean Architecture* sederhana: Core, Data, Domain, Presentation).
- **Backend & Database:** [Supabase](https://supabase.com/) (PostgreSQL & Supabase Storage untuk struk belanja).
- **State Management:** [Provider](https://pub.dev/packages/provider) untuk manajemen state yang reaktif dan efisien.
- **Library Kunci:**
  - `supabase_flutter` untuk integrasi database.
  - `image_picker` untuk mengambil foto struk.
  - `pdf` & `printing` untuk membuat dan mencetak laporan PDF.
  - `intl` untuk format mata uang IDR (Rupiah) dan tanggal lokal.

---

## 🚀 Memulai Penggunaan

### Prasyarat
- Flutter SDK terbaru telah terpasang.
- Akun Supabase aktif.

### Langkah Instalasi

1. **Clone Repository:**
   ```bash
   git clone https://github.com/arviansetya/money_app.git
   cd money_app
   ```

2. **Dapatkan Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Supabase:**
   Buka file `lib/core/constants/api_constants.dart` dan isi URL serta Kunci Anonim Supabase Anda:
   ```dart
   class ApiConstants {
     static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
     static const String supabaseKey = 'YOUR_ANON_PUBLIC_KEY';
     // ...
   }
   ```

4. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

---

## 📸 Struktur Folder

```text
lib/
├── core/
│   ├── constants/       # Konstanta API, URL, dll.
│   └── errors/          # Penanganan error/failure
├── data/
│   ├── models/          # Model Data (JSON Mapper)
│   └── repositories/    # Implementasi repository (akses database Supabase)
├── domain/
│   └── entities/        # Entitas logika bisnis murni
├── presentation/
│   ├── pages/           # Halaman UI & State Provider
│   ├── utils/           # Helper fungsi (format uang, PDF, notifikasi kustom)
│   └── widgets/         # Komponen UI modular
└── main.dart            # Titik masuk aplikasi (App entrypoint)
```
