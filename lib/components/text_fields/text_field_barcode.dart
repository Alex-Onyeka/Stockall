import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class TextFieldBarcode extends StatefulWidget {
  final TextEditingController searchController;
  final Function() clearTextField;
  final Function(String)? onChanged;
  final Function()? onPressedScan;

  const TextFieldBarcode({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onPressedScan,
    required this.clearTextField,
  });

  @override
  State<TextFieldBarcode> createState() =>
      _TextFieldBarcodeState();
}

class _TextFieldBarcodeState
    extends State<TextFieldBarcode> {
  final FocusNode _node = FocusNode();
  bool isFocus = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (screenWidth(context) > tabletScreen) {
        _node.requestFocus();
        setState(() {
          isFocus = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return TextFormField(
      focusNode: _node,
      controller: widget.searchController,
      onChanged: widget.onChanged,
      onTap: () {
        setState(() {
          isFocus = true;
        });
      },
      onTapOutside: (event) {
        setState(() {
          isFocus = false;
        });
      },
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        fillColor: Colors.white,
        filled: isFocus,
        suffixIcon: Visibility(
          visible:
              platforms(context) ==
                  TargetPlatform.android ||
              platforms(context) == TargetPlatform.iOS ||
              kIsWeb,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  if (widget
                      .searchController
                      .text
                      .isEmpty) {
                    widget.onPressedScan!();
                    setState(() {
                      isFocus = true;
                    });
                  } else {
                    widget.clearTextField();
                    widget.searchController.clear();
                    setState(() {
                      isFocus = false;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(
                    right: 20,
                    left: 30,
                    top: 10,
                    bottom: 10,
                  ),
                  child:
                      widget.searchController.text.isEmpty
                          ? Icon(
                            size: 20,
                            color:
                                isFocus
                                    ? theme
                                        .lightModeColor
                                        .secColor100
                                    : Colors.grey.shade600,
                            Icons.qr_code_scanner,
                          )
                          : Icon(
                            size: 20,
                            color:
                                isFocus
                                    ? theme
                                        .lightModeColor
                                        .secColor100
                                    : Colors.grey.shade600,
                            Icons.clear,
                          ),
                ),
              ),
            ),
          ),
        ),

        suffixIconConstraints: BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 5,
          ),
          child: Icon(
            size: 20,
            color:
                isFocus
                    ? theme.lightModeColor.secColor100
                    : Colors.grey,
            Icons.search_rounded,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        hintText: 'Search Name or Scan Barcode',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.grey.shade500,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: theme.lightModeColor.prColor300,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}
