Task: Implement the Item Records Table in Stockall
Implement a complete Item Records Table feature in my existing Stockall Flutter application.

The table must display individual item records associated with receipts, allowing users to analyse item sales, quantities, selling prices, discounts, costs, profit/loss, and transaction history.

Unlike the Receipt Table, which displays one row per receipt, this table must display one row per TempProductSaleRecord. A single receipt may therefore appear across multiple rows, one for each recorded item line.

The table must support searching, sorting, pagination, financial calculations, and configurable filters, including Filter by Item Category and Filter by Item.

1. Inspect the Existing Codebase First
Before writing code, inspect the relevant parts of the Stockall Flutter application to understand:

The existing Receipt Table, product-sales reports, item reports, and reusable table components.

The TempProductSaleRecord model, its Hive adapter, and how item records are stored and retrieved.

The relationship between item records and their parent receipts.

How receiptUuid, invoiceUuid, recepitId, and the nullable productUuid and productId fields are used.

How product categories are represented and related to products.

How department assignments are stored and how Department Management is enabled.

How staff, customers, and sub-staff identifiers and names are obtained.

How sales, invoice payments, order deliveries, returns, and voided item lines are represented.

Existing financial calculations for selling value, discounts, cost, profit/loss, profit margin, subtotal, and revenue.

Existing quantity conversion, group-unit, multiple-unit, dimensional-product, and wastage calculations.

Existing date filtering, business-day handling, pagination, sorting, search, currency formatting, and responsive table conventions.

How the currently selected shop and the applicable access-control rules are enforced.

Reuse established Stockall utilities, data access methods, models, and UI conventions wherever possible. Do not create duplicate financial calculations or a separate settings mechanism when existing functionality already provides the required behaviour.

Do not modify the existing TempProductSaleRecord Hive field indexes, adapters, or persisted transaction structures for this task.

2. Data Source and Record Identification
Use the existing item-level transaction records represented by:

TempProductSaleRecord

Inspect how these records are persisted locally and remotely and how the application retrieves them for the selected shop.

Relevant model fields include:

productRecordId

createdAt

productId

productName

shopId

staffId

staffName

customerId

customerName

recepitId

discount

quantity

revenue

discountedAmount

originalCost

costPrice

customPriceSet

departmentName

departmentUuid

addToStock

uuid

productUuid

customerUuid

receiptUuid

isProductManaged

setTotalPrice

invoiceUuid

fixedDiscount

unit

useWholeSalePrice

useGroupQuantity

qttyPerGroup

isVoid

unitsList

unitUuid

pricesList

priceUuid

widthDimension

heightDimension

quantityType

manageSalesWastage

isPercentageWastage

wastageAmount

wastageUnitUuid

Use the actual field definitions and existing relationships in the codebase as the source of truth.

Record identification requirements
Use the existing persisted item-record identifier where available.

Use the product's name and stable product identifier to identify the item.

Use the associated receipt or invoice reference to identify the parent transaction.

Do not treat a product ID as a receipt ID or an item-record ID.

Handle nullable IDs and UUIDs safely.

Do not generate fake persisted identifiers for records whose identifiers are missing.

Do not accidentally merge separate item records merely because they refer to the same product.

Respect the selected shop and existing data access restrictions.

If records are stored in both Hive and Supabase, inspect the established synchronization and retrieval logic before deciding which source to use. Avoid duplicate rows when local and remote copies represent the same persisted item record.

3. Item Records Table Columns
Display the following columns in the specified order. Follow the existing Stockall table architecture and responsive layout conventions.

1. Record ID
Display the existing item-record identifier, such as productRecordId or the appropriate persisted record identifier used by the application.

If the identifier is nullable, use an existing safe fallback where appropriate. Do not invent an identifier that could be mistaken for a database ID.

2. Item
Display productName.

Where appropriate, allow the user to open the existing product details page using the product's stable identifier.

Handle missing product names gracefully.

3. Category
Display the item's actual product category using the existing product-category relationship.

The category is not explicitly defined in TempProductSaleRecord. Inspect the product model, category tables, and existing category-management logic to determine how to retrieve it.

Requirements:

Reuse existing category information rather than introducing a duplicate category field.

Handle deleted products and missing historical category information safely.

Do not substitute departmentName for the product category.

If the category cannot be reliably retrieved for a historical item record, use the existing missing-value convention.

4. Receipt ID
Display the identifier of the parent receipt associated with the item record.

