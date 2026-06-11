# 📱 Zakkistore SDK for Flutter / Dart

**Official B2B Client Library for Zakki Store API Gateway**

Pustaka Flutter & Dart resmi untuk memudahkan integrasi layanan Host-to-Host (H2H) prabayar/pascabayar, payment gateway QRIS otomatis, perbankan Virtual Account (VA), Noktel OTP virtual, mining reward, dan gacha koin Zakki Store ke dalam proyek Flutter Anda (Android, iOS, Web, macOS, Windows, Linux).

---

## 🚀 Instalasi & Inisialisasi

Instal pustaka via `pub.dev` ke dalam proyek Flutter Anda:

```bash
flutter pub add zakkistore_sdk
```

Atau tambahkan secara manual ke berkas `pubspec.yaml` proyek Anda:

```yaml
dependencies:
  zakkistore_sdk: ^1.0.1
```

### Inisialisasi Klien

#### Mode 1: Inisialisasi Instan (Official Gateway by Default)
Sangat praktis! SDK otomatis mengarah ke gateway server resmi (`https://qris.zakki.store`).

```dart
import 'package:zakkistore_sdk/zakkistore_sdk.dart';

void main() async {
  // Klien otomatis mengarah ke server resmi!
  final zakki = ZakkiStore("API_TOKEN_MEMBER_ANDA");

  // Contoh: Melakukan Health Check Server
  try {
    final status = await zakki.status();
    print("Status Server: ${status['status']}");
  } catch (e) {
    print("Error: $e");
  }
}
```

#### Mode 2: Inisialisasi dengan Konfigurasi Kustom
Gunakan opsi ini jika Anda ingin melakukan kustomisasi base URL (migrasi domain) atau mengaktifkan fitur penarikan otomatis (Auto-Withdraw).

```dart
final zakki = ZakkiStore(
  "API_TOKEN_MEMBER_ANDA",
  baseUrl: "https://qris.zakki.store", // Domain custom/resmi
  iduser: "IBO99",
  email: "member@gmail.com",
  pin: "123456",                       // Wajib untuk tabung & tarik
  isAutoWithdraw: true,                // Aktifkan auto-withdrawal saldo bank!
);
```

---

## 🛠️ Fitur Unggulan

### 🔄 Auto-Withdraw Saldo VA
Jika opsi `isAutoWithdraw = true` diaktifkan, SDK akan memicu penarikan dana VA bank otomatis secara *real-time* menjadi saldo utama aplikasi zakki store ketika fungsi `zakki.checkbank()` dipanggil.

### 💡 Dual-Flow Pascabayar & Bebas Nominal
*   **Pascabayar (PLN/BPJS/PDAM):** Inquiry tagihan terlebih dahulu, lalu bayar dengan format tujuan `[ID_Pelanggan].[Nominal_Tagihan]` (Contoh: `122345678901.150000`).
*   **E-Wallet Bebas Nominal:** Kirim transfer E-Wallet nominal kustom dengan format tujuan `[No_HP].[Nominal]` (Contoh: `08123456789.25000`).

---

## 📑 Daftar Referensi Metode Lengkap & Struktur Pengelompokan (37 Fungsi Resmi)

Seluruh fungsi yang didukung oleh SDK ini dikelompokkan secara rapi ke dalam 7 kategori layanan utama demi mempermudah pemahaman dan integrasi:

### 1. ⚡ Layanan Payment Gateway (QRIS Topup) — [5 Fungsi]
*   **`await zakki.topup(nominal)`** — Membuat tiket pembayaran QRIS dinamis instan dengan nominal kode unik.
*   **`await zakki.cektopup(idtopup)`** — Mengecek status pembayaran tiket QRIS tertentu secara real-time.
*   **`zakki.cektopup2(idtopup)`** — Mendapatkan URL gambar struk digital dinamis (hologram receipt) berformat PNG.
*   **`await zakki.mytopup()`** — Mengambil seluruh riwayat transaksi topup QRIS akun Anda.
*   **`await zakki.cancel(id_transaksi, all_pending)`** — Membatalkan satu atau seluruh tiket topup pending.

### 2. 🏪 Layanan Transaksi Host-to-Host (H2H) — [4 Fungsi]
*   **`await zakki.listkode(jenis, product_type)`** — Mengambil katalog produk prabayar/pascabayar aktif beserta daftar harga beli.
*   **`await zakki.h2h(kode, tujuan, refID)`** — Mengirimkan order transaksi H2H (pulsa, paket data, PLN kustom, dll).
*   **`await zakki.cekh2h(id_trx)`** — Mengecek status transaksi, Serial Number (SN), dan harga beli riil dari order H2H.
*   **`await zakki.myh2h()`** — Mengambil 20 riwayat transaksi H2H terupdate milik akun Anda.

