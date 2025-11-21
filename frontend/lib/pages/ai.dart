import 'package:flutter/material.dart';
import '../constants.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('My AI'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.darkCharcoal,
        elevation: 0,
      ),
    );
  }
}
