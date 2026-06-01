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
Jika opsi `isAutoWithdraw = true` diaktifkan, SDK akan memicu penarikan dana VA bank otomatis secara *real-time* menjadi saldo utama aplikasi (Zakki Store) ketika fungsi `zakki.checkbank()` dipanggil.

### 💡 Dual-Flow Pascabayar & Bebas Nominal
*   **Pascabayar (PLN/BPJS/PDAM):** Inquiry tagihan terlebih dahulu, lalu bayar dengan format tujuan `[ID_Pelanggan].[Nominal_Tagihan]` (Contoh: `122345678901.150000`).
*   **E-Wallet Bebas Nominal:** Kirim transfer E-Wallet nominal kustom dengan format tujuan `[No_HP].[Nominal]` (Contoh: `08123456789.25000`).

---

## 📑 Daftar Referensi Metode Lengkap

SDK Flutter/Dart ini mendukung secara penuh seluruh **25 fungsi resmi** dengan nama dan perilaku yang konsisten dengan SDK versi Node.js (NPM), Python (PyPI), PHP (Composer), Go, dan C#:

### 1. Payment Gateway (QRIS Top Up)
*   `zakki.topup(int nominal)` — Membuat QRIS dinamis instan dengan nominal kode unik.
*   `zakki.cektopup(String idtopup)` — Cek status pembayaran QRIS.
*   `zakki.cancel(String? idTransaksi, {bool allPending})` — Batalkan transaksi pending.

### 2. Transaksi H2H
*   `zakki.listkode({String? jenis, String? productType})` — Katalog kode produk aktif.
*   `zakki.h2h(H2HParams params)` — Mengirim order transaksi H2H.
*   `zakki.h2hSimple(String kode, String tujuan, String refID)` — Versi sederhana posisional untuk memicu order H2H.
*   `zakki.cekh2h(String idTrx)` — Cek detail status pengisian, SN, dan harga beli.
*   `zakki.myh2h()` — Mengambil 20 riwayat pembelian H2H terupdate.

### 3. Perbankan & Transfer VA
*   `zakki.checkbank()` — Cek saldo, VA member, mutasi, dan pemicu Auto-Withdraw.
*   `zakki.checkname(String number)` — Verifikasi nama asli pemilik VA Bank.
*   `zakki.transfer(TransferParams params)` — Transfer saldo antar Virtual Account.
*   `zakki.transferSimple(String to, int amount)` — Versi sederhana posisional untuk transfer saldo.
*   `zakki.tabung(int jumlah)` — Menabung saldo ke Bank (butuh PIN).
*   `zakki.tarik(int jumlah)` — Menarik dana tabungan ke saldo aplikasi (butuh PIN).
*   `zakki.checkmutasi({String mutasiType})` — Riwayat mutasi Tarik/Tabung.

### 4. Noktel Marketplace (OTP Virtual)
*   `zakki.noktelStok()` — Cek stok nomor virtual yang ready.
*   `zakki.noktelBuy(String category)` — Membeli nomor virtual baru untuk OTP.
*   `zakki.noktelGetOtp(String accountID)` — Menarik kode OTP Telegram secara real-time.
*   `zakki.noktelCancel(String invoiceID)` — Membatalkan nomor yang pending OTP & auto-refund.
*   `zakki.noktelHistory()` — Mengambil daftar riwayat pembelian Noktel.

### 5. Reward Komputasi & Game
*   `zakki.cekmining()` — Cek status kesulitan global, block reward, dan miner aktif.
*   `zakki.mymining()` — Riwayat koin mining SHA256 milik akun Anda.
*   `zakki.cekgacha()` — Statistik poin, kemenangan, dan keuntungan gacha member.

### 6. Keamanan & Utilitas
*   `zakki.whitelistip(String ip)` — Whitelist IP server Anda untuk otorisasi API H2H.
*   `zakki.delwhitelistip(String ip)` — Hapus IP server dari whitelist.
*   `zakki.leaderboard(int limit, {String period})` — Mengambil peringkat sultan topup teraktif.
*   `zakki.status()` — Informasi beban CPU, metrik finansial, dan kesehatan sistem.

---

## 🛡️ Protokol Keamanan API

> [!WARNING]
> **Selalu jalankan SDK ini di sisi backend (Server-side)!**
> Jangan pernah mengekspos API Token dan PIN Anda di sisi frontend / client-side publik demi mencegah potensi pencurian saldo.
