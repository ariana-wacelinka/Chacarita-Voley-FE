import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EditPaymentsPage extends StatefulWidget {
  const EditPaymentsPage({super.key});

  @override
  State<EditPaymentsPage> createState() => _EditPaymentsPageState();
}

class _EditPaymentsPageState extends State<EditPaymentsPage> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(child: Column(children: [Text("data")])),
    );
  }
}
