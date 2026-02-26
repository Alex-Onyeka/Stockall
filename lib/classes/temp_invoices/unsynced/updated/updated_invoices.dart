import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
part 'updated_invoices.g.dart';

@HiveType(typeId: 11)
class UpdatedInvoices extends HiveObject {
  @HiveField(0)
  TempInvoice updatedInvoice;

  UpdatedInvoices({required this.updatedInvoice});
}