Inspect how receiptUuid, recepitId, and the existing receipt model relate to one another.

Prefer the actual receipt identifier displayed by Stockall's Receipt Table. Where necessary, use an appropriate existing fallback.

For item records associated with invoices or other transaction types, use the correct parent transaction reference. Do not display an unrelated identifier.

5. Staff
Display staffName, using the existing staff information and identifiers.

Handle missing names consistently with the rest of Stockall.

6. Sub-Staff
Display the associated sub-staff name where the existing item-record or parent-transaction relationship provides it.

Show this column only when the existing Manage Bulk Sale setting is enabled.

Inspect how sub-staff assignments are represented in the codebase. Do not invent a new setting or infer sub-staff identity from the main staff name.

7. Customer
Display customerName.

Handle missing customer information consistently with the existing application, including anonymous or walk-in transactions where supported.

8. Date
Display the item's transaction date using createdAt.

Use Stockall's existing date formatting and business-day conventions.

Do not introduce a new timezone conversion or alter stored timestamps to make them fit a calendar day.

Inspect the existing date filtering and business-day logic before implementing date-range filters. Preserve the established distinction between calendar-day filtering and configurable business-day boundaries.

9. Time
Display the time portion of createdAt accurately, using existing Stockall formatting conventions.

The displayed date, displayed time, and date-filtering behaviour must remain consistent.

10. Quantity
Display the item's recorded quantity using quantity and the appropriate unit.

Requirements:

Respect the item's selected unit.

Respect the existing group-unit conventions involving useGroupQuantity and qttyPerGroup.

Support fractional quantities where the product's measurement rules permit them.

Respect the existing multiple-unit and dimensional-product conventions.

Do not blindly multiply quantities by group size if the recorded quantity has already been converted.

Do not count area measurements as individual pieces unless the existing product configuration explicitly establishes that relationship.

Handle missing or invalid historical quantity data safely.

For dimensional products, inspect how Stockall represents 2D products using quantityType, widthDimension, and heightDimension.

Do not invent conversions between area measurements and individual pieces.

11. Unit
Display the appropriate transaction unit using unit, unitUuid, and the existing unit information where available.

If the unit name is no longer available, fall back to the recorded unit or an established missing-value convention.

Do not replace a historical transaction unit with the product's current default unit if doing so would misrepresent the original transaction.

12. Selling Price
Display the applicable selling price per recorded sale unit.

Inspect the existing pricing logic and determine how Stockall derives the effective unit price from:

revenue

quantity

discountedAmount

discount

fixedDiscount

setTotalPrice

customPriceSet

useWholeSalePrice

pricesList

priceUuid

unitsList

unitUuid

Do not assume that revenue / quantity always represents the original unit selling price. The revenue field may already contain a line total or reflect particular discount or custom-price conventions.

Reuse existing pricing utilities. Do not reconstruct historical unit prices from current product prices when reliable transaction-level information is available.

Where the original unit price cannot be established reliably, display an appropriate unavailable value rather than inventing one.

13. Discount
Display the applicable discount associated with the individual item record.

Inspect the meaning of discount, fixedDiscount, and discountedAmount in existing sales processing.

Requirements:

Distinguish percentage-based discounts from fixed monetary discounts according to Stockall's established conventions.

Avoid counting the same discount twice.

Respect custom prices and fixed total-price sales.

Preserve the existing rules for group quantities and unit-based pricing.

Handle missing historical discount data safely.

Do not assume every discount is a percentage or that discountedAmount is always the final discount amount without verifying its usage.

14. Original Cost
Display the item's original cost using originalCost, following the existing meaning and conventions of that field.

Inspect whether the value represents a per-unit cost, a line-level cost, or another cost measure before implementing the display.

Do not multiply or divide it by quantity unless the stored meaning and existing calculations require that operation.

15. Cost Price
Display the applicable item cost using costPrice and existing cost-calculation logic.

Inspect the relationship between originalCost, costPrice, product quantities, units, and any existing cost-price conversions.

Avoid double-counting costs or using the product's current cost as a replacement for reliable historical transaction cost data.

Where the historical cost is unavailable, do not fabricate a value.

16. Department
Display departmentName.

Show this column only when the existing Department Management setting is enabled.

For records without a department assignment, display:

No Department

Use the existing department-management settings and conventions. Do not confuse department assignments with product categories.

