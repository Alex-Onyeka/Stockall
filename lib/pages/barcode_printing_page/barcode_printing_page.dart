import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/printer_settings/printer_settings.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_and_barcode_printer_class%20copy/price_and_barcode_printer_settings/price_and_barcode_printer_settings.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_tag_printer_class/price_tag_printer_settings/price_tag_printer_settings.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart';

class BarcodePrintingPage extends StatefulWidget {
  final TempProductClass? product;
  const BarcodePrintingPage({super.key, this.product});

  @override
  State<BarcodePrintingPage> createState() =>
      _BarcodePrintingPageState();
}

class _BarcodePrintingPageState
    extends State<BarcodePrintingPage> {
  bool isLoading = false;
  final TextEditingController searchController =
      TextEditingController();
  TempProductClass? productPage;
  final TextEditingController widthC =
      TextEditingController();
  final TextEditingController heightC =
      TextEditingController();
  final TextEditingController gapC =
      TextEditingController();
  final TextEditingController startX =
      TextEditingController();
  final TextEditingController startY =
      TextEditingController();
  final TextEditingController barcodeHeightC =
      TextEditingController();
  final TextEditingController barcodeScaleC =
      TextEditingController();
  final TextEditingController verticalSpacingC =
      TextEditingController();
  // final TextEditingController nameStartXC =
  //     TextEditingController();

  final TextEditingController gapPriceC =
      TextEditingController();
  // final TextEditingController startPricePriceX =
  //     TextEditingController();
  final TextEditingController startPricePriceY =
      TextEditingController();
  final TextEditingController labelWidthPrice =
      TextEditingController();
  final TextEditingController verticalSpacingPriceC =
      TextEditingController();

  final TextEditingController widthPriceAndBarcodeC =
      TextEditingController();
  final TextEditingController heightPriceAndBarcodeC =
      TextEditingController();
  final TextEditingController gapPriceAndBarcodeC =
      TextEditingController();
  final TextEditingController startXPriceAndBarcode =
      TextEditingController();
  final TextEditingController startYPriceAndBarcode =
      TextEditingController();
  final TextEditingController
  barcodeHeightPriceAndBarcodeC = TextEditingController();
  final TextEditingController barcodeScalePriceAndBarcodeC =
      TextEditingController();
  final TextEditingController
  verticalSpacingPriceAndBarcodeC = TextEditingController();

  void initPrinterSetting() {
    var shopP = returnShopProvider();
    widthC.text = shopP.printerSettings!.widthMm.toString();
    heightC.text =
        shopP.printerSettings!.heightMm.toString();
    gapC.text = shopP.printerSettings!.gapMm.toString();
    startX.text = shopP.printerSettings!.startX.toString();
    startY.text = shopP.printerSettings!.startY.toString();
    barcodeHeightC.text =
        shopP.printerSettings!.barcodeHeight.toString();
    barcodeScaleC.text =
        shopP.printerSettings!.barcodeScale.toString();
    verticalSpacingC.text =
        shopP.printerSettings!.verticalSpacing.toString();
    // nameStartXC.text =
    //     shopP.printerSettings!.nameStartX.toString();

    gapPriceC.text =
        shopP.priceTagPrinterSettings!.gapMm.toString();
    labelWidthPrice.text =
        shopP.priceTagPrinterSettings!.labelWidth
            .toString();
    // startPricePriceX.text =
    //     shopP.priceTagPrinterSettings!.startPriceX
    //         .toString();
    startPricePriceY.text =
        shopP.priceTagPrinterSettings!.startPriceY
            .toString();
    verticalSpacingPriceC.text =
        shopP.priceTagPrinterSettings!.verticalSpacing
            .toString();

    //
    //
    //widthC.text = shopP.printerSettings!.widthMm.toString();
    heightPriceAndBarcodeC.text =
        shopP.priceAndBarcodePrinterSettings!.heightMm
            .toString();
    gapPriceAndBarcodeC.text =
        shopP.priceAndBarcodePrinterSettings!.gapMm
            .toString();
    startXPriceAndBarcode.text =
        shopP.priceAndBarcodePrinterSettings!.startX
            .toString();
    startYPriceAndBarcode.text =
        shopP.priceAndBarcodePrinterSettings!.startY
            .toString();
    barcodeHeightPriceAndBarcodeC.text =
        shopP.priceAndBarcodePrinterSettings!.barcodeHeight
            .toString();
    barcodeScalePriceAndBarcodeC.text =
        shopP.priceAndBarcodePrinterSettings!.barcodeScale
            .toString();
    verticalSpacingPriceAndBarcodeC.text =
        shopP
            .priceAndBarcodePrinterSettings!
            .verticalSpacing
            .toString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData().clearBarcodeGenerationList();
      searchController.clear();

      if (widget.product != null) {
        print(widget.product?.name);
        setState(() {
          productPage = widget.product;
        });
        returnData().addToBarcodeGenerationList(
          ProductBarcode(
            product: widget.product!,
            number: 1,
          ),
        );
      }
      listPrinters();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
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
              child: Scaffold(
                body: DesktopPageContainer(
                  widget: Scaffold(
                    appBar: appBar(
                      backAction:
                          () => Navigator.of(context).pop(),
                      context: context,
                      title: 'Generate Barcode',
                      titleWidget: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                        width: 350,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Material(
                                type:
                                    MaterialType
                                        .transparency,
                                child: InkWell(
                                  onTap: () {
                                    returnData()
                                        .selectBarcodeGeneratingINdex(
                                          0,
                                        );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              returnData(
                                                        context:
                                                            context,
                                                      ).barcodeGeneratingIndex ==
                                                      0
                                                  ? theme
                                                      .lightModeColor
                                                      .secColor200
                                                  : Colors
                                                      .grey
                                                      .shade300,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(
                                            8.0,
                                          ),
                                      child: Center(
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                returnData(
                                                          context:
                                                              context,
                                                        ).barcodeGeneratingIndex ==
                                                        0
                                                    ? FontWeight
                                                        .bold
                                                    : null,
                                          ),
                                          'Barcode',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Material(
                                type:
                                    MaterialType
                                        .transparency,
                                child: InkWell(
                                  onTap: () {
                                    returnData()
                                        .selectBarcodeGeneratingINdex(
                                          1,
                                        );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              returnData(
                                                        context:
                                                            context,
                                                      ).barcodeGeneratingIndex ==
                                                      1
                                                  ? theme
                                                      .lightModeColor
                                                      .secColor200
                                                  : Colors
                                                      .grey
                                                      .shade300,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(
                                            8.0,
                                          ),
                                      child: Center(
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                returnData(
                                                          context:
                                                              context,
                                                        ).barcodeGeneratingIndex ==
                                                        1
                                                    ? FontWeight
                                                        .bold
                                                    : null,
                                          ),
                                          'Price',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Material(
                                type:
                                    MaterialType
                                        .transparency,
                                child: InkWell(
                                  onTap: () {
                                    returnData()
                                        .selectBarcodeGeneratingINdex(
                                          2,
                                        );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              returnData(
                                                        context:
                                                            context,
                                                      ).barcodeGeneratingIndex ==
                                                      2
                                                  ? theme
                                                      .lightModeColor
                                                      .secColor200
                                                  : Colors
                                                      .grey
                                                      .shade300,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(
                                            8.0,
                                          ),
                                      child: Center(
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                returnData(
                                                          context:
                                                              context,
                                                        ).barcodeGeneratingIndex ==
                                                        2
                                                    ? FontWeight
                                                        .bold
                                                    : null,
                                          ),
                                          'B.Code/Price',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      widget: SizedBox(
                        width: 300,
                        height: 35,
                        child: GeneralTextfieldOnly(
                          hint: 'Search Product Name',
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              setState(() {
                                productPage = null;
                              });
                            });
                          },
                          lines: 1,
                          theme: theme,
                        ),
                      ),
                    ),
                    body: Row(
                      spacing: 10,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 25,
                              horizontal: 20,
                            ),
                            child: Column(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    spacing: 5,
                                    children: [
                                      SizedBox(height: 5),
                                      Builder(
                                        builder: (context) {
                                          List<
                                            TempProductClass
                                          >
                                          products =
                                              returnData(
                                                context:
                                                    context,
                                              ).productList().where((
                                                product,
                                              ) {
                                                if (productPage ==
                                                    null) {
                                                  return product
                                                      .name
                                                      .toLowerCase()
                                                      .contains(
                                                        searchController.text.toLowerCase(),
                                                      );
                                                } else {
                                                  return product
                                                          .uuid ==
                                                      productPage
                                                          ?.uuid;
                                                }
                                              }).toList();
                                          return Expanded(
                                            child: ListView(
                                              children:
                                                  products
                                                      .map(
                                                        (
                                                          product,
                                                        ) => Material(
                                                          color:
                                                              Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () {
                                                              var dataP =
                                                                  returnData();
                                                              if (dataP.barcodeGenerationList
                                                                  .where(
                                                                    (
                                                                      pr,
                                                                    ) =>
                                                                        pr.product.uuid ==
                                                                        product.uuid,
                                                                  )
                                                                  .isNotEmpty) {
                                                                dataP.removeFromBarcodeGenerationList(
                                                                  ProductBarcode(
                                                                    product:
                                                                        product,
                                                                    number:
                                                                        1,
                                                                  ),
                                                                );
                                                              } else {
                                                                dataP.addToBarcodeGenerationList(
                                                                  ProductBarcode(
                                                                    product:
                                                                        product,
                                                                    number:
                                                                        1,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                border: Border(
                                                                  bottom: BorderSide(
                                                                    color:
                                                                        Colors.grey.shade100,
                                                                  ),
                                                                ),
                                                              ),
                                                              margin: EdgeInsets.symmetric(
                                                                vertical:
                                                                    5,
                                                              ),
                                                              padding: EdgeInsets.fromLTRB(
                                                                15,
                                                                10,
                                                                10,
                                                                10,
                                                              ),
                                                              child: Row(
                                                                spacing:
                                                                    12,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      spacing:
                                                                          8,
                                                                      children: [
                                                                        Icon(
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              theme.lightModeColor.secColor200,
                                                                          Icons.inventory_2,
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  theme.mobileTexts.b2.fontSize,
                                                                              // fontWeight:
                                                                              //     FontWeight.bold,
                                                                            ),
                                                                            product.name,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b3.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                      color:
                                                                          product.barcode ==
                                                                                  null
                                                                              ? Colors.redAccent
                                                                              : null,
                                                                    ),
                                                                    product.barcode ??
                                                                        'Barcode Not Set',
                                                                  ),
                                                                  Visibility(
                                                                    visible:
                                                                        returnData(
                                                                              context:
                                                                                  context,
                                                                            ).barcodeGenerationList
                                                                            .where(
                                                                              (
                                                                                pr,
                                                                              ) =>
                                                                                  pr.product.uuid ==
                                                                                  product.uuid,
                                                                            )
                                                                            .isNotEmpty,
                                                                    child: Icon(
                                                                      size:
                                                                          18,
                                                                      color:
                                                                          theme.lightModeColor.secColor200,
                                                                      Icons.check,
                                                                    ),
                                                                  ),
                                                                  Visibility(
                                                                    visible:
                                                                        product.uuid ==
                                                                        productPage?.uuid,
                                                                    child: IconButton(
                                                                      onPressed: () {
                                                                        setState(
                                                                          () {
                                                                            productPage =
                                                                                null;
                                                                            returnData().removeFromBarcodeGenerationList(
                                                                              ProductBarcode(
                                                                                product:
                                                                                    product,
                                                                                number:
                                                                                    1,
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      icon: Icon(
                                                                        size:
                                                                            18,
                                                                        Icons.clear,
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
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 300,
                          // height: 600,
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            color: Colors.grey.shade200,
                          ),
                          child: Column(
                            spacing: 10,
                            children: [
                              Row(
                                spacing: 5,
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        size: 18,
                                        Icons.refresh,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Avalaible Printers',
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      listPrinters();
                                    },
                                    icon: Icon(
                                      size: 18,
                                      Icons.refresh,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 2.5,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        20,
                                      ),
                                  color:
                                      theme
                                          .lightModeColor
                                          .secColor200,
                                ),
                              ),
                              Visibility(
                                visible:
                                    returnShopProvider(
                                      context: context,
                                    ).printerCache !=
                                    null,
                                child: Column(
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 15,
                                          ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        color:
                                            Color.fromARGB(
                                              200,
                                              255,
                                              255,
                                              255,
                                            ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Expanded(
                                            child: Column(
                                              spacing: 2,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  returnShopProvider(
                                                        context:
                                                            context,
                                                      ).printerCache?.name ??
                                                      'Name',
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,

                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  returnShopProvider(
                                                        context:
                                                            context,
                                                      ).printerCache?.driverName ??
                                                      'Driver Name',
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor200,
                                            size: 16,
                                            Icons.check,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    50,
                                                  ),
                                              onTap: () {
                                                var shopP =
                                                    returnShopProvider();
                                                initPrinterSetting();
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return DialogTemplate(
                                                      theme:
                                                          theme,
                                                      message:
                                                          'Edit Printer Settings',
                                                      title:
                                                          'Edit Printer',
                                                      topRightWidget: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            returnShopProvider().updatePrinterSettings(
                                                              returnShopProvider().defaultPrinterSettings,
                                                              returnShopProvider().defaultPriceTagPrinterSettings,
                                                              returnShopProvider().defaultPriceAndBarcodePrinterSettings,
                                                            );
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(
                                                              5.0,
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize.min,
                                                              spacing:
                                                                  3,
                                                              children: [
                                                                Icon(
                                                                  size:
                                                                      16,
                                                                  Icons.refresh,
                                                                ),
                                                                Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                  ),
                                                                  'Reset',
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      action: () {
                                                        var newSettings = PrinterSettings(
                                                          widthMm:
                                                              double.tryParse(
                                                                widthC.text,
                                                              ) ??
                                                              shopP.printerSettings!.widthMm,
                                                          heightMm:
                                                              double.tryParse(
                                                                heightC.text,
                                                              ) ??
                                                              shopP.printerSettings!.heightMm,
                                                          gapMm:
                                                              double.tryParse(
                                                                gapC.text,
                                                              ) ??
                                                              shopP.printerSettings!.gapMm,
                                                          startX:
                                                              int.tryParse(
                                                                startX.text,
                                                              ) ??
                                                              shopP.printerSettings!.startX,
                                                          startY:
                                                              int.tryParse(
                                                                startY.text,
                                                              ) ??
                                                              shopP.printerSettings!.startY,
                                                          barcodeHeight:
                                                              int.tryParse(
                                                                barcodeHeightC.text,
                                                              ) ??
                                                              shopP.printerSettings!.barcodeHeight,
                                                          barcodeScale:
                                                              int.tryParse(
                                                                barcodeScaleC.text,
                                                              ) ??
                                                              shopP.printerSettings!.barcodeScale,
                                                          verticalSpacing:
                                                              int.tryParse(
                                                                verticalSpacingC.text,
                                                              ) ??
                                                              shopP.printerSettings!.verticalSpacing,
                                                          // nameStartX:
                                                          //     int.tryParse(
                                                          //       nameStartXC.text,
                                                          //     ) ??
                                                          //     shopP.printerSettings!.nameStartX,
                                                        );
                                                        var newPriceTagSettings = PriceTagPrinterSettings(
                                                          gapMm:
                                                              double.tryParse(
                                                                gapPriceC.text,
                                                              ) ??
                                                              shopP.priceTagPrinterSettings!.gapMm,
                                                          labelWidth:
                                                              int.tryParse(
                                                                labelWidthPrice.text,
                                                              ) ??
                                                              shopP.priceTagPrinterSettings!.labelWidth,
                                                          startPriceY:
                                                              int.tryParse(
                                                                startPricePriceY.text,
                                                              ) ??
                                                              shopP.priceTagPrinterSettings!.startPriceY,
                                                          verticalSpacing:
                                                              int.tryParse(
                                                                verticalSpacingPriceC.text,
                                                              ) ??
                                                              shopP.priceTagPrinterSettings!.verticalSpacing,
                                                          // startTitleX:
                                                          //     int.tryParse(
                                                          //       startPriceTitleX.text,
                                                          //     ) ??
                                                          //     shopP.priceTagPrinterSettings!.startTitleX,
                                                        );
                                                        var newSettingsPriceAndBarcode = PriceAndBarcodePrinterSettings(
                                                          widthMm:
                                                              double.tryParse(
                                                                widthPriceAndBarcodeC.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.widthMm,
                                                          heightMm:
                                                              double.tryParse(
                                                                heightPriceAndBarcodeC.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.heightMm,
                                                          gapMm:
                                                              double.tryParse(
                                                                gapPriceAndBarcodeC.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.gapMm,
                                                          startX:
                                                              int.tryParse(
                                                                startXPriceAndBarcode.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.startX,
                                                          startY:
                                                              int.tryParse(
                                                                startYPriceAndBarcode.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.startY,
                                                          barcodeHeight:
                                                              int.tryParse(
                                                                barcodeHeightPriceAndBarcodeC.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.barcodeHeight,
                                                          barcodeScale:
                                                              int.tryParse(
                                                                barcodeScalePriceAndBarcodeC.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.barcodeScale,
                                                          verticalSpacing:
                                                              int.tryParse(
                                                                verticalSpacingPriceAndBarcodeC.text,
                                                              ) ??
                                                              shopP.priceAndBarcodePrinterSettings!.verticalSpacing,
                                                          // nameStartX:
                                                          //     int.tryParse(
                                                          //       nameStartXC.text,
                                                          //     ) ??
                                                          //     shopP.priceAndBarcodePrinterSettings!.nameStartX,
                                                        );
                                                        shopP.updatePrinterSettings(
                                                          newSettings,
                                                          newPriceTagSettings,
                                                          newSettingsPriceAndBarcode,
                                                        );
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      widget: Builder(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          if (returnData().barcodeGeneratingIndex ==
                                                              0) {
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize.min,
                                                              spacing:
                                                                  10,
                                                              children: [
                                                                SizedBox(
                                                                  height:
                                                                      20,
                                                                ),
                                                                // Row(
                                                                //   mainAxisAlignment:
                                                                //       MainAxisAlignment.spaceBetween,
                                                                //   spacing:
                                                                //       10,
                                                                //   children: [
                                                                //     Expanded(
                                                                //       child: EditCartTextField(
                                                                //         title:
                                                                //             'Name Start X',
                                                                //         hint:
                                                                //             'Width (mm)',
                                                                //         controller:
                                                                //             nameStartXC,
                                                                //         theme:
                                                                //             theme,
                                                                //       ),
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Label Width',
                                                                        hint:
                                                                            'Width (mm)',
                                                                        controller:
                                                                            widthC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Label Height',
                                                                        hint:
                                                                            'Height (mm)',
                                                                        controller:
                                                                            heightC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Left Margin Position',
                                                                        hint:
                                                                            'Left Margin (mm)',
                                                                        controller:
                                                                            startX,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Top Margin Position',
                                                                        hint:
                                                                            'Top Margin (mm)',
                                                                        controller:
                                                                            startY,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Sticker Gap',
                                                                        hint:
                                                                            'Gap (mm)',
                                                                        controller:
                                                                            gapC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Barcode height',
                                                                        hint:
                                                                            'Height (mm)',
                                                                        controller:
                                                                            barcodeHeightC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Barcode Scale',
                                                                        hint:
                                                                            'Scale (mm)',
                                                                        controller:
                                                                            barcodeScaleC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Vertical Spacing',
                                                                        hint:
                                                                            'spacing (mm)',
                                                                        controller:
                                                                            verticalSpacingC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          } else if (returnData().barcodeGeneratingIndex ==
                                                              1) {
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize.min,
                                                              spacing:
                                                                  10,
                                                              children: [
                                                                SizedBox(
                                                                  height:
                                                                      20,
                                                                ),
                                                                // Row(
                                                                //   mainAxisAlignment:
                                                                //       MainAxisAlignment.spaceBetween,
                                                                //   spacing:
                                                                //       10,
                                                                //   children: [
                                                                //     Expanded(
                                                                //       child: EditCartTextField(
                                                                //         title:
                                                                //             'Label Width',
                                                                //         hint:
                                                                //             'Width (mm)',
                                                                //         controller:
                                                                //             labelWidthPrice,
                                                                //         theme:
                                                                //             theme,
                                                                //       ),
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Label Width',
                                                                        hint:
                                                                            'Width (mm)',
                                                                        controller:
                                                                            labelWidthPrice,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Top Margin Position',
                                                                        hint:
                                                                            'Top Margin (mm)',
                                                                        controller:
                                                                            startPricePriceY,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Sticker Gap',
                                                                        hint:
                                                                            'Gap (mm)',
                                                                        controller:
                                                                            gapPriceC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Vertical Spacing',
                                                                        hint:
                                                                            'spacing (mm)',
                                                                        controller:
                                                                            verticalSpacingPriceC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          } else {
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize.min,
                                                              spacing:
                                                                  10,
                                                              children: [
                                                                SizedBox(
                                                                  height:
                                                                      20,
                                                                ),
                                                                // Row(
                                                                //   mainAxisAlignment:
                                                                //       MainAxisAlignment.spaceBetween,
                                                                //   spacing:
                                                                //       10,
                                                                //   children: [
                                                                //     Expanded(
                                                                //       child: EditCartTextField(
                                                                //         title:
                                                                //             'Name Start X',
                                                                //         hint:
                                                                //             'Width (mm)',
                                                                //         controller:
                                                                //             nameStartXC,
                                                                //         theme:
                                                                //             theme,
                                                                //       ),
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Label Width',
                                                                        hint:
                                                                            'Width (mm)',
                                                                        controller:
                                                                            widthPriceAndBarcodeC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Label Height',
                                                                        hint:
                                                                            'Height (mm)',
                                                                        controller:
                                                                            heightPriceAndBarcodeC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Left Margin Position',
                                                                        hint:
                                                                            'Left Margin (mm)',
                                                                        controller:
                                                                            startXPriceAndBarcode,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Top Margin Position',
                                                                        hint:
                                                                            'Top Margin (mm)',
                                                                        controller:
                                                                            startYPriceAndBarcode,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Sticker Gap',
                                                                        hint:
                                                                            'Gap (mm)',
                                                                        controller:
                                                                            gapPriceAndBarcodeC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Barcode height',
                                                                        hint:
                                                                            'Height (mm)',
                                                                        controller:
                                                                            barcodeHeightPriceAndBarcodeC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                  spacing:
                                                                      10,
                                                                  children: [
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Barcode Scale',
                                                                        hint:
                                                                            'Scale (mm)',
                                                                        controller:
                                                                            barcodeScalePriceAndBarcodeC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: EditCartTextField(
                                                                        title:
                                                                            'Vertical Spacing',
                                                                        hint:
                                                                            'spacing (mm)',
                                                                        controller:
                                                                            verticalSpacingPriceAndBarcodeC,
                                                                        theme:
                                                                            theme,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        },
                                                      ),
                                                      actionButtonText:
                                                          'Update Printer',
                                                    );
                                                  },
                                                );
                                              },
                                              child: SizedBox(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(
                                                        5,
                                                      ),
                                                  child: Icon(
                                                    size:
                                                        16,
                                                    color:
                                                        Colors.grey,
                                                    Icons
                                                        .edit,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Divider(height: 10),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  children:
                                      returnShopProvider(
                                            context:
                                                context,
                                          ).printers
                                          .where(
                                            (print) =>
                                                print
                                                    .name !=
                                                returnShopProvider(
                                                  context:
                                                      context,
                                                ).printerCache?.name,
                                          )
                                          .map(
                                            (
                                              printer,
                                            ) => Padding(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                    vertical:
                                                        3,
                                                  ),
                                              child: Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    color: Color.fromARGB(
                                                      110,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                  ),
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    onTap: () async {
                                                      await returnShopProvider().selectPrinter(
                                                        printer,
                                                        context,
                                                      );
                                                      setState(
                                                        () {},
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(
                                                        vertical:
                                                            12,
                                                        horizontal:
                                                            15,
                                                      ),

                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              spacing:
                                                                  2,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b4.fontSize,
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                  ),
                                                                  printer.name,
                                                                ),
                                                                Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b4.fontSize,
                                                                    fontWeight:
                                                                        FontWeight.normal,
                                                                  ),
                                                                  printer.driverName,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                              SizedBox(height: 10),
                              MainButtonP(
                                themeProvider: theme,
                                action: () async {
                                  if (returnData()
                                      .barcodeGenerationList
                                      .isNotEmpty) {
                                    if (returnShopProvider()
                                            .printerCache !=
                                        null) {
                                      showDialog(
                                        context: context,
                                        builder: (
                                          firstContext,
                                        ) {
                                          return ConfirmationAlert(
                                            theme: theme,
                                            message:
                                                'You are about to regenerate and print the barcode of this item(s), are you sure you want to proceed?',
                                            actionButtonText:
                                                'Generate',
                                            title:
                                                'Generate Multiple Barcode?',
                                            action: () async {
                                              Navigator.of(
                                                firstContext,
                                              ).pop();

                                              var res = await generateBarcodeAndPrint(
                                                context,
                                                returnData()
                                                    .barcodeGenerationList,
                                                false,
                                              );

                                              if (res &&
                                                  context
                                                      .mounted) {
                                                returnData()
                                                    .clearBarcodeGenerationList();
                                              }

                                              print(
                                                'Generate Clicked',
                                              );
                                            },
                                          );
                                        },
                                      );
                                    } else {}
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'Please one or more items to continue.',
                                          title:
                                              'Items Not Selected',
                                        );
                                      },
                                    );
                                  }
                                },
                                text:
                                    'Generate ${returnData(context: context).barcodeGeneratingIndex == 1 ? 'Price' : 'Barcode(s)'}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
