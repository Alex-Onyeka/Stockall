import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';

import 'production_report_fixtures.dart';

void main() {
  group('MaterialItemHistoryEventClass.eventOf', () {
    String? eventOf(String title, {bool? isIncreased, String? event}) =>
        MaterialItemHistoryEventClass.eventOf(
          materialHistory(title: title, event: event, isIncreased: isIncreased),
        );

    test('infers the event of every legacy title', () {
      final cases = <String, String>{
        'Item Created': MaterialItemHistoryEventClass.itemCreated,
        'Item Deleted': MaterialItemHistoryEventClass.itemDeleted,
        'Material Used': MaterialItemHistoryEventClass.usageCreated,
        'Material Usage Deleted': MaterialItemHistoryEventClass.usageDeleted,
        'Material Used in Production':
            MaterialItemHistoryEventClass.productionCreated,
        'Production Record Deleted':
            MaterialItemHistoryEventClass.productionDeleted,
        'Transfered In': MaterialItemHistoryEventClass.transferedIn,
        'Transferred In': MaterialItemHistoryEventClass.transferedIn,
        'Transfered Out': MaterialItemHistoryEventClass.transferedOut,
        'Transferred Out': MaterialItemHistoryEventClass.transferedOut,
        'Item Quantity Increased':
            MaterialItemHistoryEventClass.quantityUpdatedIncrease,
        'Item Quantity Reduced':
            MaterialItemHistoryEventClass.quantityUpdatedDecrease,
      };
      cases.forEach((title, expected) {
        expect(eventOf(title), expected, reason: title);
        expect(
          eventOf('  ${title.toUpperCase()} '),
          expected,
          reason: 'case and spaces: $title',
        );
      });
    });

    test('"Material Used in Production" is not read as manual usage', () {
      expect(
        eventOf('Material Used in Production'),
        isNot(MaterialItemHistoryEventClass.usageCreated),
      );
    });

    test('other quantity titles follow isIncreased', () {
      expect(
        eventOf('Item Quantity Updated', isIncreased: true),
        MaterialItemHistoryEventClass.quantityUpdatedIncrease,
      );
      expect(
        eventOf('Item Quantity Updated', isIncreased: false),
        MaterialItemHistoryEventClass.quantityUpdatedDecrease,
      );
      expect(eventOf('Item Quantity Updated'), isNull);
    });

    test('the title wins over isIncreased for increased/reduced', () {
      expect(
        eventOf('Item Quantity Reduced', isIncreased: true),
        MaterialItemHistoryEventClass.quantityUpdatedDecrease,
      );
    });

    test('unknown titles give null', () {
      expect(eventOf('Something Else'), isNull);
      expect(eventOf(''), isNull);
      // A produced-item title isn't a material event.
      expect(eventOf('Item Produced'), isNull);
    });

    test('a stored event wins over the title', () {
      expect(
        eventOf('Material Used', event: 'transfered_out'),
        'transfered_out',
      );
      expect(eventOf('Material Used', event: '  usage_deleted '), 'usage_deleted');
    });

    test('a blank stored event falls back to the title', () {
      expect(
        eventOf('Material Used', event: '   '),
        MaterialItemHistoryEventClass.usageCreated,
      );
    });

    test("Alex's flour history: legacy copies give the stored events", () {
      final example = AlexExample();
      for (final h in example.flourHistory) {
        final stored = MaterialItemHistoryEventClass.eventOf(h);
        expect(stored, h.event);
        final legacy = materialHistory(
          title: h.title,
          event: null,
          isIncreased: h.isIncreased,
        );
        expect(
          MaterialItemHistoryEventClass.eventOf(legacy),
          stored,
          reason: h.title,
        );
      }
    });
  });

  group('ProductionItemHistoryEventClass.eventOf', () {
    String? eventOf(String title, {bool? isIncreased, String? event}) =>
        ProductionItemHistoryEventClass.eventOf(
          producedHistory(title: title, event: event, isIncreased: isIncreased),
        );

    test('infers the event of every legacy title', () {
      final cases = <String, String>{
        'Item Created': ProductionItemHistoryEventClass.itemCreated,
        'Item Deleted': ProductionItemHistoryEventClass.itemDeleted,
        'Item Produced': ProductionItemHistoryEventClass.productionCreated,
        'Production Record Deleted':
            ProductionItemHistoryEventClass.productionDeleted,
        'Transfered In': ProductionItemHistoryEventClass.transferedIn,
        'Transferred In': ProductionItemHistoryEventClass.transferedIn,
        'Transfered Out': ProductionItemHistoryEventClass.transferedOut,
        'Transferred Out': ProductionItemHistoryEventClass.transferedOut,
        'Item Quantity Increased':
            ProductionItemHistoryEventClass.quantityUpdatedIncrease,
        'Item Quantity Reduced':
            ProductionItemHistoryEventClass.quantityUpdatedDecrease,
      };
      cases.forEach((title, expected) {
        expect(eventOf(title), expected, reason: title);
        expect(
          eventOf('  ${title.toLowerCase()} '),
          expected,
          reason: 'case and spaces: $title',
        );
      });
    });

    test('other quantity titles follow isIncreased', () {
      expect(
        eventOf('Item Quantity Updated', isIncreased: true),
        ProductionItemHistoryEventClass.quantityUpdatedIncrease,
      );
      expect(
        eventOf('Item Quantity Updated', isIncreased: false),
        ProductionItemHistoryEventClass.quantityUpdatedDecrease,
      );
      expect(eventOf('Item Quantity Updated'), isNull);
    });

    test('unknown titles give null', () {
      expect(eventOf('Something Else'), isNull);
      expect(eventOf(''), isNull);
      // Material titles aren't produced-item events.
      expect(eventOf('Material Used'), isNull);
      expect(eventOf('Material Used in Production'), isNull);
    });

    test('a stored event wins over the title', () {
      expect(
        eventOf('Item Produced', event: 'production_deleted'),
        'production_deleted',
      );
    });

    test('a blank stored event falls back to the title', () {
      expect(
        eventOf('Item Produced', event: ''),
        ProductionItemHistoryEventClass.productionCreated,
      );
    });

    test("Alex's donut history: legacy copies give the stored events", () {
      final example = AlexExample();
      for (final h in example.donutHistory) {
        final stored = ProductionItemHistoryEventClass.eventOf(h);
        expect(stored, h.event);
        final legacy = producedHistory(
          title: h.title,
          event: null,
          isIncreased: h.isIncreased,
        );
        expect(
          ProductionItemHistoryEventClass.eventOf(legacy),
          stored,
          reason: h.title,
        );
      }
    });
  });
}
