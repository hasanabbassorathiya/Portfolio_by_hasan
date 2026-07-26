import 'package:flutter/material.dart';

class AppSocialLinks {
  AppSocialLinks._();

  static const String linkedIn = 'https://linkedin.com/in/hasanabbassorathiya';
  static const String email = 'mailto:hasanabbassorathiya12@gmail.com';
  static const String buyMeACoffee = 'https://buymeacoffee.com/hasanabbassorathiya';
  static const String resume = 'https://flowcv.com/resume/pmesjl0q9sm9';

  static const List<Map<String, dynamic>> items = [
    {'icon': Icons.link, 'url': linkedIn, 'tooltip': 'LinkedIn'},
    {'icon': Icons.email_outlined, 'url': email, 'tooltip': 'Email'},
  ];
}