17. Custom Price
Display whether a custom selling price was applied, based on customPriceSet and the existing pricing conventions.

Use a clear and consistent presentation, such as Yes/No or the application's established equivalent.

Inspect whether the field represents a manually specified price or another custom pricing operation before assigning its meaning.

18. Wholesale Price
Display whether the transaction used wholesale pricing, based on useWholeSalePrice and existing pricing conventions.

Use a consistent presentation for true, false, and unavailable historical values.

19. Managed Status
Display whether the product was managed by Stockall inventory management, using isProductManaged and the application's established conventions.

Do not infer historical managed status solely from the product's current configuration if the transaction already stores this information.

20. Transaction Type
Determine the parent transaction type using the existing receipt or transaction model.

Inspect how the application distinguishes:

Sales

Invoice Payment

Order Delivery

Reuse the established transaction-type mapping. Do not classify every item record as an ordinary sale.

Handle missing or unexpected transaction-type values safely rather than silently assigning an incorrect type.

21. Void Status
Display whether the item record is voided using isVoid.

Use a clear visual distinction for voided item records.

Inspect the existing application behaviour for voided items and determine whether they should be included by default, excluded by default, or displayed with a filter.

Do not delete, alter, or silently omit historical voided records.

Financial summaries must follow the same void-handling rules used by Stockall's existing sales and reporting calculations.

22. Wastage
Where applicable, display the wastage associated with the item sale using:

manageSalesWastage

isPercentageWastage

wastageAmount

wastageUnitUuid

quantityType

widthDimension

heightDimension

Inspect the existing wastage implementation before determining how to display the amount.

Requirements:

Distinguish percentage-based wastage from fixed-quantity or fixed-area wastage.

Respect the unit in which fixed wastage was entered.

Use the existing unit relationship associated with wastageUnitUuid.

Respect dimensional-product calculations.

Handle legacy records with missing wastage units according to existing compatibility rules.

Do not assume that every item has wastage.

Do not subtract wastage from quantity or profit twice if the existing sales calculation already accounts for it.

23. Revenue
Display the applicable financial value associated with the individual item record.

Inspect how revenue is stored and calculated throughout Stockall.

Determine whether the field represents the item's gross selling value, discounted line total, or another established measure.

Requirements:

Reuse the existing calculation conventions.

Account for the actual meaning of discountedAmount, discount, and fixedDiscount.

Respect custom pricing and group-unit pricing.

Respect dimensional quantities and wastage where applicable.

Do not treat the amount collected from the customer as the item's revenue unless that matches the existing accounting model.

Do not count invoice payments or order deliveries as additional sales revenue when the existing accounting model treats them as settlement or fulfilment records rather than new sales.

Apply the established void and return rules.

If a value cannot be reliably established from historical information, display an appropriate unavailable value instead of fabricating revenue.

24. Profit/Loss
Display the item's applicable profit or loss using the existing Stockall financial calculation.

Inspect the product-sales reporting calculations and determine how Stockall calculates item-level profit using transaction revenue, cost, discounts, returns, voids, group quantities, and wastage.

Requirements:

Reuse the established profit calculation wherever possible.

Respect the actual meaning of revenue, originalCost, costPrice, and quantity.

Avoid counting discounts twice.

Avoid counting a line's profit twice.

Respect custom pricing, wholesale pricing, and fixed total-price transactions.

Preserve existing dimensional-product and wastage conventions.

Do not assume originalCost alone is sufficient to calculate profit.

Do not assume a missing cost or revenue value is zero.

Do not invent historical profit when the necessary data is unavailable.

Visual presentation:

Positive profit: green.

Negative profit/loss: red.

Zero: neutral styling.

Unknown profit: an appropriate unavailable indicator, not zero.

Use Stockall's existing theme and financial formatting conventions.

25. Profit Margin (%)
Display the item's profit margin as a percentage.

Inspect the existing reports to establish the standard profit-margin formula and revenue denominator.

If Stockall uses:

Profit Margin = Profit / Revenue × 100

reuse that formula consistently.

Requirements:

Use the established item-level profit and revenue values.

Handle zero revenue safely.

Handle negative revenue according to existing reporting conventions.

Handle missing profit or revenue without displaying a fabricated percentage.

Never display NaN or Infinity.

Do not calculate the item margin using a different formula from the rest of Stockall.

4. Search
Provide a search field that searches item records using relevant fields, including:

Item name.

Item identifier, where searchable.

