import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  Future<void> fetchAppointments() async {
    final response = await http.get(Uri.parse('https://api.example.com/appointments'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _appointments = data.map((item) => Appointment.fromJson(item)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load appointments');
    }
  }
}
