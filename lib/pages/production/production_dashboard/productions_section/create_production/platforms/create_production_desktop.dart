import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/productions_cart.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/components/production_total_tab.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/components/production_materials_cart_item_tile.dart';

class CreateProductionDesktop extends StatefulWidget {
  const CreateProductionDesktop({super.key});

  @override
  State<CreateProductionDesktop> createState() =>
      _CreateProductionDesktopState();
}

class _CreateProductionDesktopState
    extends State<CreateProductionDesktop> {
  @override
  Widget build(BuildContext context) {
    var cartActionProv = returnProductionsActionProvider();
    ProductionsCart? cartItem =
        returnProductionsActionProvider(
          context: context,
        ).getProductionsCart();
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      width: 900,
      mainWidget: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 15),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 20,
                    ),
                    child: Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                ),
              ),
              Column(
                spacing: 2,
                children: [
                  Text(
                    style: TextStyle(
                      color:
                          theme
                              .lightModeColor
                              .shadesColorBlack,
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
                      fontWeight:
                          theme
                              .mobileTexts
                              .h4
                              .fontWeightBold,
                    ),
                    'Create Production',
                  ),
                  Text(
                    style:
                        theme
                            .mobileTexts
                            .b3
                            .textStyleNormal,
                    "Create, New Production",
                  ),
                ],
              ),
              Opacity(
                opacity:
                    (cartItem
                                    ?.materialsCartItems
                                    .isNotEmpty ==
                                true &&
                            cartItem?.productionsCartItem ==
                                null)
                        ? 0
                        : 1,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      cartActionProv.clearProductionCart();
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.only(
                        right: 10,
                        left: 10,
                        top: 5,
                        bottom: 5,
                      ),
                      decoration: BoxDecoration(),
                      child: Row(
                        spacing: 3,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Clear',
                          ),
                          Icon(size: 17, Icons.clear),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Builder(
                builder: (context) {
                  if (cartItem == null) {
                    return EmptyWidgetDisplayOnly(
                      title: 'Cart Not Set',
                      subText:
                          'Click on the Button Below To Initialize Cart',
                      theme: theme,
                      height: 30,
                      altAction: () {
                        cartActionProv
                            .initProductionsCart();
                      },
                      altActionText: 'Init Cart',
                      altIcon: Icons.add,
                    );
                  } else {
                    return ListView(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                10,
                                10,
                                10,
                                0,
                              ),
                          child: Builder(
                            builder: (context) {
                              if (cartItem
                                      .productionsCartItem ==
                                  null) {
                                return EmptyWidgetDisplayOnly(
                                  title:
                                      'Production Item Not Set',
                                  subText:
                                      'Click on the Button Below To Initialize Cart',
                                  theme: theme,
                                  height: 30,
                                  altAction: () {
                                    cartActionProv
                                        .initProductionsCart();
                                  },
                                  altActionText:
                                      'Init Cart',
                                  altIcon: Icons.add,
                                );
                              } else {
                                return ProductionTotalTab(
                                  entries: 12,
                                  title: 'Produced Today',
                                  action: () {},
                                  number: 22,
                                  icon:
                                      Icons
                                          .view_in_ar_rounded,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor250,
                                  theme: theme,
                                );
                              }
                            },
                          ),
                        ),
                        Divider(
                          color: Colors.grey.shade400,
                          thickness: 0.3,
                        ),
                        Padding(
                          padding:
                              EdgeInsetsGeometry.fromLTRB(
                                10,
                                5,
                                10,
                                10,
                              ),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Materials',
                              ),
                              Material(
                                type:
                                    MaterialType
                                        .transparency,
                                child: InkWell(
                                  onTap: () {},
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 12,
                                        ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      spacing: 5,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .normal,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor200,
                                          ),
                                          'Add Material',
                                        ),
                                        Icon(
                                          size: 16,
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .secColor200,
                                          Icons.add,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            if (cartItem
                                .materialsCartItems
                                .isEmpty) {
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Material(
                                    type:
                                        MaterialType
                                            .transparency,
                                    child: EmptyWidgetDisplayOnly(
                                      title:
                                          'No Production Recorded',
                                      subText:
                                          'No Production has been recorded for today.',
                                      theme: theme,
                                      height: 0,
                                      // icon: Icons.clear,
                                      altAction: () {},
                                      altActionText:
                                          'Add New Material',
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                spacing: 5,
                                children:
                                    cartItem
                                        .materialsCartItems
                                        .map(
                                          (
                                            item,
                                          ) => ProductionMaterialCartItemTile(
                                            productionMaterialCartItem:
                                                item,
                                          ),
                                        )
                                        .toList(),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