Receipt ID or receipt identifier.

Staff name.

Customer name.

Department name, only when Department Management is enabled.

Item category, where the existing category relationship supports it.

Search should be case-insensitive where appropriate and should work together with all active filters.

Use stable identifiers for matching where appropriate. Preserve existing searchable receipt identifiers and barcode behaviour where the codebase supports it.

Search must operate on the item-record dataset, not merely on the currently visible page.

Do not introduce unnecessary database requests for every keystroke if the existing architecture supports local filtering or a reusable search mechanism.

5. Filters
Implement the following filters. All filters must work together.

A. Item Category Filter
Provide a category selector that allows users to select a product category and display only item records associated with that category.

Requirements:

Obtain categories from Stockall's existing category-management system.

Use the actual category identifier for matching, not just the displayed category name.

Include the appropriate option to clear the filter.

Handle products with missing or deleted category assignments safely.

Do not confuse product categories with departments.

Do not create a new category table or modify the existing database schema for this feature.

Ensure category filtering and the Category column use the same underlying category relationship.

If the existing application supports uncategorised products, provide an appropriate option to filter for them.

B. Item Filter
Provide an item selector that allows users to select a specific product and display only its item records.

Requirements:

Populate the selector using existing products and relevant historical item records for the selected shop.

Use a stable product identifier, such as productUuid or the established product ID.

Do not rely solely on product names, because different products may share the same name.

Handle deleted products and historical item records whose product identifiers are unavailable.

Include an option to clear the filter.

Ensure the filter works with the selected category.

When a category is selected, the item selector should preferably show products belonging to that category. Changing the category must not leave an invalid or contradictory item selection active.

If the selected item does not belong to the newly selected category, clear the item filter or otherwise follow an established, predictable UI convention.

C. Staff Filter
Allow users to select a staff member and display the item records associated with that staff member.

Use existing staff identifiers and names. Prefer stable IDs for matching.

Provide an option to clear the filter.

D. Customer Filter
Allow users to select a customer and display item records associated with that customer.

Use existing customer identifiers and names.

Handle anonymous or walk-in transactions according to existing Stockall conventions.

Provide an option to clear the filter.

E. Date Range Filter
Provide start-date and end-date filters based on the item's createdAt timestamp.

Requirements:

Reuse the existing Stockall date-filtering and business-day utilities.

Respect configured business-day boundaries where applicable.

Do not introduce a separate timezone conversion.

Correctly include records within the selected range.

Handle a missing start date or end date according to the existing reporting conventions.

Validate date ranges and prevent invalid start/end combinations.

Date filtering must remain consistent with the displayed transaction date and time.

F. Department Filter
Show this filter only when Department Management is enabled.

Allow users to select a department and display records assigned to that department.

Requirements:

Match using the existing department identifier where available.

Provide a No Department option for records without a department assignment.

Include an option to clear the filter.

Keep the Department column and department filter consistent.

Do not use the item category as a substitute for the department.

G. Transaction Type Filter
Allow users to filter by the actual parent transaction type supported by Stockall.

Use the established classifications for:

Sales

Invoice Payment

Order Delivery

Inspect how item records are associated with parent transactions before implementing this filter.

Do not infer transaction type from the presence of receiptUuid or invoiceUuid alone if the application's established model provides a more reliable classification.

H. Void Status Filter
Provide a way to display:

All item records.

Non-voided item records.

Voided item records.

Follow the existing Stockall conventions for interpreting nullable isVoid values.

Do not delete or modify voided historical records when filtering.

I. Custom Price Filter
Where useful and consistent with the existing UI, provide a filter for records where customPriceSet is true or false.

Handle missing historical values appropriately.

J. Wholesale Price Filter
Where useful and consistent with the existing UI, provide a filter for records where useWholeSalePrice is true or false.

K. Revenue Range Filter
Allow users to enter minimum and maximum item revenue values.

Apply the filter to the same revenue calculation displayed in the Revenue column.

Requirements:

Support decimal monetary values.

Validate the minimum and maximum.

Prevent invalid ranges.

Handle missing historical revenue safely.

Do not silently classify unknown revenue as zero.

L. Profit/Loss Range Filter
Allow users to specify minimum and maximum item profit/loss values.

Requirements:

Support negative values to find loss-making transactions.

Support positive values to find profitable transactions.

Apply the range to the same profit calculation displayed in the Profit/Loss column.

