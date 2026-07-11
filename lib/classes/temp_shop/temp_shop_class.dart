import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'temp_shop_class.g.dart';

@HiveType(typeId: 7)
class TempShopClass {
  @HiveField(0)
  final int? shopId;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String name;

  @HiveField(5)
  String? state;

  @HiveField(6)
  String? country;

  @HiveField(7)
  String? city;

  @HiveField(8)
  String? shopAddress;

  @HiveField(9)
  List<String>? categories;

  @HiveField(10)
  List<String>? colors;

  @HiveField(11)
  String? phoneNumber;

  @HiveField(12)
  String? activeEmployee;

  @HiveField(13)
  List<String>? employees;

  @HiveField(14)
  String? refCode;

  @HiveField(15)
  String currency;

  @HiveField(16)
  int? updateNumber;

  @HiveField(17)
  bool isVerified;

  @HiveField(18)
  int? printType;

  @HiveField(19)
  String? language;

  @HiveField(20)
  DateTime? updatedAt;

  @HiveField(23)
  String? instaHandle;

  @HiveField(24)
  String? faceBookHandle;

  @HiveField(25)
  bool? showEmail;

  @HiveField(26)
  bool? showPhone;

  @HiveField(27)
  bool? showAddress;

  @HiveField(28)
  bool? showInstaDown;

  @HiveField(29)
  bool? showFacebookDown;

  @HiveField(30)
  bool? showFirst;

  @HiveField(31)
  bool? showSecond;

  @HiveField(32)
  bool? showThird;

  @HiveField(33)
  bool? showInstaTop;

  @HiveField(34)
  bool? showFacebookTop;

  @HiveField(35)
  String? bottomText;

  @HiveField(36)
  bool? showShopName;

  @HiveField(37)
  String? logoUrl;

  @HiveField(38)
  int? imageHeight;

  @HiveField(39)
  int? imageWidth;

  @HiveField(40)
  bool? isHeadQuarters;

  @HiveField(41)
  double? percentDiscount;

  @HiveField(42)
  double? fixedDiscount;

  @HiveField(43)
  bool? isAllowedBySubscription;

  @HiveField(44)
  bool? applyVAT;

  @HiveField(45)
  bool? manageInventoryStorage;

  @HiveField(46)
  bool? bulkSale;

  @HiveField(47)
  bool? useGroupUnit;

  @HiveField(48)
  bool? wholeSale;

  @HiveField(49)
  bool? manageDepartments;

  @HiveField(50)
  bool? printSalesDocket;

  @HiveField(51)
  TimeOfDay? closeSaleTime;

  @HiveField(52)
  String? closeSaleTimeString;

  @HiveField(53)
  bool? trackCart;

  @HiveField(54)
  String? accessPin;

  // String? uuid

  TempShopClass({
    this.shopId,
    required this.createdAt,
    required this.userId,
    this.email,
    required this.name,
    this.state,
    this.city,
    this.shopAddress,
    this.categories,
    this.colors,
    this.country,
    this.activeEmployee,
    this.phoneNumber,
    this.employees,
    this.refCode,
    required this.currency,
    this.updateNumber,
    required this.isVerified,
    this.printType,
    this.language,
    this.updatedAt,
    // this.plan,
    // this.nextPayment,
    this.instaHandle,
    this.faceBookHandle,
    this.showEmail = true,
    this.showAddress = false,
    this.showFacebookDown = false,
    this.showInstaDown = false,
    this.showFirst = true,
    this.showSecond = true,
    this.showThird = true,
    this.showPhone = false,
    this.showFacebookTop = false,
    this.showInstaTop = false,
    this.showShopName = true,
    this.bottomText,
    this.logoUrl,
    this.imageHeight,
    this.imageWidth,
    this.isHeadQuarters,
    this.percentDiscount,
    this.fixedDiscount,
    this.isAllowedBySubscription,
    this.applyVAT,
    required this.manageInventoryStorage,
    this.bulkSale,
    required this.useGroupUnit,
    required this.wholeSale,
    required this.manageDepartments,
    required this.printSalesDocket,
    required this.closeSaleTimeString,
    this.closeSaleTime,
    required this.trackCart,
    required this.accessPin,
    // required this.uuid
  });

