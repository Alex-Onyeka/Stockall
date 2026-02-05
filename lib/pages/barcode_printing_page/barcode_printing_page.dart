import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_barcode_printer_class/printer_settings/printer_settings.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
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
                                              ).productList.where((
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
                                                        );
                                                        shopP.updatePrinterSettings(
                                                          newSettings,
                                                        );
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      widget: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        spacing:
                                                            10,
                                                        children: [
                                                          SizedBox(
                                                            height:
                                                                20,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            spacing:
                                                                10,
                                                            children: [
                                                              Expanded(
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Label Widgth',
                                                                  hint:
                                                                      'Width (mm)',
                                                                  controller:
                                                                      widthC,
                                                                  lines:
                                                                      1,
                                                                  theme:
                                                                      theme,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Label Height',
                                                                  hint:
                                                                      'Height (mm)',
                                                                  controller:
                                                                      heightC,
                                                                  lines:
                                                                      1,
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
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Start X Position',
                                                                  hint:
                                                                      'Start X (mm)',
                                                                  controller:
                                                                      startX,
                                                                  lines:
                                                                      1,
                                                                  theme:
                                                                      theme,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Start Y Position',
                                                                  hint:
                                                                      'Start Y (mm)',
                                                                  controller:
                                                                      startY,
                                                                  lines:
                                                                      1,
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
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Sticker Gap',
                                                                  hint:
                                                                      'Gap (mm)',
                                                                  controller:
                                                                      gapC,
                                                                  lines:
                                                                      1,
                                                                  theme:
                                                                      theme,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Barcode height',
                                                                  hint:
                                                                      'Height (mm)',
                                                                  controller:
                                                                      barcodeHeightC,
                                                                  lines:
                                                                      1,
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
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Barcode Scale',
                                                                  hint:
                                                                      'Scale (mm)',
                                                                  controller:
                                                                      barcodeScaleC,
                                                                  lines:
                                                                      1,
                                                                  theme:
                                                                      theme,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: GeneralTextField(
                                                                  title:
                                                                      'Vertical Spacing',
                                                                  hint:
                                                                      'spacing (mm)',
                                                                  controller:
                                                                      verticalSpacingC,
                                                                  lines:
                                                                      1,
                                                                  theme:
                                                                      theme,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
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
                                text: 'Generate Barcode(s)',
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
