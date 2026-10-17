Task: Implement the Receipt Table in Stockall
Implement a complete Receipt Table feature in my existing Stockall Flutter application.

The table should display receipt records with financial summaries, staff and customer information, transaction types, and configurable search, sorting, and filtering.

Before writing code, inspect the existing codebase to understand:

The current receipt table or report architecture, if one exists.

The TempMainReceipt model and how receipt records are stored and retrieved.

The TempProductSaleRecord model and the fields available for calculating item-level profit/loss.

How sales, invoice payments, and order deliveries are created and stored.

How revenue, subtotal, discounts, VAT, cost, profit, and profit margin are currently calculated elsewhere in Stockall.

How Manage Bulk Sale and Department Management settings are stored and accessed.

Existing date filtering, business-day handling, pagination, search, sorting, and UI conventions.

Reuse existing logic and utilities wherever possible. Do not introduce duplicate calculations if Stockall already has a reliable implementation.


The items field may be null or empty for older receipts. Handle these records safely without crashing.

2. Receipt Table Columns
Display the following columns in the table, in the specified order.

1. ID
Display the existing receipt ID or the appropriate receipt identifier used by the existing application.

Inspect how receipt IDs are assigned and displayed. If id can be null, use an appropriate existing fallback identifier, such as the receipt barcode or UUID, without inventing identifiers that could be mistaken for persisted IDs.

2. Staff
Display staffName.

Handle null or missing names gracefully.

3. Sub-Staff
Display subStaffName.

Show this column only when the existing Manage Bulk Sale setting is enabled. Use the actual settings mechanism in the codebase rather than creating a new setting.

4. Customer
Display customerName.

Handle missing customer names consistently with the existing UI.

5. Channel
Display the actual payment channel or combination of channels used for the receipt.

The supported channels are:

Cash

Bank

Customer Account

Split

Determine the displayed channel from the receipt's actual payment allocation fields and existing payment-method conventions.

Use cashAlt, bank, and customerAccount where appropriate. Inspect the existing payment processing logic before deciding how paymentMethod relates to these fields.

A receipt paid through multiple channels should display Split when that is consistent with the application's existing payment semantics.

Do not assume that every receipt has a single payment channel or infer the channel solely from a non-null field.

6. Date
Display the receipt's date based on createdAt.

Use Stockall's existing date formatting and business-day conventions. Do not introduce a new timezone conversion or modify the timestamp to make it fit a calendar date.

7. Time
Display the time portion of createdAt accurately, using the existing application's time formatting conventions.

Date filtering and time display must remain consistent with the existing business-day system.

8. Discount
Display the receipt's applicable discount using the existing discount calculation logic.

Inspect generalDiscount and fixedDiscount to determine how Stockall distinguishes percentage-based and fixed discounts. Avoid double-counting them.

9. VAT
Display the applicable VAT amount from vat, using the existing currency formatting.

Inspect the codebase to establish whether this field represents the actual VAT amount or a rate before implementing the display. Do not reinterpret a stored amount as a percentage.

10. Items
Display the total number of individual units represented by the receipt's sold lines.

For example:

1 item sold as 2 bottles contributes 2.

1 item sold as 3 bags contributes 3.

A receipt containing 2 bottles and 3 bags displays 5 items.

Use the actual quantity fields and quantity conventions in TempProductSaleRecord. Do not simply count the number of entries in items.

Respect Stockall's existing group-unit, quantity conversion, and dimensional inventory rules. For dimensional products, inspect the existing model and reporting conventions to determine how the item count should be represented. Do not invent conversions between area measurements and individual pieces.

If items is null or empty, handle the record gracefully and avoid crashing. Do not fabricate historical quantities.

11. Department
Display departmentName.

Show this column only when Department Management is enabled.

For receipts without a department assignment, display No Department.

Use the application's existing department-management setting and conventions.

12. Comment
Display comment.

Handle null and empty comments gracefully without displaying the literal string null.

13. Type
Determine the receipt type from salesTypeIndex:

1 = Sales

2 = Invoice Payment

3 = Order Delivery

Use these exact labels.

Inspect existing records and sales-processing code to understand how missing or unexpected index values should be handled. Do not silently classify unknown values as Sales.

14. Balance
Display the receipt's applicable outstanding balance from balance, particularly for Invoice Payment records.

Inspect how invoice balances are stored and updated. Do not automatically treat the balance on an ordinary sale or order delivery as an invoice balance.

Use the existing currency formatting and display conventions.

