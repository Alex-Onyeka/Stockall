import 'package:flutter/material.dart';

class MyIndicator extends StatelessWidget {
  final int currentPage;
  final int number;
  final Function()? onTap;
  const MyIndicator({
    super.key,
    required this.onTap,
    required this.currentPage,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 5,
        width: currentPage == number ? 30 : 5,
        decoration: BoxDecoration(
          color:
              currentPage == number
                  ? Colors.amber
                  : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
