import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

// Used by the make sales page "Save Draft" button on both
// platforms.
Future<void> saveDraftAction(BuildContext context) async {
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (firstConctext) {
      return ConfirmationAlert(
        theme: theme,
        message:
            'You are about to Save this Sale as a Draft. Are you sure you want to continue?',
        title: 'Save Draft',
        action: () async {
          Navigator.of(firstConctext).pop();
          final saved =
              await returnSalesProvider().saveDraft();
          if (!context.mounted) return;
          if (saved) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Draft saved'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else {
            showDialog(
              context: context,
              builder: (alertContext) {
                return InfoAlert(
                  theme: returnTheme(
                    context,
                    listen: false,
                  ),
                  title: 'Draft Not Saved',
                  message:
                      'Add at least one item to the cart before saving a draft.',
                );
              },
            );
          }
        },
      );
    },
  );
}

class DraftsButton extends StatelessWidget {
  const DraftsButton({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final count =
        returnDraftsProvider(
          context: context,
        ).drafts.length;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(3),
        onTap: () {
          DraftsListSheet.show(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color.fromARGB(
                255,
                94,
                194,
                124,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                size: 16,
                color: theme.lightModeColor.greyColor200,
                Icons.edit_note,
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                ),
                'Drafts ($count)',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DraftsListSheet extends StatelessWidget {
  final BuildContext parentContext;
  const DraftsListSheet({
    super.key,
    required this.parentContext,
  });

  static Future<void> show(BuildContext context) {
    if (MediaQuery.of(context).size.width < mobileScreen) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (sheetContext) {
          return SizedBox(
            height:
                MediaQuery.of(sheetContext).size.height *
                0.75,
            child: DraftsListSheet(parentContext: context),
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: 520,
              height: 600,
              child: DraftsListSheet(
                parentContext: context,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final drafts =
        returnDraftsProvider(context: context).drafts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Saved Drafts',
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child:
                drafts.isEmpty
                    ? Center(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b2.fontSize,
                          color:
                              theme
                                  .lightModeColor
                                  .greyColor100,
                        ),
                        'No saved drafts',
                      ),
                    )
                    : ListView(
                      children:
                          drafts
                              .map(
                                (item) => DraftListTile(
                                  draft: item,
                                  parentContext:
                                      parentContext,
                                ),
                              )
                              .toList(),
                    ),
          ),
        ],
      ),
    );
  }
}

class DraftListTile extends StatelessWidget {
  final Drafts draft;
  final BuildContext parentContext;
  const DraftListTile({
    super.key,
    required this.draft,
    required this.parentContext,
  });

  String title() {
    if (draft.comment != null) {
      return draft.comment!;
    } else {
      return 'Untitled Draft';
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final itemCount = draft.getItemCount();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      title(),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor100,
                          ),
                          overflow: TextOverflow.ellipsis,
                          'Customer Name: ${draft.customerName ?? "Not Set"}',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor100,
                          ),
                          overflow: TextOverflow.ellipsis,
                          '$itemCount ${itemCount == 1 ? 'item' : 'items'} · ${draft.staffName ?? ''} · ${formatDateWithTime(draft.updatedAt ?? draft.createdAt)}',
                        ),
                      ],
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      formatMoneyMid(
                        amount: draft.total ?? 0,
                        context: context,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 1,
              horizontal: 15,
            ),
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color.fromARGB(
                188,
                255,
                255,
                255,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 5,
              children: [
                IconButton(
                  tooltip: 'Delete Draft',
                  mouseCursor: SystemMouseCursors.click,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (alertContext) {
                        return ConfirmationAlert(
                          theme: theme,
                          title: 'Delete Draft?',
                          message:
                              'This draft will be deleted on all devices. This cannot be undone.',
                          action: () async {
                            Navigator.of(
                              alertContext,
                            ).pop();
                            await returnDraftsProvider()
                                .deleteDraft(draft.uuid!);
                          },
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color:
                        theme.lightModeColor.errorColor200,
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      color:
                          theme.lightModeColor.secColor200,
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () async {
                        Navigator.of(context).pop();
                        if (parentContext.mounted) {
                          await returnDraftsProvider()
                              .onContinueDraft(
                                draft: draft,
                                context: parentContext,
                              );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),

                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          'Continue',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
