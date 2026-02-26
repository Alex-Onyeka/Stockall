import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
part 'created_invoices.g.dart';

@HiveType(typeId: 44)
class CreatedInvoices extends HiveObject {
  @HiveField(0)
  final TempInvoice invoice;

  CreatedInvoices({required this.invoice});
}
