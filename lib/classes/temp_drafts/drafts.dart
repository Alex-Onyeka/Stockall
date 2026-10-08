import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_drafts/draft_items.dart';

part 'drafts.g.dart';

@HiveType(typeId: 149)
class Drafts extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime? updatedAt;

  @HiveField(3)
  int shopId;

  @HiveField(4)
  String? staffId;

  @HiveField(5)
  String? staffName;

  @HiveField(6)
  String? subStaffUuid;

  @HiveField(7)
  String? subStaffName;

  @HiveField(8)
  String? customerUuid;

  @HiveField(9)
  String? customerName;

  @HiveField(10)
  String? departmentUuid;

  @HiveField(11)
  String? departmentName;

  @HiveField(12)
  String? cartName;

  @HiveField(13)
  String? comment;

  @HiveField(14)
  double? generalDiscount;

  @HiveField(15)
  double? fixedDiscount;

  @HiveField(16)
  double? total;

  @HiveField(17)
  List<DraftItems> draftItems;

  Drafts({
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    required this.shopId,
    required this.staffId,
    required this.staffName,
    required this.subStaffUuid,
    required this.subStaffName,
    required this.customerUuid,
    required this.customerName,
    required this.departmentUuid,
    required this.departmentName,
    required this.cartName,
    required this.comment,
    required this.generalDiscount,
    required this.fixedDiscount,
    required this.total,
    required this.draftItems,
  });

  factory Drafts.fromJson(Map<String, dynamic> json) {
    return Drafts(
      uuid: json['uuid'] as String?,
      createdAt:
          DateTime.parse(json['created_at']).toLocal(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(
                json['updated_at'] as String,
              ).toLocal()
              : null,
      shopId: json['shop_id'],
      staffId: json['staff_id'] as String?,
      staffName: json['staff_name'] as String?,
      subStaffUuid: json['sub_staff_uuid'] as String?,
      subStaffName: json['sub_staff_name'] as String?,
      customerUuid: json['customer_uuid'] as String?,
      customerName: json['customer_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      cartName: json['cart_name'] as String?,
      comment: json['comment'] as String?,
      generalDiscount:
          (json['general_discount'] as num?)?.toDouble(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      draftItems:
          (json['items'] as List<dynamic>? ?? [])
              .map(
                (e) => DraftItems.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'sub_staff_uuid': subStaffUuid,
      'sub_staff_name': subStaffName,
      'customer_uuid': customerUuid,
      'customer_name': customerName,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'cart_name': cartName,
      'comment': comment,
      'general_discount': generalDiscount,
      'fixed_discount': fixedDiscount,
      'total': total,
      'items': draftItems.map((e) => e.toJson()).toList(),
    };
  }

  Drafts copyWith({
    String? uuid,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? shopId,
    String? staffId,
    String? staffName,
    String? subStaffUuid,
    String? subStaffName,
    String? customerUuid,
    String? customerName,
    String? departmentUuid,
    String? departmentName,
    String? cartName,
    String? comment,
    double? generalDiscount,
    double? fixedDiscount,
    double? total,
    List<DraftItems>? draftItems,
  }) {
    return Drafts(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      subStaffUuid: subStaffUuid ?? this.subStaffUuid,
      subStaffName: subStaffName ?? this.subStaffName,
      customerUuid: customerUuid ?? this.customerUuid,
      customerName: customerName ?? this.customerName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      departmentName: departmentName ?? this.departmentName,
      cartName: cartName ?? this.cartName,
      comment: comment ?? this.comment,
      generalDiscount:
          generalDiscount ?? this.generalDiscount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      total: total ?? this.total,
      draftItems: draftItems ?? this.draftItems,
    );
  }

  // Non-voided items, for list display.
  int getItemCount() {
    return draftItems
        .where((item) => item.isVoid != true)
        .length;
  }
}
