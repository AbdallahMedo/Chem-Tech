import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chem_tech_gravity_app/core/utils/assets.dart';

class SocialRow extends StatefulWidget {
  SocialRow({Key? key}) : super(key: key);

  @override
  State<SocialRow> createState() => _SocialRowState();
}

class _SocialRowState extends State<SocialRow> {
  final Map<String, String> socialLinks = {
    AssetsData.facebook: 'https://www.facebook.com/share/1C8JYT8v7r',
    AssetsData.watsapp: 'https://wa.me/201200786950',
    AssetsData.prowser: 'https://chemtech-eg.com/',
    AssetsData.linkedin: 'https://www.linkedin.com/company/chem-tech',
    AssetsData.youtube: 'https://www.youtube.com/@chemtech8780',
  };

  Future<void> _launchLink(BuildContext context, String url) async  {
    try {
      final uri = Uri.parse(url);
      debugPrint('Attempting to launch: $uri');

      if (!await canLaunchUrl(uri)) {
        _showError(context, 'Cannot launch this URL: $url');
        return;
      }

      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success) {
        _showError(context, 'Failed to open: $url');
      }
    } catch (e) {
      debugPrint('Exception while launching URL: $e');
      _showError(context, 'Error: $e');
    }
  }
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: socialLinks.entries.map((entry) {
        return GestureDetector(
          onTap: () => _launchLink(context, entry.value),
          child: Image.asset(
            entry.key,
            width: 40,
            height: 40,
          ),
        );
      }).toList(),
    );
  }
}
