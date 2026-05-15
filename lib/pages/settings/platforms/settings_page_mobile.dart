import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/discount_setter.dart/discount_setter_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/multiple_stores_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/categories/categories_page.dart';
import 'package:stockall/pages/departments/departments_dashboard.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/settings/components/manage_departments_toggle_switch.dart';
import 'package:stockall/pages/settings/components/manage_inventory_switch_toggle.dart';
import 'package:stockall/pages/settings/components/set_closing_time.dart';
import 'package:stockall/pages/settings/components/toggle_bulk_sale.dart';
import 'package:stockall/pages/settings/components/toggle_whole_sale_switch.dart';
import 'package:stockall/pages/settings/components/use_group_unit_toggle.dart';
import 'package:stockall/pages/settings/settings_page.dart';
import 'package:stockall/pages/shop_setup/edit_receipt_page/edit_receipt.dart';
import 'package:stockall/pages/shop_setup/shop_dashboard/shop_dashboard.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';
import 'package:stockall/pages/sub_staffs/sub_staffs_page.dart';
import 'package:stockall/pages/subscription_page/subscription_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() =>
      _SettingsPageMobileState();
}

class _SettingsPageMobileState
    extends State<SettingsPageMobile> {
  final passwordController = TextEditingController();
  final productSearch = TextEditingController();
  final discountPercentController = TextEditingController();
  bool isLoading = false;
  bool isChangePlanLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'General Settings',
            backAction: () {
              Navigator.of(context).pop();
            },
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      // spacing: 10,
                      children: [
                        NavListTileDesktopAlt(
                          title: 'Account',
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ProfilePage();
                                },
                              ),
                            );
                          },
                          height: 18,
                          icon: Icons.person,
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().manageShop,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ShopPage();
                                  },
                                ),
                              );
                            },
                            title: 'Manage Shop',
                            icon: Icons.home_filled,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .manageShopDashboard,
                          ),
                          child: SubWrapper(
                            isVisible:
                                !MultipleStoresAuthAction()
                                    .manageShopDashboardAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () async {
                                bool isOnline =
                                    await ConnectivityProvider()
                                        .isOnline();
                                if (isOnline) {
                                  MultipleStoresAuthAction()
                                      .manageShopDashboardAction(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return ShopDashboard();
                                              },
                                            ),
                                          );
                                        },
                                      );
                                } else {
                                  showDialog(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'You need to turn on your internet connecting to access this page.',
                                        title:
                                            'Internet Required',
                                      );
                                    },
                                  );
                                }
                              },
                              title: 'Stores Dashboard',
                              icon:
                                  Icons
                                      .space_dashboard_outlined,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().manageShop,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              setStoreAsHeadquarters(
                                context,
                              );
                            },
                            title:
                                'Set Business Head Quarter',
                            icon:
                                Icons
                                    .settings_suggest_outlined,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .generalDiscount,
                          ),
                          child: SubWrapper(
                            isVisible:
                                !SalesAuthAction()
                                    .applyDiscountAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                SalesAuthAction().applyDiscountAction(
                                  context: context,
                                  action: () {
                                    showDialog(
                                      context: context,
                                      builder: (
                                        confirmDialog,
                                      ) {
                                        bool
                                        isDiscountLoading =
                                            false;
                                        return StatefulBuilder(
                                          builder: (
                                            context,
                                            setState,
                                          ) {
                                            return DialogTemplate(
                                              showTopSection:
                                                  returnShopProvider().userShop()!.fixedDiscount ==
                                                              null &&
                                                          returnShopProvider().userShop()!.percentDiscount ==
                                                              null
                                                      ? null
                                                      : false,
                                              showBottomActionButtons:
                                                  returnShopProvider().userShop()!.fixedDiscount ==
                                                              null &&
                                                          returnShopProvider().userShop()!.percentDiscount ==
                                                              null
                                                      ? null
                                                      : false,
                                              theme: theme,
                                              message:
                                                  'Set General Discount',
                                              title:
                                                  'Set General Discount',
                                              action: () async {
                                                var fixedDiscount =
                                                    returnShopProvider()
                                                        .generalFixedDiscount;
                                                var percentDiscount =
                                                    returnShopProvider()
                                                        .generalPercentDiscount;
                                                if (!isDiscountLoading) {
                                                  if (fixedDiscount ==
                                                          null &&
                                                      percentDiscount ==
                                                          null &&
                                                      discountPercentController
                                                          .text
                                                          .isEmpty) {
                                                    showDialog(
                                                      context:
                                                          context,
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return InfoAlert(
                                                          theme:
                                                              theme,
                                                          message:
                                                              'You have to select or enter a number in the text field before setting discount.',
                                                          title:
                                                              'Empty Discount',
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    showDialog(
                                                      context:
                                                          context,
                                                      builder: (
                                                        mainDialog,
                                                      ) {
                                                        return ConfirmationAlert(
                                                          theme:
                                                              theme,
                                                          message:
                                                              'Are you sure you want to proceed to set general discount?',
                                                          title:
                                                              'Proceed with action?',
                                                          action: () async {
                                                            Navigator.of(
                                                              mainDialog,
                                                            ).pop();
                                                            if (returnShopProvider().discountIndex ==
                                                                0) {
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      true;
                                                                },
                                                              );
                                                              await returnShopProvider().setPercentDiscount(
                                                                discount:
                                                                    returnShopProvider().generalPercentDiscount ??
                                                                    double.parse(
                                                                      discountPercentController.text,
                                                                    ),
                                                              );
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      false;
                                                                },
                                                              );
                                                            } else {
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      true;
                                                                },
                                                              );
                                                              await returnShopProvider().setFixedDiscount(
                                                                discount:
                                                                    returnShopProvider().generalFixedDiscount ??
                                                                    double.parse(
                                                                      discountPercentController.text,
                                                                    ),
                                                              );
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      false;
                                                                },
                                                              );
                                                            }
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              },
                                              widget: Stack(
                                                alignment:
                                                    AlignmentGeometry.xy(
                                                      0,
                                                      0,
                                                    ),
                                                children: [
                                                  Visibility(
                                                    visible:
                                                        returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).userShop()?.fixedDiscount ==
                                                            null &&
                                                        returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).userShop()?.percentDiscount ==
                                                            null,
                                                    child: Stack(
                                                      children: [
                                                        DiscountSetterBody(
                                                          addListener:
                                                              () {},
                                                          removeListener:
                                                              () {},
                                                          isGeneral:
                                                              true,
                                                          discountPercentController:
                                                              discountPercentController,
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              isDiscountLoading,
                                                          child: ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth:
                                                                  500,
                                                            ),
                                                            child: Container(
                                                              color: const Color.fromARGB(
                                                                47,
                                                                255,
                                                                255,
                                                                255,
                                                              ),
                                                              height:
                                                                  180,
                                                              width:
                                                                  500,
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).userShop()?.fixedDiscount !=
                                                            null ||
                                                        returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).userShop()?.percentDiscount !=
                                                            null,
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth:
                                                            500,
                                                      ),
                                                      child: Stack(
                                                        alignment: AlignmentGeometry.xy(
                                                          0,
                                                          0,
                                                        ),
                                                        children: [
                                                          Container(
                                                            color: const Color.fromARGB(
                                                              47,
                                                              255,
                                                              255,
                                                              255,
                                                            ),
                                                            height:
                                                                250,
                                                            width:
                                                                500,
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                mainAxisSize:
                                                                    MainAxisSize.min,
                                                                spacing:
                                                                    10,
                                                                children: [
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b1.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                    'Current Discount Applied',
                                                                  ),
                                                                  Container(
                                                                    height:
                                                                        3,
                                                                    width:
                                                                        200,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                      color:
                                                                          theme.lightModeColor.secColor200,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10,
                                                                  ),
                                                                  Row(
                                                                    spacing:
                                                                        5,
                                                                    mainAxisSize:
                                                                        MainAxisSize.min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment.center,
                                                                    children: [
                                                                      Icon(
                                                                        size:
                                                                            20,
                                                                        color:
                                                                            theme.lightModeColor.secColor200,
                                                                        Icons.discount,
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                theme.mobileTexts.h1.fontSize,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          "${returnShopProvider().userShop()!.fixedDiscount == null ? '%' : ''}${returnShopProvider().userShop()!.percentDiscount ?? formatMoneyMid(amount: returnShopProvider().userShop()!.fixedDiscount ?? 0, context: context)} ",
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        300,
                                                                    child: MainButtonP(
                                                                      themeProvider:
                                                                          theme,
                                                                      action: () async {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (
                                                                            clearDiscountDialog,
                                                                          ) {
                                                                            return ConfirmationAlert(
                                                                              theme:
                                                                                  theme,
                                                                              message:
                                                                                  'Are you sure you want to clear your current applied discount?',
                                                                              title:
                                                                                  'Clear Discount?',
                                                                              action: () async {
                                                                                setState(
                                                                                  () {
                                                                                    isDiscountLoading =
                                                                                        true;
                                                                                  },
                                                                                );
                                                                                Navigator.of(
                                                                                  clearDiscountDialog,
                                                                                ).pop();
                                                                                await returnShopProvider().setPercentDiscount(
                                                                                  discount:
                                                                                      null,
                                                                                );
                                                                                setState(
                                                                                  () {
                                                                                    isDiscountLoading =
                                                                                        false;
                                                                                  },
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      text:
                                                                          'Clear Discount',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        300,
                                                                    child: MainButtonTransparent(
                                                                      themeProvider:
                                                                          theme,
                                                                      constraints:
                                                                          BoxConstraints(),
                                                                      text:
                                                                          'Cancel',
                                                                      action: () {
                                                                        Navigator.of(
                                                                          confirmDialog,
                                                                        ).pop();
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible:
                                                                isDiscountLoading,
                                                            child: Container(
                                                              height:
                                                                  200,
                                                              width:
                                                                  300,
                                                              decoration: BoxDecoration(
                                                                color: const Color.fromARGB(
                                                                  61,
                                                                  255,
                                                                  255,
                                                                  255,
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ).then((_) {
                                      returnShopProvider()
                                          .clearDiscountsCache();
                                      discountPercentController
                                          .clear();
                                    });
                                  },
                                );
                              },
                              title: 'Manage Discount',
                              icon: Icons.discount,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().manageVAT,
                          ),
                          child: SubWrapper(
                            isVisible:
                                !GeneralSettingsAuthAction()
                                    .manageVATAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                GeneralSettingsAuthAction().manageVATAction(
                                  context: context,
                                  action: () {
                                    var shopProvider =
                                        returnShopProvider();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmationAlert(
                                          theme: theme,
                                          message:
                                              shopProvider
                                                      .userShop()!
                                                      .applyVAT!
                                                  ? 'VAT of 7% will not be applied to your subsequent sales, are you sure you want to proceed?'
                                                  : 'VAT of 7% will be added to your subsequent sales, are you sure you want to proceed?',
                                          title:
                                              shopProvider
                                                      .userShop()!
                                                      .applyVAT!
                                                  ? 'Remove VAT'
                                                  : 'Apply VAT',
                                          action: () async {
                                            Navigator.of(
                                              context,
                                            ).pop();
                                            shopProvider
                                                .toggleApplyVAT();
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              endWidget: Builder(
                                builder: (context) {
                                  if (returnShopProvider(
                                    context: context,
                                  ).isVatLoading) {
                                    return SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color:
                                            theme
                                                .lightModeColor
                                                .secColor200,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  } else {
                                    return MyToggleButton(
                                      isSmall: true,
                                      boolValue:
                                          returnShopProvider(
                                                context:
                                                    context,
                                              )
                                              .userShop()
                                              ?.applyVAT ??
                                          true,
                                      toggle: () {
                                        GeneralSettingsAuthAction().manageVATAction(
                                          context: context,
                                          action: () {
                                            var shopProvider =
                                                returnShopProvider();
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                context,
                                              ) {
                                                return ConfirmationAlert(
                                                  theme:
                                                      theme,
                                                  message:
                                                      shopProvider.userShop()!.applyVAT!
                                                          ? 'VAT of 7% will not be applied to your subsequent sales, are you sure you want to proceed?'
                                                          : 'VAT of 7% will be added to your subsequent sales, are you sure you want to proceed?',
                                                  title:
                                                      shopProvider.userShop()!.applyVAT!
                                                          ? 'Remove VAT'
                                                          : 'Apply VAT',
                                                  action: () async {
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                    shopProvider
                                                        .toggleApplyVAT();
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      theme: theme,
                                    );
                                  }
                                },
                              ),
                              title: 'Manage VAT ( $vat )',
                              icon: Icons.percent,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .updateProduct,
                          ),

                          child: SubWrapper(
                            isVisible:
                                !ItemsAuthAction()
                                    .applyVariationsAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                ItemsAuthAction()
                                    .applyVariationsAction(
                                      context: context,
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return CategoriesPage();
                                            },
                                          ),
                                        );
                                      },
                                    );
                              },
                              title: 'Manage Categories',
                              icon: Icons.category_outlined,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              !authorization(
                                authorized:
                                    Authorizations()
                                        .viewAllDepartments,
                              ),
                          child: SubWrapper(
                            isVisible:
                                !GeneralSettingsAuthAction()
                                    .manageDeparmtmentsAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                GeneralSettingsAuthAction().manageDeparmtmentsAction(
                                  context: context,
                                  action: () {
                                    String? selectedDept;
                                    setState(() {
                                      selectedDept =
                                          returnDepartmentProvider()
                                              .currentDepartment()
                                              ?.uuid;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (
                                        firstContext,
                                      ) {
                                        return StatefulBuilder(
                                          builder: (
                                            secondContext,
                                            setState,
                                          ) {
                                            return DialogTemplate(
                                              theme: theme,
                                              message:
                                                  'Select Your Current Department',
                                              title:
                                                  'Select Department',
                                              action: () {
                                                if (selectedDept !=
                                                    null) {
                                                  returnDepartmentProvider().selectDepartment(
                                                    departmentClass: returnDepartmentProvider().departments.firstWhere(
                                                      (
                                                        dept,
                                                      ) =>
                                                          dept.uuid ==
                                                          selectedDept,
                                                    ),
                                                  );
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              },
                                              widget: SizedBox(
                                                height:
                                                    screenHeight(
                                                      context,
                                                    ) -
                                                    300,
                                                child: SingleChildScrollView(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal:
                                                          20.0,
                                                      vertical:
                                                          15,
                                                    ),
                                                    child: Builder(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        if (returnDepartmentProvider().departments.isEmpty) {
                                                          return SizedBox(
                                                            height:
                                                                400,
                                                            child: EmptyWidgetDisplayOnly(
                                                              title:
                                                                  'No Department Found',
                                                              subText:
                                                                  'You have not been added to any departments.',
                                                              theme:
                                                                  theme,
                                                              height:
                                                                  30,
                                                              altAction: () {
                                                                returnDepartmentProvider().getDepartments();
                                                              },
                                                              altActionText:
                                                                  'Refresh',
                                                              icon:
                                                                  Icons.clear,
                                                            ),
                                                          );
                                                        } else {
                                                          return Column(
                                                            spacing:
                                                                5,
                                                            children:
                                                                returnDepartmentProvider().departments
                                                                    .map(
                                                                      (
                                                                        dept,
                                                                      ) => Material(
                                                                        color:
                                                                            Colors.transparent,
                                                                        child: InkWell(
                                                                          onTap: () {
                                                                            setState(
                                                                              () {
                                                                                if (returnDepartmentProvider().departments.length >
                                                                                    1) {
                                                                                  setState(
                                                                                    () {
                                                                                      selectedDept =
                                                                                          dept.uuid;
                                                                                    },
                                                                                  );
                                                                                }
                                                                              },
                                                                            );
                                                                          },
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  9.0,
                                                                              horizontal:
                                                                                  12,
                                                                            ),
                                                                            child: Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  style: TextStyle(
                                                                                    fontSize:
                                                                                        theme.mobileTexts.b3.fontSize,
                                                                                    fontWeight:
                                                                                        FontWeight.bold,
                                                                                  ),
                                                                                  dept.name,
                                                                                ),
                                                                                Container(
                                                                                  padding: EdgeInsets.all(
                                                                                    2,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    shape:
                                                                                        BoxShape.circle,
                                                                                    border: Border.all(
                                                                                      color:
                                                                                          Colors.grey,
                                                                                    ),
                                                                                  ),
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.all(
                                                                                      5,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      shape:
                                                                                          BoxShape.circle,
                                                                                      color:
                                                                                          selectedDept ==
                                                                                                  dept.uuid
                                                                                              ? theme.lightModeColor.prColor250
                                                                                              : Colors.transparent,
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
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              title: 'Manage Departments',
                              icon:
                                  Icons
                                      .width_normal_outlined,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .editReceiptTemplate,
                          ),

                          child: SubWrapper(
                            isVisible:
                                !GeneralSettingsAuthAction()
                                    .customizeReceiptTemplateAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                GeneralSettingsAuthAction()
                                    .customizeReceiptTemplateAction(
                                      context: context,
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return EditReceipt();
                                            },
                                          ),
                                        );
                                      },
                                    );
                              },
                              title:
                                  'Edit Receipt Template',
                              icon: Icons.receipt,
                            ),
                          ),
                        ),
                        ManageInventoryToggleSwitch(),
                        UseGroupUnitToggle(),
                        ToggleWholeSaleSwitch(),
                        ManageDepartmentsToggleSwitch(),
                        // FloatingButtonToggleSwitch(),
                        SetClosingTime(),
                        Visibility(
                          visible:
                              authorization(
                                authorized:
                                    Authorizations()
                                        .manageShop,
                              ) &&
                              shop(
                                    context,
                                  )?.manageDepartments ==
                                  true,
                          child: SubWrapper(
                            isVisible:
                                !GeneralSettingsAuthAction()
                                    .manageDeparmtmentsAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                GeneralSettingsAuthAction()
                                    .manageDeparmtmentsAction(
                                      context: context,
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return DepartmentsDashboard();
                                            },
                                          ),
                                        );
                                      },
                                    );
                              },
                              title: 'View Departments',
                              icon:
                                  Icons
                                      .width_normal_outlined,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .generateBarcode,
                          ),
                          child: SubWrapper(
                            isVisible:
                                !ItemsAuthAction()
                                    .generateBarcodeAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                ItemsAuthAction()
                                    .generateBarcodeAction(
                                      context: context,
                                      action: () {
                                        settingsGenerateProductBarcode(
                                          context,
                                          productSearch,
                                        );
                                      },
                                    );
                              },
                              title:
                                  'Generate Product Barcode',
                              icon: Icons.qr_code_rounded,
                            ),
                          ),
                        ),
                        ToggleBulkSale(),
                        Visibility(
                          visible:
                              shop(context)!.bulkSale ==
                                  true &&
                              authorization(
                                authorized:
                                    Authorizations()
                                        .manageSubStaff,
                              ) &&
                              subPlans
                                  .firstWhere(
                                    (plan) =>
                                        plan.plan ==
                                        returnSubcsription(
                                              context,
                                            )
                                            .subscription
                                            ?.plan,
                                  )
                                  .salesAuth
                                  .bulkSale,
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SubStaffsPage();
                                  },
                                ),
                              );
                            },
                            title: 'Manage Sub Staffs',
                            icon:
                                Icons
                                    .people_outline_outlined,
                          ),
                        ),
                        // NavListTileDesktopAlt(
                        //   height: 18,
                        //   action: () {
                        //     returnSubcsription(
                        //       context,
                        //       listen: false,
                        //     ).select(
                        //       returnSubcsription(
                        //             context,
                        //             listen: false,
                        //           ).subscription?.plan ??
                        //           0,
                        //     );
                        //     showDialog(
                        //       context: context,
                        //       builder: (confirmDialog) {
                        //         return StatefulBuilder(
                        //           builder:
                        //               (
                        //                 context,
                        //                 setState,
                        //               ) => DialogTemplate(
                        //                 theme: theme,
                        //                 message:
                        //                     'Select Another Subcription Plan',
                        //                 title:
                        //                     'Select Plan',
                        //                 action: () async {
                        //                   if (!isChangePlanLoading) {
                        //                     setState(() {
                        //                       isChangePlanLoading =
                        //                           true;
                        //                     });
                        //                     await returnSubcsription(
                        //                       context,
                        //                       listen: false,
                        //                     ).subscribe(
                        //                       plan:
                        //                           returnSubcsription(
                        //                             context,
                        //                             listen:
                        //                                 false,
                        //                           ).selected!,
                        //                       context:
                        //                           context,
                        //                     );
                        //                     returnData(
                        //                       // ignore: use_build_context_synchronously
                        //                       context,
                        //                       listen: false,
                        //                     ).setAllowedRange(
                        //                       // ignore: use_build_context_synchronously
                        //                       context:
                        //                           context,
                        //                       plan:
                        //                           returnSubcsription(
                        //                             // ignore: use_build_context_synchronously
                        //                             context,
                        //                             listen:
                        //                                 false,
                        //                           ).subscription?.plan,
                        //                     );
                        //                     if (confirmDialog
                        //                         .mounted) {
                        //                       Navigator.of(
                        //                         confirmDialog,
                        //                       ).pop();
                        //                     }
                        //                   }
                        //                 },
                        //                 widget: Column(
                        //                   spacing: 5,
                        //                   mainAxisSize:
                        //                       MainAxisSize
                        //                           .min,
                        //                   children:
                        //                       returnSubcsription(
                        //                         context,
                        //                       ).subs.map((
                        //                         sub,
                        //                       ) {
                        //                         return Material(
                        //                           type:
                        //                               MaterialType
                        //                                   .transparency,
                        //                           child: InkWell(
                        //                             onTap: () {
                        //                               returnSubcsription(
                        //                                 context,
                        //                                 listen:
                        //                                     false,
                        //                               ).select(
                        //                                 sub.plan,
                        //                               );
                        //                             },
                        //                             child: Container(
                        //                               decoration: BoxDecoration(
                        //                                 border: Border(
                        //                                   bottom: BorderSide(
                        //                                     color:
                        //                                         Colors.grey.shade100,
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                               child: Padding(
                        //                                 padding: const EdgeInsets.symmetric(
                        //                                   horizontal:
                        //                                       20.0,
                        //                                   vertical:
                        //                                       10,
                        //                                 ),
                        //                                 child: Column(
                        //                                   mainAxisSize:
                        //                                       MainAxisSize.min,
                        //                                   children: [
                        //                                     Row(
                        //                                       mainAxisAlignment:
                        //                                           MainAxisAlignment.spaceBetween,
                        //                                       children: [
                        //                                         Text(
                        //                                           style: TextStyle(
                        //                                             fontSize:
                        //                                                 theme.mobileTexts.b2.fontSize,
                        //                                           ),
                        //                                           sub.planName,
                        //                                         ),
                        //                                         Stack(
                        //                                           children: [
                        //                                             Visibility(
                        //                                               visible:
                        //                                                   !isChangePlanLoading,
                        //                                               child: Container(
                        //                                                 padding: EdgeInsets.all(
                        //                                                   2,
                        //                                                 ),
                        //                                                 decoration: BoxDecoration(
                        //                                                   shape:
                        //                                                       BoxShape.circle,
                        //                                                   border: Border.all(
                        //                                                     color:
                        //                                                         Colors.grey.shade300,
                        //                                                   ),
                        //                                                 ),
                        //                                                 child: Container(
                        //                                                   padding: EdgeInsets.all(
                        //                                                     6,
                        //                                                   ),
                        //                                                   decoration: BoxDecoration(
                        //                                                     shape:
                        //                                                         BoxShape.circle,
                        //                                                     color:
                        //                                                         returnSubcsription(
                        //                                                                   context,
                        //                                                                 ).selected ==
                        //                                                                 sub.plan
                        //                                                             ? theme.lightModeColor.prColor250
                        //                                                             : Colors.transparent,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                             ),
                        //                                             Visibility(
                        //                                               visible:
                        //                                                   isChangePlanLoading,
                        //                                               child: SizedBox(
                        //                                                 height:
                        //                                                     17,
                        //                                                 width:
                        //                                                     17,
                        //                                                 child: CircularProgressIndicator(
                        //                                                   strokeWidth:
                        //                                                       2,
                        //                                                   color:
                        //                                                       theme.lightModeColor.secColor200,
                        //                                                 ),
                        //                                               ),
                        //                                             ),
                        //                                           ],
                        //                                         ),
                        //                                       ],
                        //                                     ),
                        //                                   ],
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                           ),
                        //                         );
                        //                       }).toList(),
                        //                 ),
                        //               ),
                        //         );
                        //       },
                        //     ).then((_) {
                        //       setState(() {
                        //         isChangePlanLoading = false;
                        //       });
                        //     });
                        //   },
                        //   title: 'Change Subscription Plan',
                        //   icon:
                        //       Icons
                        //           .earbuds_battery_outlined,
                        // ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().manageShop,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SubscriptionPage();
                                  },
                                ),
                              ).then((_) {
                                if (context.mounted) {
                                  print(
                                    'Context is mounted',
                                  );
                                  setState(() {});
                                } else {
                                  print(
                                    'Context is not mounted',
                                  );
                                }
                              });
                            },
                            title: 'Manage Subscription',
                            icon:
                                Icons
                                    .workspace_premium_outlined,
                          ),
                        ),
                        NavListTileDesktopAlt(
                          height: 18,
                          action: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmationAlert(
                                  theme: theme,
                                  message:
                                      'You are about to download and install our official Native application, for better experience.',
                                  title:
                                      screenWidth(context) >
                                              tabletScreenSmall
                                          ? 'Proceed to Download Desktop App'
                                          : 'Proceed to Download Mobile App',
                                  action: () async {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                    await downloadApkFromApp(
                                      context: context,
                                    );
                                  },
                                );
                              },
                            );
                          },
                          title:
                              screenWidth(context) >
                                      tabletScreenSmall
                                  ? 'Download Desktop App'
                                  : 'Download Mobile App',
                          icon: Icons.download_outlined,
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .contactStockall,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () async {
                              phoneCall();
                            },
                            title:
                                'Call Us (+234 704 850 7587)',
                            icon: Icons.phone,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .contactStockall,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 14,
                            action: () async {
                              openWhatsApp();
                            },
                            title: 'Chat With Us',
                            svg: whatsappIconSvg,
                          ),
                        ),
                        NavListTileDesktopAlt(
                          height: 20,
                          action: () async {
                            await launchUrlMain(
                              "https://stockallsolution.com/help-center",
                            );
                          },
                          title: 'Visit Help Center',
                          icon: Icons.people_alt_outlined,
                        ),
                        NavListTileDesktopAlt(
                          height: 18,
                          action: () async {
                            await launchUrlMain(
                              "https://stockallsolution.com/privacy-policy",
                            );
                          },
                          title: 'Privacy P. & Terms/C.',
                          icon: Icons.menu_book_rounded,
                        ),
                        NavListTileDesktopAlt(
                          height: 18,
                          action: () async {
                            await launchUrlMain(
                              "https://stockallsolution.com",
                            );
                          },
                          title: 'Go to Website.',
                          icon: Icons.language_rounded,
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().deleteShop,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              var safeContext = context;
                              var shopP =
                                  returnShopProvider();
                              var userP =
                                  returnUserProvider(
                                    context,
                                    listen: false,
                                  );
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to delete an entire Store, with all its data. You will loose all the data of this store after this process. This Action can not be reversed. Are you sure you want to proceed?',
                                    title: 'Delete Shop?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      showDialog(
                                        context:
                                            safeContext,
                                        builder: (
                                          newDialog,
                                        ) {
                                          return DialogTemplate(
                                            theme: theme,
                                            message:
                                                'You have to enter your password to verify that you are the owner this shop, in other to delete',
                                            title:
                                                'Enter Password',
                                            action: () async {
                                              var password =
                                                  userP
                                                      .currentUserMain!
                                                      .password;
                                              if (passwordController
                                                  .text
                                                  .isEmpty) {
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return InfoAlert(
                                                      theme: returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ),
                                                      message:
                                                          'Password field cannot be empty. You must enter you password in the password field to proceed.',
                                                      title:
                                                          'Password Empty',
                                                    );
                                                  },
                                                );
                                                return;
                                              }
                                              if (password !=
                                                  passwordController
                                                      .text) {
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return InfoAlert(
                                                      theme: returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ),
                                                      message:
                                                          'The Password you entered is Incorrect. Please check the password and try again.',
                                                      title:
                                                          'Password Incorrect.',
                                                    );
                                                  },
                                                );
                                                return;
                                              }
                                              Navigator.of(
                                                newDialog,
                                              ).pop();
                                              setState(() {
                                                isLoading =
                                                    true;
                                              });
                                              var res = await shopP
                                                  .deleteShop(
                                                    context:
                                                        context,
                                                  );
                                              if (res ==
                                                  0) {
                                                setState(() {
                                                  isLoading =
                                                      false;
                                                });
                                              }
                                            },
                                            widget: SizedBox(
                                              width:
                                                  double
                                                      .infinity,
                                              child: EmailTextField(
                                                controller:
                                                    passwordController,
                                                theme:
                                                    theme,
                                                isEmail:
                                                    false,
                                                hint:
                                                    'Enter Password',
                                                title:
                                                    'Password',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            title: 'Delete Shop',
                            color: Colors.red,
                            icon:
                                Icons
                                    .delete_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    color: Colors.transparent,
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Row(
                            spacing: 10,
                            mainAxisAlignment:
                                MainAxisAlignment.start,
                            children: [
                              // SizedBox(
                              //   width: 20,
                              //   child: Center(),
                              // ),
                              Text(
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade900,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontStyle:
                                      FontStyle.italic,
                                ),
                                'Current Version:',
                              ),
                            ],
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                            appVersionMobile.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // SizedBox(
                  //   height: screenHeight(context) * 0.2,
                  // ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: 'Deleting Store'),
        ),
      ],
    );
  }
}
