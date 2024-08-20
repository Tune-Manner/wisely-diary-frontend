import 'package:http/http.dart' as http;
import 'dart:convert';
import 'letter_model.dart';

class LetterNotReadyException implements Exception {
  final String message;
  LetterNotReadyException(this.message);
}

class LetterService {
  final String baseUrl = 'http://10.0.2.2:8080/api';

  Future<int> createLetter(int diaryCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/letter/$diaryCode'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['letterCode'];
    } else {
      throw Exception('Failed to create letter: ${response.statusCode}');
    }
  }

  Future<Letter> getLetter(int letterCode) async {
    final response = await http.get(Uri.parse('$baseUrl/letter/$letterCode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Letter.fromJson(data);
    } else if (response.statusCode == 404) {
      throw LetterNotReadyException('Letter is not ready yet');
    } else {
      throw Exception('Failed to load letter: ${response.statusCode}');
    }
  }

  Future<bool> checkLetterStatus(int letterCode) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/letter/status/$letterCode'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isReady'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking letter status: $e');
      return false;
    }
  }
}