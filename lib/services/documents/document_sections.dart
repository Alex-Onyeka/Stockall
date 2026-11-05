import 'dart:typed_data';

// Generic building blocks of a printed A4 document. Plain data only, so a
// layout can be tested without rendering a PDF. Sales documents use them
// today; the report exports can build the same sections.

enum DocAlign { left, center, right }

// The business printing the document: its logo or name on the left, its
// contact lines on the right.
class DocShop {
  final String name;
  final bool showName;
  final Uint8List? logo;

  // True when the logo is much wider than tall (more than 2:1), so it is
  // drawn shorter.
  final bool logoIsWide;
  final List<String> contactLines;
  final String? reference;

  const DocShop({
    required this.name,
    this.showName = true,
    this.logo,
    this.logoIsWide = false,
    this.contactLines = const [],
    this.reference,
  });
}

// One label/value pair of the general information box.
class DocField {
  final String label;
  final String value;

  const DocField(this.label, this.value);

  @override
  String toString() => '$label: $value';
}

class DocColumn {
  final String title;
  final int flex;
  final DocAlign align;

  const DocColumn(
    this.title, {
    this.flex = 1,
    this.align = DocAlign.left,
  });
}

// A table row. Notes print in small text under the cell at noteColumn.
class DocRow {
  final List<String> cells;
  final List<String> notes;
  final int noteColumn;

  const DocRow(
    this.cells, {
    this.notes = const [],
    this.noteColumn = 1,
  });
}

class DocTotalRow {
  final String label;
  final String value;
  final bool emphasize;

  const DocTotalRow(
    this.label,
    this.value, {
    this.emphasize = false,
  });
}

enum DocBadgeTone { good, warning, alert }

sealed class DocSection {
  const DocSection();
}

class DocHeaderSection extends DocSection {
  final DocShop shop;

  const DocHeaderSection(this.shop);
}

class DocTitleSection extends DocSection {
  final String title;
  final String? subtitle;

  // A further line under the subtitle.
  final String? note;
  final String? badge;
  final DocBadgeTone badgeTone;

  const DocTitleSection(
    this.title, {
    this.subtitle,
    this.note,
    this.badge,
    this.badgeTone = DocBadgeTone.good,
  });
}

// Bordered key/value grid with a dark heading band.
class DocInfoBoxSection extends DocSection {
  final String heading;
  final List<DocField> fields;
  final int columns;

  const DocInfoBoxSection(
    this.heading,
    this.fields, {
    this.columns = 2,
  });
}

// Full-width band introducing the next section. Dark: solid dark with
// white text. Light: pale grey-blue with dark text.
class DocBandSection extends DocSection {
  final String text;
  final bool dark;

  const DocBandSection(this.text, {this.dark = true});
}

class DocTableSection extends DocSection {
  final List<DocColumn> columns;
  final List<DocRow> rows;
  final String? emptyText;

  const DocTableSection(
    this.columns,
    this.rows, {
    this.emptyText,
  });
}

// Right-aligned bordered box of totals, with the document's EAN-13
// barcode (if any) in the space on its left.
class DocTotalsSection extends DocSection {
  final List<DocTotalRow> rows;
  final String? barcode;

  const DocTotalsSection(this.rows, {this.barcode});
}

class DocTextSection extends DocSection {
  final String text;

  const DocTextSection(this.text);
}

// Shown at the bottom of every page.
class DocFooter {
  final String left;
  final String? message;

  const DocFooter({required this.left, this.message});
}

// A whole document, ready to render.
class DocLayout {
  final String title;
  final List<DocSection> sections;
  final DocFooter footer;

  const DocLayout({
    required this.title,
    required this.sections,
    required this.footer,
  });

  Iterable<T> sectionsOf<T extends DocSection>() =>
      sections.whereType<T>();
}
