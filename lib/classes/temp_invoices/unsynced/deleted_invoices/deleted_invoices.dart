import 'package:hive/hive.dart';
part 'deleted_invoices.g.dart';

@HiveType(typeId: 45)
class DeletedInvoices extends HiveObject {
  @HiveField(0)
  final String invoiceUuid;

  DeletedInvoices({required this.invoiceUuid});
}
