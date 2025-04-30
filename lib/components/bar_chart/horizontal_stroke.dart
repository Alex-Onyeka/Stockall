import 'package:flutter/material.dart';

class HorizontalStroke extends StatelessWidget {
  final double value;
  const HorizontalStroke({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    String setValue(double value) {
      var roundOff = (value / 100).round() * 100;
      String newValue = roundOff.toString();
      if (newValue.length < 4) {
        return newValue;
      } else if (newValue.length > 3 &&
          newValue.length < 7) {
        return '${newValue.substring(0, newValue.length - 3)}k';
      } else {
        return '${newValue.substring(0, newValue.length - 6)}m';
      }
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: SizedBox()),
          Row(
            spacing: 15,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  setValue(value),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 18,
                child: Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color.fromARGB(
                          67,
                          158,
                          158,
                          158,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
