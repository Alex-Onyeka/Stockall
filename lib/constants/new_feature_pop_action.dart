import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/new_feature_pop_up_func/new_feature_pop_up_func.dart';
import 'package:stockall/main.dart';

void newFeaturesUpdatePopUpAction({
  required BuildContext context,
  required bool isFromSettingPage,
}) {
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (templateContext) {
      return DialogTemplate(
        theme: theme,
        message:
            'New features was introduced with this new version. Below, are a List of the new Features that was Added/Updated.',
        title: '📢 New Features Update 📢',
        action: () {},
        showBottomActionButtons: false,
        topRightWidget: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              Navigator.of(templateContext).pop();
            },
            mouseCursor: SystemMouseCursors.click,
            child: Padding(
              padding: EdgeInsetsGeometry.all(5),
              child: Icon(size: 20, Icons.clear),
            ),
          ),
        ),
        widget: SizedBox(
          height: screenHeight(context) - 200,
          child: NewFeaturesBodyWidget(),
        ),
      );
    },
  ).then((_) {
    if (!isFromSettingPage) {
      NewFeaturePopUpFunc().viewPopUpAction();
    }
  });
}

class NewFeaturesBodyWidget extends StatefulWidget {
  const NewFeaturesBodyWidget({super.key});

  @override
  State<NewFeaturesBodyWidget> createState() =>
      _NewFeaturesBodyWidgetState();
}

class _NewFeaturesBodyWidgetState
    extends State<NewFeaturesBodyWidget> {
  int? index;

  void setIndex(int newIndex) {
    setState(() {
      if (newIndex == index) {
        index = null;
      } else {
        index = newIndex;
      }
    });
  }

  bool isSelected(int myIndex) {
    return myIndex == index;
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'NOTE: Please Kindly Proceed to Contact the Customer care for Further Information and Guide on how to Set it up, and Use.',
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    openWhatsApp();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 15,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        Icon(size: 14, Icons.call),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Contact Customer Care',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Column(
              spacing: 10,
              children:
                  updates
                      .map(
                        (item) => Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () {
                              setIndex(item.index);
                            },
                            mouseCursor:
                                SystemMouseCursors.click,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                10,
                                10,
                                10,
                                10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      3,
                                    ),
                                border: Border.all(
                                  color:
                                      Colors.grey.shade200,
                                ),
                                color: const Color.fromARGB(
                                  166,
                                  245,
                                  245,
                                  245,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .secColor100,
                                              Icons
                                                  .arrow_right_rounded,
                                            ),
                                            Expanded(
                                              child: Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b2
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                item.name,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        size: 25,
                                        isSelected(
                                              item.index,
                                            )
                                            ? Icons
                                                .keyboard_arrow_up_rounded
                                            : Icons
                                                .keyboard_arrow_down_rounded,
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: isSelected(
                                      item.index,
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 5,
                                          ),
                                      child: Column(
                                        children: [
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Description:',
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                  ),
                                                  item.desc ??
                                                      'Not Set',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

class UpdateInfoClass {
  final String name;
  final String? desc;
  final int index;

  UpdateInfoClass({
    required this.name,
    required this.desc,
    required this.index,
  });
}

List<UpdateInfoClass> updates = [
  UpdateInfoClass(
    name: 'Customer Account Balance Management',
    desc:
        'Customers can now deposit money, withdraw, and make purchases using their Stockall account balance. Let your customers deposit money with you and come back anytime to shop using their available balance. Simple, flexible, and convenient for both you and your customers.',
    index: 0,
  ),
  UpdateInfoClass(
    name: 'Customer Reward Cashback',
    desc:
        'Customers can now earn rewards from every purchase they make. These rewards are displayed as cash value on the customer\'s page. Whenever you want, you can use their accumulated rewards to gift, reward, or appreciate your loyal customers.',
    index: 1,
  ),
  UpdateInfoClass(
    name: 'Full Production/Manufacturing Management',
    desc:
        'You can now fully manage your productions, production items, and raw materials in Stockall. Track what goes into every production, with detailed reports and notifications to help you monitor material usage and stay in control.',
    index: 2,
  ),
  UpdateInfoClass(
    name: 'Full Item Quantity Changes Update',
    desc:
        'Stockall Now Creates a notification for every item quantity changes in your app. Ranging from sales of items, returns, manual updates, items transfers, and more. Stay updated on every movement in your inventory, so you always know what changed, when it changed, and why.',
    index: 3,
  ),
  UpdateInfoClass(
    name: 'Bulk Sales Management',
    desc:
        'You can now select and add multiple items to your cart at once instead of adding them one after another. Save time, speed up your sales, and get your cart ready faster than ever.',
    index: 4,
  ),
  UpdateInfoClass(
    name: 'Manage Cart Operations',
    desc:
        'Stockall now lets you track and secure sensitive cart operations — like removing items, deducting quantities, deleting an entire cart, or clearing a cart. Set a General PIN to authorize or restrict these actions, and get notified whenever they\'re performed. More control, better accountability, and greater security for your business.',
    index: 5,
  ),
  UpdateInfoClass(
    name: 'Multiple Categories for Single Item',
    desc:
        'You can now add an item to multiple categories for more flexible and organized inventory management. Categorize your products in different ways, making it easier to organize, find, and manage your inventory.',
    index: 6,
  ),
];