15. Profit/Loss
Display the sum of the profit/loss values of the individual sold lines in the receipt.

Inspect TempProductSaleRecord and the existing product-sales and reporting calculations to determine how each line's profit/loss is calculated.

Requirements:

Calculate the receipt-level result by summing the applicable item-level profit/loss values.

Preserve existing cost-price, selling-price, discount, return, and wastage conventions where applicable.

Avoid counting a line's profit twice.

Handle missing historical item data safely.

Do not assume that originalCost alone is sufficient to calculate receipt profit.

Do not invent item-level profit when the required historical data is unavailable.

Visual presentation:

Positive profit: green.

Negative profit/loss: red.

Zero: neutral styling.

Use the existing Stockall theme and financial formatting conventions.

16. Profit Margin (%)
Display the receipt's profit margin as a percentage.

Inspect the existing Stockall reports to establish the application's standard profit-margin formula and revenue denominator. Reuse that formula to ensure the Receipt Table agrees with other financial reports.

If the established formula is profit divided by revenue multiplied by 100, follow it consistently.

Handle zero revenue, missing financial data, and negative revenue safely. Never allow division by zero or display NaN or Infinity.

Do not calculate the average of individual item margins. Calculate the receipt-level margin from the appropriate aggregate values.

17. Subtotal
Display the receipt's subtotal using the application's existing subtotal calculation.

Inspect how Stockall calculates subtotal relative to discounts, VAT, and other charges. Avoid calculating a second, inconsistent subtotal from the displayed fields.

18. Total Revenue
Display the receipt's applicable total revenue using the established Stockall accounting conventions.

Inspect existing receipt, sales, and financial-report calculations before implementing this value.

Distinguish between:

The total value of items sold.

The amount actually collected.

Customer-account payments or credit.

Invoice payments.

Outstanding balances.

Do not automatically treat cash received as total revenue.

For Invoice Payment and Order Delivery records, inspect how Stockall represents these transactions to avoid counting the original sale and subsequent payments as new sales revenue.

Reuse the existing revenue calculation wherever possible.

3. Sorting
Users must be able to sort the table by:

Customer name.

Staff name.

Created date.

Revenue.

Balance.

Profit/loss.

Each supported field must support ascending and descending sorting.

Sorting must be applied to the complete filtered dataset before pagination, not just the currently visible page.

Requirements:

Handle nullable values consistently.

Use numeric comparisons for monetary amounts.

Use chronological comparisons for dates.

Use case-insensitive comparisons for names where appropriate.

Preserve the active filters and search query when sorting changes.

Additional sorting options may be included if they fit the existing table architecture, but the six required fields must be implemented.

4. Search
Provide a search field that can search receipts by:

Customer name.

Staff name.

Department name, only when Department Management is enabled.

Search must be case-insensitive where appropriate and must work together with the active filters.

If receipt IDs or barcodes are already searchable in related Stockall tables, preserve or reuse that behavior where appropriate.

Do not implement inventory item-name search as the primary search behavior for this receipt table. This table represents receipts, not individual inventory products.

5. Filters
Implement the following receipt-specific filters.

A. Staff Filter
Allow users to select a staff member and display receipts associated with that staff member.

Use existing staff identifiers and names. Prefer stable IDs for matching rather than relying exclusively on display names.

Provide an option to clear the staff filter.

B. Customer Filter
Allow users to select a customer and display receipts associated with that customer.

Use existing customer identifiers and names. Handle receipts without a customer assignment appropriately if the existing application supports anonymous or walk-in sales.

Provide an option to clear the customer filter.

C. Channel Filter
Allow filtering by:

Cash

Bank

Customer Account

Split

The filter must use the same channel-classification logic as the Channel column.

A receipt must not be classified differently in the table and in the filter.

D. Profit Range Filter
Allow users to specify a minimum and maximum receipt profit/loss.

Apply the range to the calculated receipt-level profit/loss.

Support negative values so that users can filter loss-making receipts as well as profitable ones.

Validate the range and handle missing historical profit data consistently. Do not silently classify unknown profit as zero.

E. Sub-Staff Filter
Show this filter only when Manage Bulk Sale is enabled.

Allow users to select a sub-staff member and display receipts associated with that sub-staff member.

Use the existing sub-staff identifiers and names.

Provide an option to clear the filter.

F. Department Filter
Show this filter only when Department Management is enabled.

Allow users to filter by a selected department.

Receipts without a department assignment must be grouped under:

No Department