### 3. 🏦 Layanan Perbankan & Transfer Saldo VA — [8 Fungsi]
*   **`await zakki.checkbank()`** — Memeriksa detail Virtual Account (VA), saldo bank VA, serta memicu Auto-Withdraw jika diaktifkan.
*   **`await zakki.checkname(number)`** — Memverifikasi nama asli pemilik rekening Virtual Account tujuan sebelum melakukan transfer.
*   **`await zakki.transfer(to, amount)`** — Mengirimkan saldo antar-VA member secara instan dan bebas biaya admin.
*   **`await zakki.tabung(jumlah)`** — Menyetorkan saldo aktif aplikasi ke rekening bank Virtual Account terhubung Anda.
*   **`await zakki.tarik(jumlah)`** — Menarik dana dari bank Virtual Account ke saldo aktif aplikasi Zakki Store Anda.
*   **`await zakki.checkmutasi(mutasi_type)`** — Melihat riwayat mutasi tabung/tarik saldo bank VA (`all`, `tarik`, `tabung`).
*   **`await zakki.checktransfer(idtransfer)`** — Mengecek status pengiriman dana transfer tertentu secara detail.
*   **`await zakki.mytransfer(type)`** — Mengambil riwayat pengiriman dan penerimaan transfer saldo (`all`, `kirim`, `terima`).

### 4. 📱 Layanan Noktel Marketplace (OTP Virtual) — [5 Fungsi]
*   **`await zakki.noktelStok()`** — Memeriksa ketersediaan stok nomor virtual aktif per kategori layanan/aplikasi.
*   **`await zakki.noktelBuy(category)`** — Membeli nomor virtual baru untuk penerimaan kode verifikasi/OTP.
*   **`await zakki.noktelGetOtp(account_id)`** — Mengambil kode verifikasi/OTP yang masuk ke nomor virtual secara real-time.
*   **`await zakki.noktelCancel(invoice_id)`** — Membatalkan order nomor virtual yang pending OTP dan memicu auto-refund saldo.
*   **`await zakki.noktelHistory()`** — Mengambil daftar riwayat lengkap pemesanan nomor virtual.

### 5. ⛏️ Layanan Reward Komputasi SHA-256 (Mining) & Game — [5 Fungsi]
*   **`await zakki.miningStart()`** — Meminta challenge penambangan SHA-256 serta target kesulitan (difficulty) dari server.
*   **`await zakki.miningSubmit(nonce, signature)`** — Mengirimkan hasil kerja hashing SHA-256 (Proof-of-Work) untuk mendapatkan koin.
*   **`await zakki.cekmining(idmining)`** — Mengecek status audit dan persetujuan dari blok mining yang telah Anda selesaikan.
*   **`await zakki.mymining()`** — Melihat riwayat penambangan koin dan total reward hashing akun Anda.
*   **`await zakki.cekgacha()`** — Mengecek jumlah tiket gacha, riwayat kemenangan, dan detail koin keberuntungan Anda.

### 6. 🔒 Layanan Keamanan IP & Utilitas — [6 Fungsi]
*   **`await zakki.whitelistip(ip)`** — Mendaftarkan IP server/host Anda agar diizinkan melakukan transaksi H2H via API (Maksimal 3 IP).
*   **`await zakki.delwhitelistip(ip)`** — Menghapus alamat IP terdaftar dari whitelist API.
*   **`await zakki.cekmyip()`** — Mendeteksi alamat IP publik host/server Anda saat ini yang terbaca oleh sistem.
*   **`await zakki.cekip(ip)`** — Mengecek detail status IP whitelisting tertentu.
*   **`await zakki.leaderboard(limit, period)`** — Melihat daftar Sultan topup teraktif secara global.
*   **`await zakki.status()`** — Memeriksa beban CPU server, statistik finansial global, dan kesehatan sistem.

### 7. 🔗 Layanan Webhook Callback & Notifikasi Bot — [4 Fungsi]
*   **`await zakki.setcallback(site)`** — Memasang URL callback real-time untuk menerima laporan status transaksi H2H.
*   **`await zakki.delcallback()`** — Menghapus URL callback yang terpasang di sistem.
*   **`await zakki.setnotifbot(telegramId)`** — Memasang ID Telegram Anda untuk menerima notifikasi otomatis transaksi sukses/gagal.
*   **`await zakki.delnotifbot()`** — Menonaktifkan bot notifikasi Telegram.


## 🛡️ Protokol Keamanan API

> [!WARNING]
> **Selalu jalankan SDK ini di sisi backend (Server-side)!**
> Jangan pernah mengekspos API Token dan PIN Anda di sisi frontend / client-side publik demi mencegah potensi pencurian saldo.
