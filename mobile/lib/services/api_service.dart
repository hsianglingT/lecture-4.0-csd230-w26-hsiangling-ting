import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Change to your machine's IP if testing on a physical device.
// Android emulator uses 10.0.2.2 to reach the host's localhost.
const String _baseUrl = 'http://10.0.2.2:8080/api/rest';

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  bool get isLoggedIn => _token != null;

  bool get isAdmin {
    if (_token == null) return false;
    try {
      final parts = _token!.split('.');
      if (parts.length != 3) return false;
      String payload = parts[1];
      // Fix base64 padding
      while (payload.length % 4 != 0) payload += '=';
      final decoded = utf8.decode(base64Decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final roles = (map['roles'] as List?)?.map((r) => r.toString()) ?? [];
      return roles.any((r) => r.contains('ADMIN'));
    } catch (_) {
      return false;
    }
  }

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _publicHeaders,
      body: jsonEncode({'email': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _saveToken(data['token']);
    } else {
      throw Exception('Invalid username or password');
    }
  }

  Future<void> register(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _publicHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 201) {
      final body = res.body;
      throw Exception(body.isNotEmpty ? body : 'Registration failed');
    }
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getBooks() async {
    final res = await http.get(Uri.parse('$_baseUrl/books'), headers: _authHeaders);
    _checkAuth(res);
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getMagazines() async {
    final res = await http.get(Uri.parse('$_baseUrl/magazines'), headers: _authHeaders);
    _checkAuth(res);
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getAudioBooks() async {
    final res = await http.get(Uri.parse('$_baseUrl/audiobooks'), headers: _authHeaders);
    _checkAuth(res);
    return jsonDecode(res.body);
  }

  // ── Admin: Books ──────────────────────────────────────────────────────────

  Future<void> addBook(Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_baseUrl/books'),
        headers: _authHeaders, body: jsonEncode(data));
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
  }

  Future<void> updateBook(int id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$_baseUrl/books/$id'),
        headers: _authHeaders, body: jsonEncode(data));
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
  }

  Future<void> deleteBook(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/books/$id'), headers: _authHeaders);
    _checkAuth(res);
  }

  // ── Admin: Magazines ──────────────────────────────────────────────────────

  Future<void> addMagazine(Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_baseUrl/magazines'),
        headers: _authHeaders, body: jsonEncode(data));
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
  }

  Future<void> updateMagazine(int id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$_baseUrl/magazines/$id'),
        headers: _authHeaders, body: jsonEncode(data));
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
  }

  Future<void> deleteMagazine(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/magazines/$id'), headers: _authHeaders);
    _checkAuth(res);
  }

  // ── Admin: AudioBooks ─────────────────────────────────────────────────────

  Future<void> addAudioBook(Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_baseUrl/audiobooks'),
        headers: _authHeaders, body: jsonEncode(data));
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
  }

  Future<void> updateAudioBook(int id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$_baseUrl/audiobooks/$id'),
        headers: _authHeaders, body: jsonEncode(data));
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
  }

  Future<void> deleteAudioBook(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/audiobooks/$id'), headers: _authHeaders);
    _checkAuth(res);
  }

  // ── Cart ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCart() async {
    final res = await http.get(Uri.parse('$_baseUrl/cart'), headers: _authHeaders);
    _checkAuth(res);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> addToCart(int productId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/cart/add/$productId'),
      headers: _authHeaders,
    );
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> removeFromCart(int productId) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/cart/remove/$productId'),
      headers: _authHeaders,
    );
    _checkAuth(res);
    return jsonDecode(res.body);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkout() async {
    final res = await http.post(
      Uri.parse('$_baseUrl/orders/checkout'),
      headers: _authHeaders,
    );
    _checkAuth(res);
    if (res.statusCode != 200) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getOrders() async {
    final res = await http.get(Uri.parse('$_baseUrl/orders'), headers: _authHeaders);
    _checkAuth(res);
    return jsonDecode(res.body);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _checkAuth(http.Response res) {
    if (res.statusCode == 401) throw UnauthorizedException();
  }
}

class UnauthorizedException implements Exception {}
