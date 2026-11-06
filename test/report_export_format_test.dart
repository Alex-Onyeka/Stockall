import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';

void main() {
  final f = ExportFormatter(currency: '₦');

  group('money', () {
    test('two decimals with the Naira sign', () {
      expect(f.money(1234.5), '₦1,234.50');
      expect(f.money(125), '₦125.00');
    });

    test('negatives put the sign before the currency', () {
      expect(f.money(-500), '-₦500.00');
      expect(f.money(-1234567.891), '-₦1,234,567.89');
    });

    test('zero, negative zero and tiny negatives print as zero', () {
      expect(f.money(0), '₦0.00');
      expect(f.money(-0.0), '₦0.00');
      expect(f.money(-0.001), '₦0.00');
    });

    test('amounts above a billion are not shortened', () {
      expect(f.money(1234567890.5), '₦1,234,567,890.50');
      expect(f.money(2500000000), '₦2,500,000,000.00');
    });

    test('NaN and infinity give empty text', () {
      expect(f.money(double.nan), '');
      expect(f.money(double.infinity), '');
    });

    test('other currencies', () {
      expect(ExportFormatter(currency: '\$').money(9.99), '\$9.99');
      expect(ExportFormatter(currency: '').money(9.99), '9.99');
    });
  });

  group('numbers', () {
    test('integer', () {
      expect(f.integer(1250), '1,250');
      expect(f.integer(-3), '-3');
      expect(f.integer(-0.4), '0');
    });

    test('number and quantity drop trailing zeros', () {
      expect(f.number(1250), '1,250');
      expect(f.number(2.5), '2.5');
      expect(f.number(0.125), '0.125');
      expect(f.number(1 / 3), '0.333');
      expect(f.quantity(12), '12');
      expect(f.quantity(-2.25), '-2.25');
    });

    test('percent trims trailing zeros', () {
      expect(f.percent(12.5), '12.5%');
      expect(f.percent(12), '12%');
      expect(f.percent(-3.456), '-3.46%');
      expect(f.percent(-0.001), '0%');
      expect(f.percent(double.nan), '');
    });
  });

  group('dates', () {
    final d = DateTime(2026, 3, 7, 14, 5);

    test('date, time and both', () {
      expect(f.date(d), 'Mar 7, 2026');
      expect(f.time(d), '02:05 PM');
      expect(f.dateTime(d), 'Mar 7, 2026 | 02:05 PM');
    });
  });

  group('format by column type', () {
    test('null gives empty text', () {
      for (final t in ExportFormat.values) {
        expect(f.format(null, t), '', reason: t.name);
      }
    });

    test('each format', () {
      final d = DateTime(2026, 1, 2, 9, 0);
      expect(f.format('Coke', ExportFormat.text), 'Coke');
      expect(f.format(1500, ExportFormat.money), '₦1,500.00');
      expect(f.format(1500, ExportFormat.integer), '1,500');
      expect(f.format(2.5, ExportFormat.number), '2.5');
      expect(f.format(2.5, ExportFormat.quantity), '2.5');
      expect(f.format(20, ExportFormat.percent), '20%');
      expect(f.format(d, ExportFormat.date), 'Jan 2, 2026');
      expect(f.format(d, ExportFormat.time), '09:00 AM');
      expect(f.format(d, ExportFormat.dateTime), 'Jan 2, 2026 | 09:00 AM');
    });

    test('a value of the wrong type falls back to its text', () {
      expect(f.format('N/A', ExportFormat.money), 'N/A');
      expect(f.format(12, ExportFormat.date), '12');
    });

    test('numeric formats align right, others left', () {
      expect(ExportFormat.money.defaultAlign, ExportAlign.right);
      expect(ExportFormat.percent.defaultAlign, ExportAlign.right);
      expect(ExportFormat.text.defaultAlign, ExportAlign.left);
      expect(ExportFormat.date.defaultAlign, ExportAlign.left);
    });
  });

  group('Excel number formats', () {
    test('money keeps the currency as a quoted literal', () {
      expect(excelMoneyFormat('₦'), '"₦"#,##0.00;-"₦"#,##0.00');
      expect(excelMoneyFormat(''), '#,##0.00;-#,##0.00');
      expect(excelMoneyFormat('a"b'), '"ab"#,##0.00;-"ab"#,##0.00');
    });

    test('whole quantities have no decimals', () {
      expect(
        excelNumberFormat(ExportFormat.quantity, 12.0, currency: '₦'),
        excelIntegerFormat,
      );
      expect(
        excelNumberFormat(ExportFormat.quantity, 2.5, currency: '₦'),
        excelDecimalFormat,
      );
    });

    test('other formats', () {
      expect(
        excelNumberFormat(ExportFormat.money, 1, currency: '₦'),
        '"₦"#,##0.00;-"₦"#,##0.00',
      );
      expect(
        excelNumberFormat(ExportFormat.percent, 12.5, currency: '₦'),
        excelPercentFormat,
      );
      expect(
        excelNumberFormat(ExportFormat.date, null, currency: '₦'),
        excelDateFormat,
      );
      expect(excelNumberFormat(ExportFormat.text, 'x', currency: '₦'), isNull);
    });
  });

  group('file names', () {
    test('downloaded_<slug>_<millis>.<ext>', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1793000000000);
      const spec = ReportExportSpec(
        reportName: 'Items Report',
        fileSlug: 'Items Report!',
        sections: [],
      );
      expect(
        reportExportFileName(spec, 'pdf', now: now),
        'downloaded_items_report_1793000000000.pdf',
      );
      expect(
        reportExportFileName(spec, 'xlsx', now: now),
        'downloaded_items_report_1793000000000.xlsx',
      );
    });

    test('a blank slug falls back to "report"', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1);
      const spec = ReportExportSpec(
        reportName: 'X',
        fileSlug: '  ',
        sections: [],
      );
      expect(
        reportExportFileName(spec, 'pdf', now: now),
        'downloaded_report_1.pdf',
      );
    });
  });
}
