import 'dart:typed_data';

import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/constants_main.dart' show shopRef;
import 'package:stockall/main.dart' show returnShopProvider;
import 'package:stockall/services/documents/a4_document_pdf.dart';
import 'package:stockall/services/documents/document_mappers.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';
import 'package:stockall/services/documents/pdf_document_kit.dart';
import 'package:universal_html/html.dart' as html;

// What the download buttons call: the right mapper for each document,
// the shop's details and the A4 PDF. Only DocShopAssets.current() reads
// app state; everything else takes its inputs.

// The shop's logo and reference, as the current prints read them.
class DocShopAssets {
  final Uint8List? logo;
  final bool logoIsWide;
  final String? reference;

  const DocShopAssets({this.logo, this.logoIsWide = false, this.reference});

  factory DocShopAssets.current() {
    final provider = returnShopProvider();
    return DocShopAssets(
      logo: provider.selectedLogo,
      logoIsWide:
          (provider.imageWidth ?? 0) > 2 * (provider.imageHeight ?? 0),
      reference: shopRef(),
    );
  }
}

DocFormat docFormatFor(TempShopClass shop) =>
    DocFormat(currency: shop.currency);

DocShop _shop(TempShopClass shop, DocShopAssets assets) => docShopFrom(
  shop,
  logo: assets.logo,
  logoIsWide: assets.logoIsWide,
  reference: assets.reference,
);

SalesDocument receiptDownloadDocument({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required DocShopAssets assets,
}) => receiptDocument(
  receipt: receipt,
  records: records,
  staffName: staffName,
  shop: _shop(shop, assets),
  fmt: docFormatFor(shop),
  footerText: shop.bottomText,
);

SalesDocument invoiceDownloadDocument({
  required TempInvoice invoice,
  required List<TempProductSaleRecord> records,
  required List<TempMainReceipt> receipts,
  required String staffName,
  required TempShopClass shop,
  required DocShopAssets assets,
}) => invoiceDocument(
  invoice: invoice,
  records: records,
  receipts: receipts,
  staffName: staffName,
  shop: _shop(shop, assets),
  fmt: docFormatFor(shop),
  footerText: shop.bottomText,
);

SalesDocument orderDownloadDocument({
  required Orders order,
  required List<TempMainReceipt> receipts,
  required TempShopClass shop,
  required DocShopAssets assets,
  List<OrderItems>? items,
}) => orderDocument(
  order: order,
  items: items,
  receipts: receipts,
  shop: _shop(shop, assets),
  fmt: docFormatFor(shop),
  footerText: shop.bottomText,
);

SalesDocument purchaseDownloadDocument({
  required TempPurchase purchase,
  required List<TempItemPurchaseRecord> items,
  required TempShopClass shop,
  required DocShopAssets assets,
}) => purchaseDocument(
  purchase: purchase,
  items: items,
  shop: _shop(shop, assets),
  fmt: docFormatFor(shop),
  footerText: shop.bottomText,
);

Future<Uint8List> salesDocumentA4Pdf(
  SalesDocument doc,
  TempShopClass shop, {
  DocFonts? fonts,
}) => buildA4DocumentPdf(doc, docFormatFor(shop), fonts: fonts);

// "downloaded_order_31112.1730000000000", without the extension, as the
// receipt, invoice and purchase downloads name theirs on mobile and
// desktop (the save and share helpers add ".pdf").
String documentDownloadName(DocType type, String? uuid, DateTime at) {
  final id = uuid ?? '';
  final short = id.length > 5 ? id.substring(0, 5) : id;
  return 'downloaded_${type.name}_$short.${at.millisecondsSinceEpoch}';
}

// "downloaded_order_1730000000000.pdf", as the other web downloads.
String documentWebDownloadName(DocType type, DateTime at) =>
    'downloaded_${type.name}_${at.millisecondsSinceEpoch}.pdf';

// Downloads PDF bytes in the browser.
void downloadPdfBytesWeb(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor =
      html.AnchorElement(href: url)
        ..download = filename
        ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
