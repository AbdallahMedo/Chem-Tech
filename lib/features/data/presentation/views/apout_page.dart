import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/spacing.dart';
import '../widgets/social_row.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('About'),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.asset(AssetsData.logo1),
              const Text(
                'About Chem-Tech',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Space.h16,
              Card(
                color: kSecondaryColor,
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'ChemTech is Egypt’s leading company in manufacturing scientific and laboratory equipment'
                      ' as well as providing specialized maintenance services for lab devices. We excel in delivering'
                      ' comprehensive solutions tailored to the needs of educational, industrial, and research sectors,'
                      ' with a strong focus on quality and innovation. Backed by a team of experts, we ensure the long-term'
                      ' efficiency and performance of your equipment through our maintenance services. Our mission is to'
                      ' promote local manufacturing while meeting international standards and reducing reliance on imports',
                    style: TextStyle(
                      fontSize: 18,
                     // height: 1.5,
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Space.h30,
              const Text(
                'Contacts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Space.h20,
              SocialRow(),

            ],
          ),
        ),
      ),
    );
  }
}
