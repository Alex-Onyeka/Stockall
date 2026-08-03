import 'package:flutter/material.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/main.dart';

class ReceiptCommentWidget extends StatefulWidget {
  const ReceiptCommentWidget({super.key});

  @override
  State<ReceiptCommentWidget> createState() =>
      _ReceiptCommentWidgetState();
}

class _ReceiptCommentWidgetState
    extends State<ReceiptCommentWidget> {
  final commentController = TextEditingController();
  bool isEdit = false;

  void toggleIsEdit(bool value) {
    setState(() {
      isEdit = value;
      commentController.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          SizedBox(height: 10),
          Divider(),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            spacing: 5,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Comment:',
              ),
              Row(
                spacing: 5,
                children: [
                  Visibility(
                    visible: isEdit,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        toggleIsEdit(false);
                      },
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(8),
                        child: Icon(size: 18, Icons.clear),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isEdit,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        returnSalesProvider().setComment(
                          comment:
                              commentController
                                      .text
                                      .isNotEmpty
                                  ? commentController.text
                                  : null,
                        );
                        toggleIsEdit(false);
                      },
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(7),
                        child: Icon(size: 20, Icons.check),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isEdit,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        toggleIsEdit(true);
                      },
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(8),
                        child: Icon(size: 18, Icons.edit),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Builder(
            builder: (context) {
              if (isEdit) {
                commentController.text =
                    returnSalesProvider()
                        .currentCart()
                        .comment ??
                    '';
                return Column(
                  children: [
                    SizedBox(height: 5),
                    GeneralTextfieldOnly(
                      hint: 'Enter Comment',
                      controller: commentController,
                      lines: 3,
                      theme: theme,
                    ),
                  ],
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          returnSalesProvider()
                                  .currentCart()
                                  .comment ??
                              'Comment Not Set',
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
