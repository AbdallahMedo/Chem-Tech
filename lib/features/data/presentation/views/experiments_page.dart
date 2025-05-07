import 'package:flutter/material.dart';

import '../widgets/experiment_list.dart';
import '../widgets/mechanics_view.dart';

class ExperimentsPage extends StatelessWidget {
  const ExperimentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: AppBar(
        title: Text('Experiments'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,

      ),
      body: ListView(
        children: [
          experimentListItem(
            title: 'Physics',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MechanicsView()),
              );
            },
            icon: Icons.science_rounded,
          ),

          // Add more items here
        ],
      ),
    );
  }
}
