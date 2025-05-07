import 'package:chem_tech_gravity_app/core/utils/constants.dart';
import 'package:flutter/material.dart';

Widget experimentListItem({
  required String title,
  required VoidCallback onTap,
  required IconData icon,
}) {
  return Card(
    color: kSecondaryColor,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      leading:Icon(icon,color: kPrimaryColor,),
      title: Text(title,style: TextStyle(color: Colors.white),),
      onTap: onTap,
    ),
  );
}
