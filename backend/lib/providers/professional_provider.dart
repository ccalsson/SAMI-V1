import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/professional.dart';

class ProfessionalProvider with ChangeNotifier {
  List<Professional> _professionals = [];

  List<Professional> get professionals => _professionals;

  Future<void> fetchProfessionals() async {
    final response = await http.get(Uri.parse('https://api.example.com/professionals'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _professionals = data.map((item) => Professional.fromJson(item)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load professionals');
    }
  }
}
