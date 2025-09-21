import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';

class PatientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
      ),
      body: FutureBuilder(
        future: Provider.of<PatientProvider>(context, listen: false).fetchPatients(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text('An error occurred!'));
          } else {
            return Consumer<PatientProvider>(
              builder: (ctx, patientProvider, child) => ListView.builder(
                itemCount: patientProvider.patients.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(patientProvider.patients[i].name),
                  subtitle: Text(patientProvider.patients[i].email),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
