import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/professional_provider.dart';

class ProfessionalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professionals'),
      ),
      body: FutureBuilder(
        future: Provider.of<ProfessionalProvider>(context, listen: false).fetchProfessionals(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text('An error occurred!'));
          } else {
            return Consumer<ProfessionalProvider>(
              builder: (ctx, professionalProvider, child) => ListView.builder(
                itemCount: professionalProvider.professionals.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(professionalProvider.professionals[i].name),
                  subtitle: Text(professionalProvider.professionals[i].specialty),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
