# 📋 Roadmap Proyek Akhir ASRI (Basayan Bestari)

Gunakan file ini sebagai panduan pengujian dan pengerjaan aplikasi. Kamu bisa memberi tanda `[x]` jika tugas sudah selesai.

---

## 🛠️ Fase 1: Penyelarasan (Laptop & Hosting)
*Tujuan: Memastikan pondasi sistem online sudah kokoh.*

- [ ] **Upload Backend**: Mengunggah `UserController.php`, `AduanController.php`, `User.php`, `api.php`, dan `web.php` ke hosting.
- [ ] **Update Database Online**: Mengakses `https://simpasda.one-babel.my.id/up-db` di browser hingga muncul pesan sukses.
- [ ] **Sinkronisasi IP/URL**: Memastikan `lib/config.dart` sudah mengarah ke URL hosting yang benar.
- [ ] **Tes Login**: Login Kurir & Nasabah lancar tanpa error tipe data (String vs Int).

---

## 🚛 Fase 2: Alur Utama Kurir
*Tujuan: Fungsi inti penimbangan dan setoran sampah berjalan.*

- [ ] **Scan & Konfirmasi**: Dialog konfirmasi identitas nasabah muncul setelah scan.
- [ ] **Auto-Load Request**: List sampah otomatis terisi jika nasabah memiliki request aktif.
- [ ] **Integrasi IoT**: Tombol timbangan orange berhasil menarik angka berat terbaru dari server.
- [ ] **Simpan Setoran**: Data transaksi + foto berhasil tersimpan dan muncul di Web Admin.

---

## 💰 Fase 3: Alur Keamanan Nasabah
*Tujuan: Saldo dan transaksi nasabah terlindungi.*

- [ ] **Persistent Login**: Aplikasi otomatis masuk ke dashboard saat dibuka (Tanpa Login ulang).
- [ ] **Setup PIN**: Nasabah dipandu membuat PIN 6 digit saat pertama kali tarik tunai/di profil.
- [ ] **Verifikasi PIN**: PIN wajib dimasukkan setiap kali melakukan penarikan saldo.
- [ ] **Unduh Struk**: Gambar bukti transaksi berhasil disimpan ke galeri HP nasabah.

---

## 🔒 Fase 4: Penguatan Sistem (Hardening)
*Tujuan: Menutup celah keamanan dan bug.*

- [ ] **Proteksi API**: Memastikan rute Dashboard & Riwayat berada di dalam `auth:sanctum`.
- [ ] **Validasi File**: Server menolak jika file yang diunggah bukan gambar (JPG/PNG).
- [ ] **Loading Overlay**: Layar terkunci saat proses "Simpan" agar tidak terjadi double-data.

---

## 🌟 Fase 5: Penyempurnaan (A+)
*Tujuan: Memberikan fitur tambahan untuk nilai maksimal.*

- [ ] **Layanan Aduan**: Fitur laporan masalah dari HP muncul di dashboard Admin DLH.
- [ ] **Midtrans Sandbox**: Integrasi penarikan saldo ke sistem pembayaran (Iris).
- [ ] **Peta Navigasi**: Merapikan rute jalan kurir agar lebih akurat dan informatif.

---
*Dibuat oleh Asisten AI untuk Mai - Proyek Akhir SEMESTER 6*
