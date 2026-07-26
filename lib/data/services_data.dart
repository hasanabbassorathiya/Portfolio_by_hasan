import 'package:flutter/material.dart';

class AppServicesData {
  AppServicesData._();

  static const List<Map<String, dynamic>> services = [
    {
      'title': 'Mobile App Development',
      'description': 'Cross-platform mobile applications with Flutter — from concept to App Store deployment.',
      'icon': Icons.phone_android,
    },
    {
      'title': 'Web Application Development',
      'description': 'Modern, responsive web applications with Flutter Web and full-stack capabilities.',
      'icon': Icons.language,
    },
    {
      'title': 'AI & Agentic App Development',
      'description': 'AI-powered applications with LLM integration, intelligent automation, and agentic workflows.',
      'icon': Icons.psychology,
    },
    {
      'title': 'FinTech Solutions',
      'description': 'Secure financial applications — payment workflows, lending platforms, and transaction systems.',
      'icon': Icons.account_balance,
    },
    {
      'title': 'Custom Solutions',
      'description': 'Enterprise-grade custom software — APIs, cloud architecture, and scalable systems.',
      'icon': Icons.build,
    },
    {
      'title': 'Consulting & Architecture',
      'description': 'Technical leadership, Clean Architecture adoption, team mentoring, and code review.',
      'icon': Icons.architecture,
    },
  ];
}
