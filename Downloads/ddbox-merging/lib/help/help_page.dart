import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Form(child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Help & Support Page"),
          ],
        ),
      ))),
    );
  }
}
