import 'package:flutter/material.dart';

class DesktopPageContainer extends StatelessWidget {
  final Widget widget;
  const DesktopPageContainer({
    super.key,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(39, 4, 1, 41),
            blurRadius: 10,
          ),
        ],
      ),
      child: widget,
    );
  }
}
