import 'package:flutter/material.dart';

class VerticalStroke extends StatelessWidget {
  final double value;
  final String day;
  final double height;
  const VerticalStroke({
    super.key,
    required this.value,
    required this.day,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            // spacing: 28,
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(2),
                child: Text(
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  value.toString().split('.')[0],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 25.0,
                ),
                child: Container(
                  height: (value / height) * 100,
                  width: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.secondary,
                  ),
                ),
              ),
              Text(day),
            ],
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
