import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storrec/main.dart';

class ProductActionTile extends StatelessWidget {
  final String text;
  final String svg;
  final Function()? action;

  const ProductActionTile({
    super.key,
    required this.text,
    required this.svg,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        child: Row(
          spacing: 15,
          children: [
            SvgPicture.asset(svg),
            Text(
              style: TextStyle(
                fontSize:
                    returnTheme(
                      context,
                    ).mobileTexts.b2.fontSize,
                fontWeight: FontWeight.w600,
              ),
              text,
            ),
          ],
        ),
      ),
    );
  }
}
