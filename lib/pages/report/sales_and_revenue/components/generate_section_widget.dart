import 'package:flutter/material.dart';

class GenerateSectionWidget extends StatelessWidget {
  const GenerateSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(29, 0, 0, 0),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
