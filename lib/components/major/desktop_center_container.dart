import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';

class DesktopCenterContainer extends StatelessWidget {
  final double? width;
  final Widget mainWidget;
  const DesktopCenterContainer({
    super.key,
    required this.mainWidget,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backGroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              color: const Color.fromARGB(
                201,
                255,
                255,
                255,
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 40),
                width: width ?? 550,
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        46,
                        0,
                        0,
                        0,
                      ),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: mainWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
