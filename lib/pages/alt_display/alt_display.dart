import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/theme/main_theme.dart';

class AltDisplayWaiting extends StatefulWidget {
  const AltDisplayWaiting({super.key});

  @override
  State<AltDisplayWaiting> createState() =>
      AltDisplayWaitingState();
}

class AltDisplayWaitingState
    extends State<AltDisplayWaiting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backGroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            color: const Color.fromARGB(201, 255, 255, 255),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      46,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          12,
                          0,
                          0,
                          0,
                        ),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Lottie.asset(
                          welcomeLady,
                          height: 70,
                        ),
                      ),
                      Image.asset(mainnLogo, height: 35),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AltDisplay extends StatefulWidget {
  final String cartId;
  final int windowId;

  const AltDisplay({
    super.key,
    required this.windowId,
    required this.cartId,
  });

  @override
  State<AltDisplay> createState() => AltDisplayState();
}

class AltDisplayState extends State<AltDisplay> {
  Future<dynamic> handleMethodCall(
    MethodCall call,
    int fromWindowId,
  ) async {
    try {
      switch (call.method) {
        case 'update_cart':
          final data = jsonDecode(call.arguments as String);
          final cart = AltCartClass.fromJson(data);
          setState(() {
            cartClass = cart;
            showCart = null;
          });
          break;
        case 'show_cart':
          setState(() {
            showCart = false;
          });
          break;

        default:
          print('Unknown method: ${call.method}');
      }
    } catch (e) {
      print('Error Updating Alt Screen: ${e.toString()}');
    }
  }

  bool? showCart = true;

  @override
  void initState() {
    super.initState();

    DesktopMultiWindow.setMethodHandler(handleMethodCall);
    initCartClass();
  }

  AltCartClass? cartClass;

  double calcTotalMain() {
    double tempTotal = 0;
    for (var item in cartClass!.cartItems.where(
      (item) => item.isVoid != true,
    )) {
      tempTotal += item.totalCostForAltScreen();
    }
    return tempTotal;
  }

  double calcVatAmount() {
    if (cartClass!.vat != 0) {
      return calcTotalMain() * (cartClass!.vat / 100);
    } else {
      return 0;
    }
  }

  double calcFinalTotalMain() {
    return (calcTotalMain() - calcDiscountMain()) +
        calcVatAmount();
  }

  void initCartClass() {
    cartClass = AltCartClass(
      cartId: widget.cartId,
      cartItems: [],
      fixedDiscount: 0,
      percentDiscount: 0,
      vat: 0,
      currency: '#',
    );
  }

  MobileTexts mobileTexts = MobileTexts();
  TabletTexts tabletTexts = TabletTexts();

  double calcDiscountMain() {
    if (cartClass!.fixedDiscount != null) {
      return cartClass!.fixedDiscount ?? 0;
    } else if (cartClass!.percentDiscount != null) {
      return calcSubTotal() *
          ((cartClass!.percentDiscount ?? 0) / 100);
    } else {
      double tempTotalDiscount = 0;
      for (var item in cartClass!.cartItems) {
        if (item.useGroupQuantity == true) {
          if (item.item.discount != null &&
              item.customPrice == null) {
            double discountPerUnit =
                (item.item.sellingPrice ?? 0) *
                (item.item.discount! / 100);
            tempTotalDiscount +=
                discountPerUnit *
                (item.quantity *
                    item.getQttyPerGroupForAltScreen());
          }
        } else {
          if (item.item.discount != null &&
              item.customPrice == null) {
            double discountPerUnit =
                (item.item.sellingPrice ?? 0) *
                (item.item.discount! / 100);
            tempTotalDiscount +=
                discountPerUnit * item.quantity;
          }
        }
      }
      return tempTotalDiscount;
    }
  }

