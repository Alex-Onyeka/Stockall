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
      NewFeaturePopUpFunc().markDialogClosed();
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
    name: 'Order Management',
    desc:
        'Manage customer orders from placement through partial or full delivery. Track remaining item quantities per order, record payments against orders, convert deliveries into receipts, and monitor order statuses (Unpaid, Partial, and Paid) with dedicated order reports and thermal/A4 receipts.',
    index: 0,
  ),
  UpdateInfoClass(
    name: 'Draft Sale Management',
    desc:
        'Save in-progress carts as drafts and resume them anytime without losing selected items, quantities, custom dimensions, prices, discounts, or customer details. Keep your checkout counter moving smoothly when a customer needs time before completing payment.',
    index: 1,
  ),
  UpdateInfoClass(
    name: 'Derive Quantity From Price',
    desc:
        'Enter the exact amount a customer wants to spend during a sale and let Stockall automatically calculate the corresponding item quantity based on the selected unit price. Ideal for weighed, measured, or flexible-quantity sales where customers buy by amount.',
    index: 2,
  ),
  UpdateInfoClass(
    name: 'Custom Payment Channels',
    desc:
        'Create and manage your own payment channels—including Bank Accounts, POS Machines, and Other channels—complete with account numbers, account names, and notes. Select specific channels during single or split payments, and see the exact channel reflected on receipts, invoices, PDF downloads, and thermal printouts.',
    index: 3,
  ),
  UpdateInfoClass(
    name: 'Customer Page Redesign',
    desc:
        'Enjoy a cleaner, more organized Customer page with clearer summaries of customer account balances, reward cashback, purchase history, and outstanding invoices. Quickly review customer activity and take action from one unified view.',
    index: 4,
  ),
  UpdateInfoClass(
    name: 'Pay Up All Customer Invoices',
    desc:
        'Settle multiple unpaid or partially paid invoices for a customer in a single flow instead of paying them off one by one. Apply a payment across outstanding invoices automatically, saving time and keeping customer balances accurate.',
    index: 5,
  ),
  UpdateInfoClass(
    name: 'Multiple Units Management',
    desc:
        'Configure multiple selling and stocking units for a single item (such as Pieces, Packs, Cartons, or Slabs) with conversion equivalents to your primary unit. Sell, restock, adjust, and transfer items in any configured unit while Stockall keeps total inventory automatically synchronized.',
    index: 6,
  ),
  UpdateInfoClass(
    name: 'Multiple Price Management',
    desc:
        'Set up multiple price tiers for each item—such as Retail, Wholesale, or custom unit-based prices—and switch between them effortlessly during sales and invoicing. Ensure the right price is always applied for every customer and selling unit.',
    index: 7,
  ),
  UpdateInfoClass(
    name: '2Dimensional Items Management',
    desc:
        'Manage 2D sheet and slab items (such as glass, wood, boards, fabric, or tiles) using Width and Height dimensions. Sell, adjust, or transfer either whole slabs or custom cut dimensions, with Stockall automatically calculating area equivalents and tracking remaining stock accurately.',
    index: 8,
  ),
  UpdateInfoClass(
    name: 'Products Markup and Margin Calculation',
    desc:
        'Automatically see your profit markup and margin percentages as you set cost and selling prices on products. Make informed pricing decisions faster with real-time profitability feedback right inside your item setup and editing screens.',
    index: 9,
  ),
  UpdateInfoClass(
    name: 'Full Products History Management',
    desc:
        'Track a complete audit trail of every product movement—including sales, restocks, manual adjustments, returns, transfers in/out, and production usage. Filter and inspect detailed item history tables and aggregated summaries to see what changed, when, and by whom.',
    index: 10,
  ),
  UpdateInfoClass(
    name: 'Bulk Products Upload',
    desc:
        'Import multiple products into your inventory at once using downloadable CSV or Excel (XLSX) templates. Stockall validates rows upfront and highlights any issues before saving, making large catalog setup and onboarding fast and error-free.',
    index: 11,
  ),
  UpdateInfoClass(
    name: 'Bulk Stock Adjustment',
    desc:
        'Select multiple items from your products list and add to or replace their stock quantities in one batch. Supports multiple units as well as whole slabs or custom dimensions for 2D items, with automatic item history logging for every adjustment.',
    index: 12,
  ),
  UpdateInfoClass(
    name: 'Bulk Items Transfer',
    desc:
        'Transfer multiple selected items at once between branches or departments. Link destination products or auto-create missing ones, specify quantities in any unit—including whole slabs or custom dimensions for 2D items—and review a clear confirmation summary before executing.',
    index: 13,
  ),
  UpdateInfoClass(
    name: 'Full Reports Redesign Breakdown',
    desc:
        'Explore a completely redesigned Reports hub broken down into focused, easy-to-navigate sections across Sales, Orders, Invoices, Purchases, Customers, Suppliers, Staff, Storage, and Production (split into Material Report, Production Record Report, and Production Items Report).',
    index: 14,
  ),
  UpdateInfoClass(
    name: 'Reports Export, Download and Print',
    desc:
        'Export, download, and print your reports in multiple formats—including A4 PDF, thermal roll PDF, CSV/Excel spreadsheets, and direct Bluetooth ESC/POS thermal printing—so you can share, archive, or print summaries wherever you work.',
    index: 15,
  ),
];
