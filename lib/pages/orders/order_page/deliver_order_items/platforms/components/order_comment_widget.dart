import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class OrderCommentWidget extends StatefulWidget {
  const OrderCommentWidget({super.key});

  @override
  State<OrderCommentWidget> createState() =>
      _OrderCommentWidgetState();
}

class _OrderCommentWidgetState
    extends State<OrderCommentWidget> {
  final commentController = TextEditingController();

  bool isOpen = false;

  void toggleIsOpen() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Column(
      children: [
        Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  toggleIsOpen();
                },
                mouseCursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 3,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'Comment:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                            ),
                            cutLongText(
                              returnOrdersActionProvider(
                                        context: context,
                                      ).comment ==
                                      null
                                  ? 'Not Set'
                                  : returnOrdersActionProvider(
                                        context: context,
                                      ).comment ??
                                      '',
                              15,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        isOpen
                            ? Icons
                                .keyboard_double_arrow_up_rounded
                            : Icons
                                .keyboard_double_arrow_down_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isOpen,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        openTextFieldComment(
                          commentController:
                              commentController,
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      mouseCursor: SystemMouseCursors.click,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Expanded(
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                returnOrdersActionProvider(
                                      context: context,
                                    ).comment ??
                                    'Comment Not Set',
                              ),
                            ),
                            Icon(
                              size: 18,
                              color: Colors.grey.shade600,
                              Icons.edit_square,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(height: 1),
      ],
    );
  }

  void openTextFieldComment({
    required TextEditingController commentController,
  }) {
    var theme = returnTheme(context, listen: false);
    var orderAction = returnOrdersActionProvider();
    commentController.text = orderAction.comment ?? '';
    showDialog(
      context: context,
      builder: (firstContext) {
        return DialogTemplate(
          theme: theme,
          message: 'Enter Comment Below',
          title: 'Edit Comment',
          action: () {
            showDialog(
              context: context,
              builder: (newContext) {
                return ConfirmationAlert(
                  theme: theme,
                  message:
                      'You are about to ${commentController.text.isNotEmpty ? 'Set' : "Clear"} this Comment. Are you sure you want to Proceed?',
                  title:
                      '${commentController.text.isNotEmpty ? 'Set' : "Clear"} Comment',
                  action: () {
                    Navigator.of(newContext).pop();
                    orderAction.setComment(
                      newComment:
                          commentController.text.isNotEmpty
                              ? commentController.text
                                  .trim()
                              : null,
                    );
                    Navigator.of(firstContext).pop();
                  },
                );
              },
            );
          },
          widget: SizedBox(
            height: 100,
            child: GeneralTextfieldOnly(
              hint: 'Enter Comment',
              controller: commentController,
              lines: 4,
              minLines: 4,
              theme: theme,
              autoFocus: true,
              textInputAction: TextInputAction.newline,
            ),
          ),
        );
      },
    );
  }
}