  double calcSubTotal() {
    double tempTotal = 0;
    for (var item in cartClass!.cartItems) {
      tempTotal += item.totalCostForAltScreen();
    }
    return tempTotal.roundToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (showCart == null) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backGroundImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  color: const Color.fromARGB(
                    201,
                    255,
                    255,
                    255,
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            46,
                            0,
                            0,
                            0,
                          ),
                          blurRadius: 10,
                          spreadRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Scaffold(
                      body: Row(
                        // spacing: 15,
                        children: [
                          Expanded(
                            flex: 10,
                            child: DesktopPageContainer(
                              widget: Scaffold(
                                body: Column(
                                  spacing: 0,
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              vertical:
                                                  10.0,
                                            ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    left:
                                                        20.0,
                                                  ),
                                                  child: Image.asset(
                                                    mainnLogo,
                                                    height:
                                                        22,
                                                  ),
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Cart Items',
                                                ),
                                                Opacity(
                                                  opacity:
                                                      0,
                                                  child: Image.asset(
                                                    mainnLogo,
                                                    height:
                                                        28,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Builder(
                                        builder: (context) {
                                          if (cartClass!
                                              .cartItems
                                              .isEmpty) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        10.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  EmptyWidgetAltScreen(),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal:
                                                        0.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            10,
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal:
                                                                10.0,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    10,
                                                              ),
                                                              Expanded(
                                                                child: Builder(
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    List<
                                                                      TempCartItem
                                                                    >
                                                                    items =
                                                                        cartClass!.cartItems
                                                                            .where(
                                                                              (
                                                                                item,
                                                                              ) =>
                                                                                  item.isVoid !=
                                                                                  true,
                                                                            )
                                                                            .toList();

                                                                    if (items.isEmpty) {
                                                                      return Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          EmptyWidgetAltScreen(),
                                                                        ],
                                                                      );
                                                                    } else {
                                                                      return ListView.builder(
                                                                        itemCount:
                                                                            cartClass!.cartItems
                                                                                .where(
                                                                                  (
                                                                                    item,
                                                                                  ) =>
                                                                                      item.isVoid !=
                                                                                      true,
                                                                                )
                                                                                .length,
                                                                        itemBuilder: (
                                                                          context,
                                                                          index,
                                                                        ) {
                                                                          // return Container();
                                                                          return CartItemAlt(
                                                                            cartItem:
                                                                                items[index],
                                                                            currency:
                                                                                cartClass!.currency,
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            flex:
                                screenWidth(context) <
                                        tabletScreen
                                    ? 5
                                    : 3,
                            child: Container(
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.only(
                                      topLeft:
                                          Radius.circular(
                                            15,
                                          ),
                                      topRight:
                                          Radius.circular(
                                            15,
                                          ),
                                    ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                      15,
                                      20,
                                      15,
                                      15,
                                    ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .start,
                                    children: [
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  mobileTexts
                                                      .b2
                                                      .fontSize,
                                            ),
                                            'Subtotal',
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  mobileTexts
                                                      .b2
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            formatMoneyAlt(
                                              currency:
                                                  cartClass!
                                                      .currency,
                                              amount:
                                                  calcTotalMain(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible:
                                            cartClass!
                                                    .percentDiscount !=
                                                null ||
                                            cartClass!
                                                    .fixedDiscount !=
                                                null,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            mobileTexts.b2.fontSize,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                      'Discount',
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          cartClass!.percentDiscount !=
                                                          null,
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              mobileTexts.b2.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                        ' (${formatLargeNumberDouble(cartClass!.percentDiscount ?? 0)}%)',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        mobileTexts.b2.fontSize,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                  '- ${formatMoneyAlt(amount: calcDiscountMain(), currency: cartClass!.currency)}',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          mobileTexts.b2.fontSize,
                                                      // fontWeight: FontWeight.bold,
                                                    ),
                                                    'VAT:',
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          mobileTexts.b2.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // fontWeight: FontWeight.bold,
                                                    ),
                                                    ' ${cartClass!.vat.toString()}%',
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      mobileTexts
                                                          .b2
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                formatMoneyAlt(
                                                  currency:
                                                      cartClass!
                                                          .currency,
                                                  amount:
                                                      cartClass!.vat !=
                                                              0
                                                          ? ((cartClass!.vat /
                                                                  100) *
                                                              calcTotalMain())
                                                          : 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  mobileTexts
                                                      .h3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Total',
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  mobileTexts
                                                      .h3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            formatMoneyAlt(
                                              currency:
                                                  cartClass!
                                                      .currency,
                                              amount:
                                                  calcFinalTotalMain(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return AltDisplayWaiting();
        }
      },
    );
  }
}

class AltCartClass {
  final String cartId;
  final List<TempCartItem> cartItems;
  final double vat;
  final double? fixedDiscount;
  final double? percentDiscount;
  final String currency;

  AltCartClass({
    required this.cartId,
    required this.cartItems,
    required this.vat,
    required this.currency,
    this.fixedDiscount,
    this.percentDiscount,
  });

  Map<String, dynamic> toJson() => {
    'cart_id': cartId,
    'cart_items': cartItems.map((c) => c.toJson()).toList(),
    'vat': vat,
    'currency': currency,
    'fixed_discount': fixedDiscount,
    'percent_discount': percentDiscount,
  };

  // Create from JSON
  factory AltCartClass.fromJson(Map<String, dynamic> json) {
    return AltCartClass(
      cartId: json['cart_id'] as String,
      cartItems:
          (json['cart_items'] as List)
              .map(
                (item) => TempCartItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      percentDiscount:
          (json['percent_discount'] as num?)?.toDouble(),
      vat: (json['vat'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

class EmptyWidgetAltScreen extends StatefulWidget {
  const EmptyWidgetAltScreen({super.key});

  @override
  State<EmptyWidgetAltScreen> createState() =>
      _EmptyWidgetAltScreenState();
}

class _EmptyWidgetAltScreenState
    extends State<EmptyWidgetAltScreen> {
  MobileTexts mobileTexts = MobileTexts();
  TabletTexts tabletTexts = TabletTexts();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              SvgPicture.asset(productIconSvg, height: 30),
            ],
          ),
        ),

        SizedBox(height: 15),
        Text(
          style: TextStyle(
            fontSize: mobileTexts.b1.fontSize,
            fontWeight: FontWeight.bold,
          ),
          'Cart List Empty',
        ),
        SizedBox(height: 5),
        Text(
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: mobileTexts.b2.fontSize,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          'Start Adding Items to Cart to make Sales',
        ),
      ],
    );
  }
}

class CartItemAlt extends StatefulWidget {
  final String currency;
  final TempCartItem cartItem;
  const CartItemAlt({
    super.key,
    required this.cartItem,
    required this.currency,
  });

  @override
  State<CartItemAlt> createState() => _CartItemAltState();
}

class _CartItemAltState extends State<CartItemAlt> {
  MobileTexts mobileTexts = MobileTexts();
  LightModeColor lightModeColor = LightModeColor();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                41,
                158,
                158,
                158,
              ),
              blurRadius: 5,
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(5),
          elevation: 0,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),

            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade200,
                  ),
                  child: Icon(Icons.shopping_bag_outlined),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  mobileTexts.b2.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            widget.cartItem.item.name,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      lightModeColor
                                          .prColor300,
                                ),
                                formatMoneyAlt(
                                  amount:
                                      widget.cartItem
                                          .totalCost(),
                                  currency: widget.currency,
                                ),
                              ),
                            ],
                          ),
                          Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                color: Colors.grey.shade100,
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                child: Container(
                                  height: 30,
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),

                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      Center(
                                        child: Text(
                                          style: TextStyle(
                                            color:
                                                lightModeColor
                                                    .prColor300,
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          formatLargeNumberDouble(
                                            widget
                                                .cartItem
                                                .quantity,
                                          ),
                                        ),
                                      ),
                                      // SvgPicture.asset(
                                      //   height: 16,
                                      //   editIconSvg,
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