Validate minimum and maximum values.

Handle missing profit data explicitly rather than treating unknown profit as zero.

M. Quantity Range Filter
Where consistent with the existing reporting architecture, allow users to filter item records by minimum and maximum recorded quantity.

Respect the item's recorded unit and quantity conventions.

Do not compare incompatible measurement units as though they represented the same quantity. Avoid applying an area conversion to individual-piece quantities unless Stockall's existing unit system explicitly supports it.

N. Filter Behaviour
All active filters must work together.

For example, users should be able to:

Select an item category.

Select a specific item within that category.

Select a staff member.

Select a customer.

Restrict the results to a date range.

Select a department.

Restrict the transaction type.

Display only voided or non-voided records.

Apply revenue and profit ranges.

Requirements:

Provide a way to clear individual filters.

Provide a Reset All Filters action.

Preserve the search query when filters change.

Preserve active filters when sorting changes.

Update the item selector appropriately when the category changes.

Recalculate pagination after filtering.

Display an appropriate empty state when no records match.

Ensure that filter comparisons use the same underlying values and calculations as the table columns.

Do not reset unrelated filters when one filter changes.

6. Sorting
Support ascending and descending sorting by at least the following fields:

Item name.

Item category.

Receipt ID.

Staff name.

Customer name.

Created date.

Quantity.

Selling price.

Revenue.

Profit/loss.

Profit margin.

Additional sorting fields may be included where appropriate.

Requirements:

Sort the complete filtered dataset before pagination.

Use numeric comparisons for quantities and monetary values.

Use chronological comparisons for dates.

Use case-insensitive comparisons for names where appropriate.

Handle nullable values consistently.

Handle missing historical financial values without silently treating them as zero.

Preserve the active filters and search query when sorting changes.

Provide a clear visual indication of the active sort column and direction.

Sorting by profit, revenue, and profit margin must use the same values and formulas displayed in the table.

7. Pagination and Performance
Inspect the existing Stockall report-table architecture and reuse its pagination approach.

Requirements:

Apply search and filters before sorting.

Apply sorting before pagination.

Calculate or prepare item-level financial summaries without repeating expensive calculations on every widget rebuild.

Avoid unnecessary database requests and repeated Hive reads.

Reuse already loaded data where appropriate.

Respect the currently selected shop and existing access-control rules.

Recalculate the page count when the filtered dataset changes.

Reset or clamp the current page when the current page is no longer valid.

Ensure pagination remains correct after changing the item category, item, date range, search, or any other filter.

Keep the table usable on Windows, web, and mobile wherever the existing report architecture supports those platforms.

The intended processing order is:

Retrieve the applicable item records.

Associate each record with the correct product, category, and parent transaction where necessary.

Prepare the required display and financial values.

Apply the search query.

Apply all active filters.

Sort the filtered dataset.

Calculate the filtered result count.

Paginate the sorted results.

Render the table.

If local calculations are required, ensure the complete relevant dataset is processed before pagination. Do not paginate raw records first and then filter only the currently visible page.

Use server-side filtering where appropriate to the existing data architecture. Ensure that server-side pagination does not cause incorrect results when a filter depends on locally calculated financial values.

8. Financial Calculation Integrity
The Item Records Table must agree with the existing Stockall financial reports.

Before implementing financial calculations, inspect the existing usage of:

revenue

discountedAmount

discount

fixedDiscount

originalCost

costPrice

quantity

useGroupQuantity

qttyPerGroup

customPriceSet

useWholeSalePrice

setTotalPrice

quantityType

widthDimension

heightDimension

manageSalesWastage

isPercentageWastage

wastageAmount

wastageUnitUuid

isVoid

Requirements:

Reuse established calculation utilities.

Do not assume fields with similar names have identical meanings.

Do not calculate discounts twice.

Do not double-convert quantities.

Do not use current product prices to overwrite historical transaction values.

Do not count voided transactions or returns incorrectly.

Do not count invoice payments as additional item sales unless the existing accounting model explicitly requires it.

Do not count order delivery records as additional sales revenue when they represent fulfilment of an existing sale.

Do not invent missing cost, revenue, profit, or margin values.

Do not persist newly calculated historical values merely to populate the table.

Do not modify historical transactions or receipt records.

When historical records lack sufficient data for a reliable calculation, represent the missing value explicitly and handle filtering and sorting consistently.

