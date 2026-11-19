import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';

class StaffSalaryHistorySection extends StatefulWidget {
  final String staffUuid;

  const StaffSalaryHistorySection({
    super.key,
    required this.staffUuid,
  });

  @override
  State<StaffSalaryHistorySection> createState() =>
      _StaffSalaryHistorySectionState();
}

class _StaffSalaryHistorySectionState
    extends State<StaffSalaryHistorySection> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final sid = returnShopProvider().userShop()?.shopId;
    if (sid == null) return;
    if (mounted) setState(() => _loading = true);
    await returnExpensesProvider(
      context,
      listen: false,
    ).fetchSalaryHistoryForStaff(
      widget.staffUuid,
      sid,
      startDate: _startDate,
      endDate: _endDate,
    );
    if (mounted) setState(() => _loading = false);
  }

  List<TempExpensesClass> _filteredSalaries() {
    final sid = returnShopProvider().userShop()?.shopId;
    final all = returnExpensesProvider(
      context,
    ).getSalaryHistoryForStaff(widget.staffUuid, targetShopId: sid);
    if (_startDate == null) return all;
    final start = fourAm(_startDate!);
    final end = fourAmNextDay(_endDate ?? _startDate!);
    return all
        .where(
          (e) =>
              e.createdDate != null &&
              !e.createdDate!.isBefore(start) &&
              e.createdDate!.isBefore(end),
        )
        .toList();
  }

  String _dateLabel() {
    if (_startDate == null) return 'All Time';
    if (_endDate == null ||
        (_startDate!.year == _endDate!.year &&
            _startDate!.month == _endDate!.month &&
            _startDate!.day == _endDate!.day)) {
      return formatDateWithDay(_startDate!);
    }
    return '${formatDateWithDay(_startDate!)} - ${formatDateWithDay(_endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final salaries = _filteredSalaries();
    final totalPaid = salaries.fold<double>(0, (sum, e) => sum + e.amount);

    return Container(
      key: const ValueKey('staff-section-salary-history'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(26, 0, 0, 0), blurRadius: 10),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo.shade50,
                ),
                child: Icon(
                  Icons.payments_outlined,
                  size: 16,
                  color: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'SALARY HISTORY',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade100,
                ),
                child: Text(
                  '${salaries.length}',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b5.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                onPressed: () {
                  if (_startDate != null) {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    _load();
                  } else {
                    mainDatePicker(
                      context: context,
                      theme: theme,
                      singleDate: (date) {
                        if (date == null) return;
                        setState(() {
                          _startDate = date;
                          _endDate = date;
                        });
                        _load();
                      },
                      rangeDate: (first, last) {
                        if (first == null) return;
                        setState(() {
                          _startDate = first;
                          _endDate = last ?? DateTime.now();
                        });
                        _load();
                      },
                    );
                  }
                },
                icon: Icon(
                  _startDate != null ? Icons.close : Icons.date_range_outlined,
                  size: 15,
                ),
                label: Text(
                  _dateLabel(),
                  style: TextStyle(fontSize: theme.mobileTexts.b5.fontSize),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Salary Paid',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
                ),
                Text(
                  formatMoneyMid(amount: totalPaid, context: context),
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
                ),
              ],
            ),
          ),
          if (!_loading &&
              returnExpensesProvider(context).salaryHistoryIsLocal) ...[
            const SizedBox(height: 8),
            Row(
              spacing: 6,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 14,
                  color: Colors.orange.shade800,
                ),
                Expanded(
                  child: Text(
                    'Showing offline data; may be incomplete',
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b5.fontSize,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (_loading && salaries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (salaries.isEmpty)
            EmptyWidgetDisplayOnly(
              svg: expensesIconSvg,
              title: 'No Salary Payments',
              subText: 'No salary payments recorded for this staff member.',
              height: 28,
              theme: theme,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: salaries.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final sal = salaries[index];
                return InkWell(
                  onTap:
                      sal.uuid == null
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ExpenseDetails(expenseUuid: sal.uuid!),
                              ),
                            );
                          },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 3,
                            children: [
                              Text(
                                sal.createdDate != null
                                    ? formatDateWithDay(sal.createdDate!)
                                    : 'Date not set',
                                style: TextStyle(
                                  fontSize: theme.mobileTexts.b3.fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Channel: ${sal.resolvedPaymentChannelLabel}',
                                style: TextStyle(
                                  fontSize: theme.mobileTexts.b4.fontSize,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              if (sal.description != null &&
                                  sal.description!.trim().isNotEmpty)
                                Text(
                                  sal.description!.trim(),
                                  style: TextStyle(
                                    fontSize: theme.mobileTexts.b4.fontSize,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          formatMoneyMid(amount: sal.amount, context: context),
                          style: TextStyle(
                            fontSize: theme.mobileTexts.b3.fontSize,
                            fontWeight: FontWeight.bold,
                            color: theme.lightModeColor.secColor200,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