  factory TempShopClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempShopClass(
      shopId: json['shop_id'] as int?,
      // uuid: json['uuid'] as String?,
      country: json['country'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      userId: json['user_id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      state: json['state'] as String?,
      city: json['city'] as String?,
      shopAddress: json['shop_address'] as String?,
      categories:
          (json['categories'] as List?)?.cast<String>(),
      colors: (json['colors'] as List?)?.cast<String>(),
      activeEmployee: json['active_employee'] as String?,
      phoneNumber: json['phone_number'] as String?,
      employees:
          (json['employees'] as List?)?.cast<String>(),
      refCode: json['ref_code'] as String?,
      currency: json['currency'] as String,
      updateNumber: json['update_number'] as int?,
      isVerified: json['is_verified'] as bool,
      printType: json['print_type'] as int?,
      language: json['language'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      instaHandle: json['insta_handle'] as String?,
      faceBookHandle: json['facebook_handle'] as String?,
      showAddress: json['show_address'] as bool?,
      showEmail: json['show_email'] as bool?,
      showPhone: json['show_phone'] as bool?,
      showFirst: json['show_first'] as bool?,
      showSecond: json['show_second'] as bool?,
      showThird: json['show_third'] as bool?,
      showFacebookDown: json['show_facebook_down'] as bool?,
      showInstaDown: json['show_insta_down'] as bool?,
      showFacebookTop: json['show_facebook_top'] as bool?,
      showInstaTop: json['show_insta_top'] as bool?,
      bottomText: json['bottom_text'] as String?,
      showShopName: json['show_shop_name'] as bool?,
      logoUrl: json['logo_url'] as String?,
      imageHeight: json['image_height'] as int?,
      imageWidth: json['image_width'] as int?,
      isHeadQuarters: json['is_head_quarters'] as bool?,
      percentDiscount:
          (json['percent_discount'] as num?)?.toDouble(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      isAllowedBySubscription:
          json['is_allowed_by_subscription'] as bool?,
      applyVAT: json['apply_vat'] as bool?,
      manageInventoryStorage:
          json['manage_inventory_storage'] as bool?,
      bulkSale: json['bulk_sale'] as bool?,
      useGroupUnit: json['use_group_unit'] as bool?,
      wholeSale: json['whole_sale'] as bool?,
      manageDepartments:
          json['manage_departments'] as bool?,
      printSalesDocket: json['print_sales_docket'] as bool?,
      // closeSaleTime:
      //     json['close_sale_time'] != null
      //         ? parseTimeOfDay(json['close_sale_time'])
      //             as TimeOfDay?
      //         : null,
      closeSaleTimeString:
          json['close_sale_time'] as String?,
      trackCart: json['track_cart'] as bool?,
      accessPin: json['access_pin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'shop_id': shopId,
      // 'uuid': uuid
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'email': email,
      'name': name,
      'state': state,
      'city': city,
      'country': country,
      'shop_address': shopAddress,
      'categories': categories,
      'colors': colors,
      'phone_number': phoneNumber,
      'employees': employees,
      'ref_code': refCode,
      'currency': currency,
      'update_number': updateNumber,
      'is_verified': isVerified,
      'print_type': printType,
      'language': language,
      'updated_at': updatedAt?.toIso8601String(),
      // 'plan': plan,
      // 'next_payment': nextPayment?.toIso8601String(),
      'insta_handle': instaHandle,
      'facebook_handle': faceBookHandle,
      'show_shop_name': showShopName,
      'show_email': showEmail,
      'show_phone': showPhone,
      'show_address': showAddress,
      'show_insta_down': showInstaDown,
      'show_facebook_down': showFacebookDown,
      'show_insta_top': showInstaTop,
      'show_facebook_top': showFacebookTop,
      'show_first': showFirst,
      'show_second': showSecond,
      'show_third': showThird,
      'bottom_text': bottomText,
      'logo_url': logoUrl,
      'image_width': imageWidth,
      'image_height': imageHeight,
      'is_head_quarters': isHeadQuarters,
      'percent_discount': percentDiscount?.toDouble(),
      'fixed_discount': fixedDiscount?.toDouble(),
      'apply_vat': applyVAT,
      'manage_inventory_storage': manageInventoryStorage,
      'bulk_sale': bulkSale,
      'use_group_unit': useGroupUnit,
      'whole_sale': wholeSale,
      'manage_departments': manageDepartments,
      'print_sales_docket': printSalesDocket,
      // 'close_sale_time': closeSaleTime,
      'close_sale_time': closeSaleTimeString,
      'track_cart': trackCart,
      'access_pin': accessPin,
    };
  }

  TempShopClass copyWith({
    int? shopId,
    DateTime? createdAt,
    String? userId,
    String? email,
    String? name,
    String? state,
    String? country,
    String? city,
    String? shopAddress,
    List<String>? categories,
    List<String>? colors,
    String? phoneNumber,
    String? activeEmployee,
    List<String>? employees,
    String? refCode,
    String? currency,
    int? updateNumber,
    bool? isVerified,
    int? printType,
    String? language,
    DateTime? updatedAt,
    String? instaHandle,
    String? faceBookHandle,
    bool? showEmail,
    bool? showPhone,
    bool? showAddress,
    bool? showInstaDown,
    bool? showFacebookDown,
    bool? showFirst,
    bool? showSecond,
    bool? showThird,
    bool? showInstaTop,
    bool? showFacebookTop,
    String? bottomText,
    bool? showShopName,
    String? logoUrl,
    int? imageHeight,
    int? imageWidth,
    bool? isHeadQuarters,
    double? percentDiscount,
    double? fixedDiscount,
    bool? isAllowedBySubscription,
    bool? applyVAT,
    bool? manageInventoryStorage,
    bool? bulkSale,
    bool? useGroupUnit,
    bool? wholeSale,
    bool? manageDepartments,
    bool? printSalesDocket,
    TimeOfDay? closeSaleTime,
    String? closeSaleTimeString,
    bool? trackCart,
    String? accessPin,
    // String? uuid,
  }) {
    return TempShopClass(
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      state: state ?? this.state,
      country: country ?? this.country,
      city: city ?? this.city,
      shopAddress: shopAddress ?? this.shopAddress,
      categories: categories ?? this.categories,
      colors: colors ?? this.colors,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      activeEmployee: activeEmployee ?? this.activeEmployee,
      employees: employees ?? this.employees,
      refCode: refCode ?? this.refCode,
      currency: currency ?? this.currency,
      updateNumber: updateNumber ?? this.updateNumber,
      isVerified: isVerified ?? this.isVerified,
      printType: printType ?? this.printType,
      language: language ?? this.language,
      updatedAt: updatedAt ?? this.updatedAt,
      instaHandle: instaHandle ?? this.instaHandle,
      faceBookHandle: faceBookHandle ?? this.faceBookHandle,
      showEmail: showEmail ?? this.showEmail,
      showPhone: showPhone ?? this.showPhone,
      showAddress: showAddress ?? this.showAddress,
      showInstaDown: showInstaDown ?? this.showInstaDown,
      showFacebookDown:
          showFacebookDown ?? this.showFacebookDown,
      showFirst: showFirst ?? this.showFirst,
      showSecond: showSecond ?? this.showSecond,
      showThird: showThird ?? this.showThird,
      showInstaTop: showInstaTop ?? this.showInstaTop,
      showFacebookTop:
          showFacebookTop ?? this.showFacebookTop,
      bottomText: bottomText ?? this.bottomText,
      showShopName: showShopName ?? this.showShopName,
      logoUrl: logoUrl ?? this.logoUrl,
      imageHeight: imageHeight ?? this.imageHeight,
      imageWidth: imageWidth ?? this.imageWidth,
      isHeadQuarters: isHeadQuarters ?? this.isHeadQuarters,
      percentDiscount:
          percentDiscount ?? this.percentDiscount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      isAllowedBySubscription:
          isAllowedBySubscription ??
          this.isAllowedBySubscription,
      applyVAT: applyVAT ?? this.applyVAT,
      manageInventoryStorage:
          manageInventoryStorage ??
          this.manageInventoryStorage,
      bulkSale: bulkSale ?? this.bulkSale,
      useGroupUnit: useGroupUnit ?? this.useGroupUnit,
      wholeSale: wholeSale ?? this.wholeSale,
      manageDepartments:
          manageDepartments ?? this.manageDepartments,
      printSalesDocket:
          printSalesDocket ?? this.printSalesDocket,
      closeSaleTime: closeSaleTime ?? this.closeSaleTime,
      closeSaleTimeString:
          closeSaleTimeString ?? this.closeSaleTimeString,
      trackCart: trackCart ?? this.trackCart,
      accessPin: accessPin ?? this.accessPin,
      // uuid: uuid ?? this.uuid,
    );
  }
}
