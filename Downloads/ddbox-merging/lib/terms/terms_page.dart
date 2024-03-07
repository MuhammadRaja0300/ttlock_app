import 'package:flutter/material.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Scaffold(
        body: SafeArea(child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Terms & Condition Page"),
            ],
          ),
        )),
      ),
    );
  }
}
