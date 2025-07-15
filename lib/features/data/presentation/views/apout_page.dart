import 'package:flutter/material.dart';
import '../../../../core/utils/assets.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('About', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Space.h50,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Space.h50,
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(AssetsData.logo), // Replace with your logo
                ),
                Space.h16,
                const Text(
                  "Chem-Tech",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Chem-Tech',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  Space.h16,
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'ChemTech is Egypt’s leading company in manufacturing scientific and laboratory equipment, as well as providing specialized maintenance services for lab devices. We excel in delivering comprehensive solutions tailored to the needs of educational, industrial, and research sectors, with a strong focus on quality and innovation.\n\nBacked by a team of experts, we ensure the long-term efficiency and performance of your equipment through our maintenance services. Our mission is to promote local manufacturing while meeting international standards and reducing reliance on imports.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Space.h30,
                  Row(
                    children: const [
                      Icon(Icons.contact_mail_rounded, color: kPrimaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Contacts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 2,
                    height: 30,
                    color: kSecondaryColor,
                    endIndent: 200,
                  ),
                  Space.h20,
                   SocialRow(),
                  Space.h20,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
