import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';

// SalesDocument -> the sections of its A4 page, as text. Pure: the PDF
// kit draws whatever this returns, and tests read it directly.
//
// Page order: header, title, general information, Items band + table,
// totals (barcode on their left), Payments band + table, Notes band +
// text.

DocLayout salesDocumentLayout(SalesDocument doc, DocFormat fmt) {
  final sections = <DocSection>[
    DocHeaderSection(doc.shop),
    DocTitleSection(
      doc.title,
      subtitle: 'No. ${doc.number}',
      note: doc.titleLine,
      badge: doc.status?.label,
      badgeTone: _tone(doc.status),
    ),
    DocInfoBoxSection('General Information', doc.info),
    const DocBandSection('Items'),
    DocTableSection(
      _itemColumns(doc.type),
      [
        for (var i = 0; i < doc.lines.length; i++)
          _itemRow(doc.type, i + 1, doc.lines[i], fmt),
      ],
      emptyText: 'No items',
    ),
    DocTotalsSection(salesDocumentTotalRows(doc, fmt), barcode: doc.barcode),
    if (doc.payments.isNotEmpty) ...[
      const DocBandSection('Payments', dark: false),
      DocTableSection(
        _paymentColumns(doc.type),
        [for (final payment in doc.payments) _paymentRow(doc.type, payment, fmt)],
      ),
    ],
    if (doc.notes != null) ...[
      const DocBandSection('Notes', dark: false),
      DocTextSection(doc.notes!),
    ],
  ];
  return DocLayout(
    title: doc.title,
    sections: sections,
    footer: DocFooter(
      left: '${_titleCase(doc.title)} No. ${doc.number}',
      message: doc.footerText,
    ),
  );
}

List<DocColumn> _itemColumns(DocType type) {
  const number = DocColumn('#', flex: 1, align: DocAlign.center);
  const amount = DocColumn('Amount', flex: 4, align: DocAlign.right);
  switch (type) {
    case DocType.order:
      return const [
        number,
        DocColumn('Item', flex: 8),
        DocColumn('Ordered', flex: 3, align: DocAlign.right),
        DocColumn('Delivered', flex: 3, align: DocAlign.right),
        DocColumn('Outstanding', flex: 4, align: DocAlign.right),
        DocColumn('Unit price', flex: 4, align: DocAlign.right),
        amount,
      ];
    case DocType.purchase:
      return const [
        number,
        DocColumn('Item', flex: 11),
        DocColumn('Qty', flex: 4, align: DocAlign.right),
        DocColumn('Unit cost', flex: 4, align: DocAlign.right),
        amount,
      ];
    case DocType.receipt:
    case DocType.invoice:
      return const [
        number,
        DocColumn('Item', flex: 11),
        DocColumn('Qty', flex: 4, align: DocAlign.right),
        DocColumn('Unit price', flex: 4, align: DocAlign.right),
        amount,
      ];
  }
}

DocRow _itemRow(DocType type, int index, DocLine line, DocFormat fmt) {
  final notes = [
    ...line.notes,
    if (line.discount > 0)
      line.discountRate != null
          ? 'Less ${fmt.rate(line.discountRate!)} discount: ${fmt.minus(line.discount)}'
          : 'Less discount: ${fmt.minus(line.discount)}',
  ];
  final unitPrice =
      line.unitPrice == null ? '-' : fmt.money(line.unitPrice!);
  final quantity = fmt.quantity(line.quantity, line.unit);
  if (type == DocType.order) {
    return DocRow([
      '$index',
      line.name,
      quantity,
      fmt.quantity(line.delivered ?? 0, line.unit),
      fmt.quantity(line.outstanding ?? line.quantity, line.unit),
      unitPrice,
      fmt.money(line.amount),
    ], notes: notes);
  }
  return DocRow([
    '$index',
    line.name,
    quantity,
    unitPrice,
    fmt.money(line.amount),
  ], notes: notes);
}

// The totals box rows, as text. The roll print uses the same rows.
List<DocTotalRow> salesDocumentTotalRows(SalesDocument doc, DocFormat fmt) {
  final t = doc.totals;
  // A payment on an invoice or a delivery on an order: what was paid on
  // this receipt and what is left on the invoice or order. The parent's
  // subtotal, discount and VAT would not add up to this payment.
  final parent = switch (doc.receiptKind) {
    DocReceiptKind.invoicePayment => 'Invoice',
    DocReceiptKind.orderDelivery => 'Order',
    DocReceiptKind.sale => null,
  };
  if (parent != null) {
    return [
      DocTotalRow('Amount paid', fmt.money(t.total), emphasize: true),
      if (t.receiptBalance != null)
        DocTotalRow('$parent balance', fmt.money(t.receiptBalance!)),
    ];
  }
  final rows = <DocTotalRow>[DocTotalRow('Subtotal', fmt.money(t.subtotal))];
  if (t.itemDiscounts > 0.0005) {
    rows.add(DocTotalRow('Item discounts', fmt.minus(t.itemDiscounts)));
  }
  if (t.discount > 0.0005) {
    rows.add(DocTotalRow(t.discountLabel, fmt.minus(t.discount)));
  }
  if (t.vatRate != null) {
    rows.add(DocTotalRow('VAT (${fmt.rate(t.vatRate!)})', fmt.money(t.vat)));
  }
  if (t.adjustment != null) {
    rows.add(DocTotalRow('Price adjustment', fmt.money(t.adjustment!)));
  }
  rows.add(DocTotalRow('Total', fmt.money(t.total), emphasize: true));
  if (t.paid != null) {
    rows.add(DocTotalRow('Paid', fmt.money(t.paid!)));
  }
  if (t.balance != null) {
    rows.add(
      DocTotalRow(
        doc.type == DocType.invoice ? 'Balance due' : 'Balance',
        fmt.money(t.balance!),
        emphasize: t.balance! > 0.005,
      ),
    );
  }
  if (t.receiptBalance != null) {
    rows.add(DocTotalRow('Balance', fmt.money(t.receiptBalance!)));
  }
  return rows;
}

List<DocColumn> _paymentColumns(DocType type) {
  if (type == DocType.receipt) {
    return const [
      DocColumn('Method', flex: 3),
      DocColumn('Amount', flex: 2, align: DocAlign.right),
    ];
  }
  return const [
    DocColumn('Date', flex: 3),
    DocColumn('Method', flex: 2),
    DocColumn('Staff', flex: 3),
    DocColumn('Amount', flex: 2, align: DocAlign.right),
  ];
}

DocRow _paymentRow(DocType type, DocPayment payment, DocFormat fmt) {
  if (type == DocType.receipt) {
    return DocRow([payment.method, fmt.money(payment.amount)]);
  }
  return DocRow([
    payment.date == null ? '-' : fmt.dateTime(payment.date!),
    payment.method,
    payment.staff ?? '-',
    fmt.money(payment.amount),
  ]);
}

DocBadgeTone _tone(DocPaymentStatus? status) {
  switch (status) {
    case DocPaymentStatus.unpaid:
      return DocBadgeTone.alert;
    case DocPaymentStatus.partPaid:
      return DocBadgeTone.warning;
    case DocPaymentStatus.paid:
    case null:
      return DocBadgeTone.good;
  }
}

String _titleCase(String value) => value
    .toLowerCase()
    .split(' ')
    .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
    .join(' ');
