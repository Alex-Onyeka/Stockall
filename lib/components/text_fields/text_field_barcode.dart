import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';

class TextFieldBarcode extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String)? onChanged;
  final Function()? onPressedScan;

  const TextFieldBarcode({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onPressedScan,
  });

  @override
  State<TextFieldBarcode> createState() =>
      _TextFieldBarcodeState();
}

class _TextFieldBarcodeState
    extends State<TextFieldBarcode> {
  bool isFocus = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return TextFormField(
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
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: isFocus,
        suffixIcon: IconButton(
          onPressed: () {
            if (widget.searchController.text.isEmpty) {
              widget.onPressedScan!();
              setState(() {
                isFocus = true;
              });
            } else {
              widget.searchController.clear();
              setState(() {
                isFocus = false;
              });
            }
          },
          icon:
              widget.searchController.text.isEmpty
                  ? Icon(
                    color:
                        isFocus
                            ? theme
                                .lightModeColor
                                .secColor100
                            : Colors.grey.shade600,
                    Icons.qr_code_scanner,
                  )
                  : Icon(
                    color:
                        isFocus
                            ? theme
                                .lightModeColor
                                .secColor100
                            : Colors.grey.shade600,
                    Icons.clear,
                  ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        prefixIcon: Icon(
          size: 25,
          color:
              isFocus
                  ? theme.lightModeColor.secColor100
                  : Colors.grey,
          Icons.search_rounded,
        ),
        hintText: 'Search Name or Scan Barcode',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16,
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
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
