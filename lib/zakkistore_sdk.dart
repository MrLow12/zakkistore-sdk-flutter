import 'dart:convert';
import 'package:http/http.dart' as http;

class H2HParams {
  final String kode;
  final String tujuan;
  final String refID;

  H2HParams({required this.kode, required this.tujuan, required this.refID});

  Map<String, dynamic> toJson() => {
    'kode': kode,
    'tujuan': tujuan,
    'refID': refID,
  };
}

class TransferParams {
  final String to;
  final int amount;

  TransferParams({required this.to, required this.amount});

  Map<String, dynamic> toJson() => {
    'to': to,
    'amount': amount,
  };
}

class ZakkiStore {
  final String baseUrl;
  final String token;
  final String? iduser;
  final String? email;
  final String? pin;
  bool isAutoWithdraw;

  ZakkiStore(this.token, {
    this.baseUrl = 'https://qris.zakki.store',
    this.iduser,
    this.email,
    this.pin,
    this.isAutoWithdraw = false,
  });

  void enableAutoWithdraw(bool status) {
    isAutoWithdraw = status;
  }

  Future<Map<String, dynamic>> _request(String endpoint, String method, {Map<String, dynamic>? data}) async {
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    var url = Uri.parse('$cleanBaseUrl$endpoint');

    http.Response response;
    final headers = {'Content-Type': 'application/json'};

    try {
      if (method.toUpperCase() == 'GET') {
        if (data != null) {
          final queryParams = data.map((key, value) => MapEntry(key, value.toString()));
          url = url.replace(queryParameters: queryParams);
        }
        response = await http.get(url);
      } else {
        final body = data != null ? jsonEncode(data) : null;
        response = await http.post(url, headers: headers, body: body);
      }

      final resJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        var errMsg = resJson['message'] ?? 'HTTP Error! Status: ${response.statusCode}';
        if (response.statusCode == 403 || errMsg.toString().toLowerCase().contains('ip')) {
          errMsg = '$errMsg\n⚠️ [IP BLOCKED / UNREGISTERED] IP Anda diblokir atau belum terdaftar di whitelist API. Silakan hubungi developer via WhatsApp (https://wa.me/6283844082339) or Telegram (https://t.me/zakki_store) untuk mendapatkan bantuan.';
        }
        throw Exception('[ZakkiStore SDK Error] $errMsg');
      }

      return resJson;
    } catch (e) {
      if (e.toString().contains('[ZakkiStore SDK Error]')) rethrow;
      throw Exception('[ZakkiStore SDK Error] Koneksi Gagal: $e');
    }
  }

  // ==========================================================
  // --- 1. PAYMENT GATEWAY (QRIS TOPUP) ---
  // ==========================================================

  Future<Map<String, dynamic>> topup(int nominal) async {
    return _request('/topup', 'POST', data: {
      'token': token,
      'nominal': nominal,
    });
  }

  Future<Map<String, dynamic>> cektopup(String idtopup) async {
    return _request('/cektopup', 'GET', data: {
      'idtopup': idtopup,
    });
  }

  Future<Map<String, dynamic>> cancel(String? idTransaksi, {bool allPending = false}) async {
    final data = <String, dynamic>{'token': token};
    if (idTransaksi != null) data['id_transaksi'] = idTransaksi;
    if (allPending) data['all'] = true;

    return _request('/cancel', 'POST', data: data);
  }

  // ==========================================================
  // --- 2. TRANSAKSI H2H (HOST-TO-HOST) ---
  // ==========================================================

  Future<Map<String, dynamic>> listkode({String? jenis, String? productType}) async {
    final data = <String, dynamic>{};
    if (jenis != null) data['jenis'] = jenis;
    if (productType != null) data['type'] = productType;

    return _request('/listkode', 'GET', data: data);
  }

  Future<Map<String, dynamic>> h2h(H2HParams params) async {
    return _request('/h2h', 'POST', data: {
      'token': token,
      'kode': params.kode,
      'tujuan': params.tujuan,
      'refID': params.refID,
    });
  }

  Future<Map<String, dynamic>> h2hSimple(String kode, String tujuan, String refID) async {
    return h2h(H2HParams(kode: kode, tujuan: tujuan, refID: refID));
  }

  Future<Map<String, dynamic>> cekh2h(String idTrx) async {
    return _request('/cekh2h', 'GET', data: {
      'id': idTrx,
    });
  }

  Future<Map<String, dynamic>> myh2h() async {
    return _request('/myh2h', 'GET', data: {
      'token': token,
    });
  }

  // ==========================================================
  // --- 3. PERBANKAN & TRANSFER SALDO ---
  // ==========================================================

  Future<Map<String, dynamic>> checkbank() async {
    final data = <String, dynamic>{'token': token};
    if (iduser != null) data['iduser'] = iduser;
    else if (email != null) data['email'] = email;

    var bankRes = await _request('/checkbank', 'GET', data: data);

    // Alur Auto-Withdraw VA Bank Otomatis
    if (isAutoWithdraw && bankRes['data'] != null) {
      final userData = bankRes['data'] as Map<String, dynamic>;
      if (userData['bank_detail'] != null) {
        final bankDetail = userData['bank_detail'] as Map<String, dynamic>;
        final balance = double.tryParse(bankDetail['balance']?.toString() ?? '0') ?? 0.0;

        if (balance > 0) {
          try {
            final withdrawRes = await tarik(balance.toInt());
            final updatedRes = await _request('/checkbank', 'GET', data: data);
            bankRes = updatedRes;
            bankRes['auto_withdraw_executed'] = true;
            bankRes['auto_withdraw_amount'] = balance.toInt();
            bankRes['auto_withdraw_message'] = withdrawRes['message'] ?? 'Auto-withdraw berhasil dijalankan.';
          } catch (e) {
            bankRes['auto_withdraw_executed'] = false;
            bankRes['auto_withdraw_error'] = e.toString();
          }
        }
      }
    }

    return bankRes;
  }

  Future<Map<String, dynamic>> checkname(String number) async {
    return _request('/checkname', 'GET', data: {
      'number': number.trim(),
    });
  }

  Future<Map<String, dynamic>> transfer(TransferParams params) async {
    return _request('/transfer', 'POST', data: {
      'token': token,
      'to': params.to,
      'amount': params.amount,
    });
  }

  Future<Map<String, dynamic>> transferSimple(String to, int amount) async {
    return transfer(TransferParams(to: to, amount: amount));
  }

  Future<Map<String, dynamic>> tabung(int jumlah) async {
    if (pin == null) {
      throw Exception('[ZakkiStore SDK Error] PIN transaksi diperlukan untuk melakukan transaksi tabung');
    }

    final data = <String, dynamic>{
      'token': token,
      'jumlah': jumlah,
      'pin': pin,
    };

    if (iduser != null) data['iduser'] = iduser;
    if (email != null) data['email'] = email;

    return _request('/tabung', 'POST', data: data);
  }

  Future<Map<String, dynamic>> tarik(int jumlah) async {
    if (pin == null) {
      throw Exception('[ZakkiStore SDK Error] PIN transaksi diperlukan untuk melakukan transaksi tarik');
    }

    final data = <String, dynamic>{
      'token': token,
      'jumlah': jumlah,
      'pin': pin,
    };

    if (iduser != null) data['iduser'] = iduser;
    if (email != null) data['email'] = email;

    return _request('/tarik', 'POST', data: data);
  }

  Future<Map<String, dynamic>> checkmutasi({String mutasiType = 'all'}) async {
    final data = <String, dynamic>{
      'token': token,
      'type': mutasiType,
    };

    if (iduser != null) data['iduser'] = iduser;
    if (email != null) data['email'] = email;

    return _request('/checkmutasi', 'GET', data: data);
  }

  // ==========================================================
  // --- 4. NOKTEL MARKETPLACE (OTP VIRTUAL) ---
  // ==========================================================

  Future<Map<String, dynamic>> noktelStok() async {
    return _request('/noktel/stok', 'GET', data: {
      'token': token,
    });
  }

  Future<Map<String, dynamic>> noktelBuy(String category) async {
    return _request('/noktel/buy', 'POST', data: {
      'token': token,
      'category': category.trim(),
    });
  }

  Future<Map<String, dynamic>> noktelGetOtp(String accountID) async {
    return _request('/noktel/getotp', 'GET', data: {
      'token': token,
      'account_id': accountID.trim(),
    });
  }

  Future<Map<String, dynamic>> noktelCancel(String invoiceID) async {
    return _request('/noktel/cancel', 'POST', data: {
      'token': token,
      'invoice_id': invoiceID.trim(),
    });
  }

  Future<Map<String, dynamic>> noktelHistory() async {
    return _request('/noktel/history', 'GET', data: {
      'token': token,
    });
  }

  // ==========================================================
  // --- 5. REWARD KOMPUTASI & GAME ---
  // ==========================================================

  Future<Map<String, dynamic>> cekmining() async {
    return _request('/cekmining', 'GET', data: {
      'token': token,
    });
  }

  Future<Map<String, dynamic>> mymining() async {
    return _request('/mymining', 'GET', data: {
      'token': token,
    });
  }

  Future<Map<String, dynamic>> cekgacha() async {
    return _request('/cekgacha', 'GET', data: {
      'token': token,
    });
  }

  // ==========================================================
  // --- 6. UTILITY & SECURITY ---
  // ==========================================================

  Future<Map<String, dynamic>> whitelistip(String ip) async {
    return _request('/whitelistip', 'POST', data: {
      'token': token,
      'ip': ip.trim(),
    });
  }

  Future<Map<String, dynamic>> delwhitelistip(String ip) async {
    return _request('/delwhitelistip', 'POST', data: {
      'token': token,
      'ip': ip.trim(),
    });
  }

  Future<Map<String, dynamic>> leaderboard(int limit, {String period = 'all'}) async {
    return _request('/leaderboard', 'GET', data: {
      'limit': limit,
      'period': period.trim(),
    });
  }

  Future<Map<String, dynamic>> status() async {
    return _request('/status', 'GET');
  }
}
