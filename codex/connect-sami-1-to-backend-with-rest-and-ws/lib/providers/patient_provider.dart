import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/patient.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];

  List<Patient> get patients => _patients;

  Future<void> fetchPatients() async {
    final response = await http.get(Uri.parse('https://api.example.com/patients'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _patients = data.map((item) => Patient.fromJson(item)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load patients');
    }
  }
}
