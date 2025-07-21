import 'package:chem_tech_gravity_app/features/data/presentation/views/data_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../views/apout_page.dart';
import '../views/experiments_page.dart';

class BottomNavigationBarView extends StatefulWidget {
  final BluetoothDevice device;

  const BottomNavigationBarView(this.device,{super.key});

  @override
  State<BottomNavigationBarView> createState() => _BottomNavigationBarViewState();
}

class _BottomNavigationBarViewState extends State<BottomNavigationBarView> {


  int currentIndex=0;
  late final List<Widget> _pages;
@override
  void initState() {

    super.initState();
    _pages = [
      DataPage(device: widget.device),
      ExperimentsPage(),
      AboutPage(),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Measure'),
          BottomNavigationBarItem(icon: Icon(Icons.science_rounded), label: 'Experiments'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
        ],
        currentIndex: currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

}
