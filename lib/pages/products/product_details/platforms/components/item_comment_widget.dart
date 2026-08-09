import 'package:flutter/material.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/main.dart';

class ItemCommentWidget extends StatefulWidget {
  final TextEditingController commentController;
  // final String? comment;
  // final Function()? action;
  final Function(PointerDownEvent pointerDownEvent)?
  onTapOutside;
  const ItemCommentWidget({
    super.key,
    required this.commentController,
    // required this.action,
    // required this.comment,
    this.onTapOutside,
  });

  @override
  State<ItemCommentWidget> createState() =>
      _ItemCommentWidgetState();
}

class _ItemCommentWidgetState
    extends State<ItemCommentWidget> {
  // bool isEdit = false;

  // void toggleIsEdit(bool value) {
  //   setState(() {
  //     isEdit = value;
  //     widget.commentController.clear();
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    widget.commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          // SizedBox(height: 10),
          Divider(),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Comment:',
              ),
            ],
          ),
          Builder(
            builder: (context) {
              return Column(
                children: [
                  SizedBox(height: 5),
                  GeneralTextfieldOnly(
                    onTapOutside: widget.onTapOutside,
                    textInputAction:
                        TextInputAction.newline,
                    minLines: 3,
                    hint: 'Enter Comment',
                    controller: widget.commentController,
                    lines: 6,
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