Profit/loss
Use the established Stockall item-level profit/loss formula. Confirm whether the stored revenue and cost values are per-unit or line-level values before calculating anything.

The displayed profit must not double-count quantity, discounts, returns, or wastage.

Profit margin
Use Stockall's existing profit-margin formula and revenue denominator.

If the established formula is profit divided by revenue multiplied by 100, follow it consistently. Handle zero revenue and missing financial data safely.

Revenue
Use the same meaning of revenue established by the existing application.

Do not substitute collected cash, invoice settlement amounts, or the current selling price for historical item revenue without verifying that this matches Stockall's accounting conventions.

Historical data
Some older records may have missing product relationships, unit information, costs, or other fields.

Handle such records safely without crashing or presenting invented financial values.

9. UI and Project Conventions
Follow Stockall's existing:

Theme and colour palette.

Typography and spacing.

Table and report layouts.

Currency and number formatting.

Date and time formatting.

Filter controls and dropdowns.

Responsive layout conventions.

Empty states and loading indicators.

Navigation and page architecture.

Do not redesign unrelated pages or unnecessarily change navigation.

The Category and Item filters should be easy to locate and use. If the existing report UI supports an expandable filter panel, reuse it rather than introducing a completely different filtering experience.

The Item selector should remain usable even when the shop has a large product catalogue. Follow existing conventions for searchable dropdowns or product selection controls.

Keep the implementation maintainable. Introduce shared helpers only where appropriate and avoid unnecessary abstractions.

10. Permissions and Sensitive Files
You may inspect relevant source files, trace dependencies, implement the table, and modify ordinary Dart source files needed for the task without repeatedly requesting permission.

Do not make unrelated changes.

Do not modify sensitive project configuration files, including:

pubspec.yaml

Android manifests.

Gradle files.

Signing configuration.

Build-critical settings.

If a change to any of these files is genuinely necessary, stop and explain the reason before proceeding.

Do not delete existing code or data merely because it appears unused without verifying its role.

Do not modify Hive field indexes or adapters, Supabase schemas, or persisted historical transactions for this feature.

11. Testing and Verification
After implementation, run the relevant tests and available Dart/Flutter static analysis.

Verify the following:

The table displays one row per item record rather than one row per receipt.

All 25 specified columns display the correct information.

Category information is obtained from the correct product-category relationship.

Filtering by item category works.

Filtering by item works.

Changing the selected category handles an incompatible item selection correctly.

Staff and customer filters work.

Date-range filtering follows Stockall's business-day conventions.

Department filtering and its conditional visibility work.

Sub-staff visibility follows the Manage Bulk Sale setting.

Transaction-type filtering uses the correct parent transaction.

Void-status filtering works.

Custom-price and wholesale-price filters work where implemented.

Revenue and profit/loss ranges work, including negative profit values.

Quantity filtering respects the relevant measurement conventions.

Search works across the supported fields.

All filters can be combined and individually cleared.

Reset All Filters clears every applicable filter.

All required sort fields support ascending and descending sorting.

Sorting is applied before pagination.

Pagination remains correct after search, filtering, and sorting.

Group quantities are not double-converted.

Dimensional products are represented using the existing area and quantity conventions.

Wastage is not double-counted.

Discounts, custom prices, wholesale prices, costs, revenue, and profit/loss follow existing calculations.

Profit margin handles zero revenue and missing data safely.

Voided records and invoice-related transactions follow established reporting rules.

Missing product details, nullable IDs, and missing historical financial values do not crash the table.

The table respects the selected shop and existing access-control rules.

Existing Hive adapters, stored transactions, and application configuration remain compatible.

Do not claim a test passed unless it was actually executed and its result verified.

12. Final Implementation Report
At completion, provide a concise report stating:

The files created or modified.

The table columns implemented.

The filters and sorting options implemented.

How item categories and products are identified.

How item records are associated with their parent receipts and other transactions.

Which existing calculation and data-access utilities were reused.

The formulas and conventions used for selling price, discount, cost, revenue, profit/loss, and profit margin.

How group quantities, dimensional products, wastage, and voided records are handled.

The tests and static analysis performed and their actual results.

Any unresolved issues or limitations involving historical records.

Do not stop after building the visual table. Complete the filtering, sorting, calculations, pagination, and verification.

If an existing calculation or relationship is ambiguous, inspect its usage throughout Stockall before deciding how to implement it. Prioritize consistency with the application's established financial logic and data model over introducing new assumptions.