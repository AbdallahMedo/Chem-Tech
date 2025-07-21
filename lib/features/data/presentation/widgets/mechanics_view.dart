import 'package:chem_tech_gravity_app/features/data/presentation/widgets/pdf_view.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/assets.dart';
import '../widgets/experiment_list.dart';

class MechanicsView extends StatelessWidget {
  const MechanicsView({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: AppBar(
        title: Text('Physics', ),
        backgroundColor: Colors.white,


      ),
      body: ListView(
        children: [
          experimentListItem(
            title: 'Mechanics',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PdfView(pdfAssetPath: 'assets/Free fall .pdf'),
                ),
              );
            },
            icon: Icons.folder,
          ),

          // Add more items here
        ],
      ),
    );
  }
}