Selecting No Department must display receipts without a department assignment.

G. Revenue Range Filter
Allow users to specify a minimum and maximum total revenue.

Apply this range to the same receipt-level revenue calculation displayed in the Total Revenue column.

Use the established Stockall revenue conventions rather than automatically using cash received, subtotal, or item selling value.

Validate minimum and maximum values before applying the filter.

H. Filter Behaviour
All filters must work together.

For example, users should be able to display receipts for a particular staff member and customer, restrict the results to Split payments, select a department, and specify both a revenue range and a profit range.

Requirements:

Provide a way to clear individual filters.

Provide a Reset All Filters action.

Preserve search when a filter changes.

Preserve active filters when sorting changes.

Recalculate pagination appropriately when filtering changes.

Display an appropriate empty state when no receipts match.

Ensure all filter comparisons use the same calculations and classifications as the table columns.

6. Pagination and Performance
Inspect the existing report-table implementation and reuse its pagination approach.

Requirements:

Apply search and filters before sorting.

Apply sorting before pagination.

Avoid repeatedly recalculating receipt-level financial summaries during every widget rebuild.

Avoid unnecessary database requests or Hive reads when existing data can be reused.

Respect the currently selected shop and existing access-control rules.

Ensure pagination remains correct when the filtered result count changes.

The intended processing order is:

Obtain the applicable receipt records.

Apply search.

Apply all active filters.

Sort the filtered records.

Paginate the sorted results.

Render the table.

Use server-side filtering or sorting only where appropriate to the existing data architecture. If calculations require local item-level data, ensure the complete relevant dataset is processed before pagination.

7. Data Integrity and Financial Accuracy
Receipt reporting must not modify the underlying transactions.

Do not rewrite receipt records.

Do not alter Hive field indexes or adapters.

Do not modify Supabase schemas or stored historical transactions for this task.

Do not recalculate and persist historical receipt totals merely to populate the table.

Do not count invoice payments as additional sales revenue unless that matches the application's established accounting model.

Do not assume that missing historical item details represent zero profit.

Reuse existing financial calculations wherever possible.

Keep receipt type, payment channel, profit/loss, margin, and revenue consistent with the rest of Stockall.

If a historical receipt does not contain enough data to calculate a value reliably, handle the missing information explicitly and safely rather than inventing a financial result.

8. UI and Project Conventions
Follow the existing Stockall UI, design system, responsive layouts, currency formatting, typography, and theme.

Make the table usable on the platforms supported by the existing application, including Windows, web, and mobile where the current report architecture supports them.

Do not redesign unrelated pages or change the application's navigation unnecessarily.

Keep the implementation maintainable. Extract shared calculation or filtering helpers only where appropriate, and avoid creating unnecessary abstractions.

9. Permissions and Sensitive Files
You may inspect relevant source files, trace dependencies, implement the table, and modify ordinary Dart source files needed for the task without repeatedly requesting permission.

Do not make unrelated changes.

Do not modify sensitive project configuration files such as pubspec.yaml, Android manifests, Gradle files, signing configuration, or build-critical settings unless genuinely necessary. If such a change is required, stop and explain the reason before proceeding.

Do not delete existing code or data merely because it appears unused without verifying its role.

10. Testing and Final Report
After implementation:

Run the relevant tests and available Dart/Flutter static analysis.

Verify each of the 18 columns.

Verify conditional Sub-Staff and Department columns.

Verify receipt type mapping for indexes 1, 2, and 3.

Verify all six required sorting fields in ascending and descending order.

Verify search across customer, staff, and department.

Verify that all filters can be combined and individually cleared.

Verify Reset All Filters.

Verify pagination after search, filtering, and sorting.

Verify positive profit, negative profit, zero profit, and profit-margin calculations.

Verify missing or empty items data on older receipts.

Verify that invoice payments and order deliveries are not incorrectly counted as additional sales revenue.

Confirm that the existing application architecture and persisted data structures remain compatible.

At completion, provide a concise report stating:

The files created or modified.

The functionality implemented.

The existing calculation utilities reused.

The formulas used for profit/loss, profit margin, subtotal, and total revenue.

How payment channels are classified.

The tests and analysis performed.

Any unresolved issues or historical data limitations.

Do not stop after building the visual table. Complete the filtering, sorting, calculations, pagination, and verification.

If an existing calculation is ambiguous, inspect its usage across Stockall before deciding how to implement it. Prioritize consistency with the application's established financial logic over introducing a new formula.

