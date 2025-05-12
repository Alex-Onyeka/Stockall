import 'package:flutter/material.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';

class ProductSummaryTab extends StatefulWidget {
  final String title;
  final bool? isMoney;
  final double value;
  final Color color;

  const ProductSummaryTab({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.isMoney,
  });

  @override
  State<ProductSummaryTab> createState() =>
      _ProductSummaryTabState();
}

class _ProductSummaryTabState
    extends State<ProductSummaryTab> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            widget.value.toString().length < 6 ? 15 : 10,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade200,
      ),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
              Text(
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                widget.title,
              ),
            ],
          ),
          Row(
            children: [
              Visibility(
                visible: widget.isMoney ?? false,
                child: Text(
                  style: TextStyle(
                    fontSize:
                        widget.value.toString().length < 6
                            ? theme.mobileTexts.h4.fontSize
                            : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  "N",
                ),
              ),
              SizedBox(width: 2),
              Text(
                style: TextStyle(
                  fontSize:
                      widget.value.toString().length < 6
                          ? theme.mobileTexts.h4.fontSize
                          : 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                formatLargeNumberDouble(widget.value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
