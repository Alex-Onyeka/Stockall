import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/subscription_payment_model.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/sub_payment_provider.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() =>
      _PaymentHistoryPageState();
}

class _PaymentHistoryPageState
    extends State<PaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = Provider.of<ShopProvider>(
        context,
        listen: false,
      );
      final shopUserId = shopProvider.userShop()?.userId;
      Provider.of<SubPaymentProvider>(
        context,
        listen: false,
      ).fetchPaymentHistory(userId: shopUserId);
    });
  }

  void _showPaymentDetails(
    BuildContext context,
    SubscriptionPaymentModel payment,
  ) {
    final theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DialogTemplate(
          theme: theme,
          title: 'Payment Details',
          message: 'Summary of subscription transaction',
          showBottomActionButtons: true,
          showMainBottomActionButton: false,
          cancelText: 'Close',
          cancelAction:
              () => Navigator.of(dialogContext).pop(),
          topRightWidget: IconButton(
            mouseCursor: SystemMouseCursors.click,
            onPressed:
                () => Navigator.of(dialogContext).pop(),
            icon: const Icon(size: 20, Icons.clear),
          ),
          action: () {},
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusBadge(payment.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Plan',
                '${payment.getPlanName()} Plan',
              ),
              _buildDetailRow(
                'Amount',
                formatMoneyMid(
                  amount: payment.amount ?? 0,
                  context: context,
                ),
                isAmount: true,
              ),
              _buildDetailRow(
                'Duration',
                payment.getDurationText(),
              ),
              _buildDetailRow(
                'Payment Date',
                formatDateWithTime(payment.createdAt),
              ),
              if (payment.nextPayment != null)
                _buildDetailRow(
                  'Valid Until',
                  formatDateTime(payment.nextPayment!),
                ),
              if (payment.paymentChannel != null &&
                  payment.paymentChannel!.isNotEmpty)
                _buildDetailRow(
                  'Channel',
                  payment.paymentChannel!.toUpperCase(),
                ),
              if (payment.reference != null &&
                  payment.reference!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Reference',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            SelectableText(
                              payment.reference!,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy Reference',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: payment.reference!,
                            ),
                          );
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reference copied to clipboard',
                              ),
                              duration: Duration(
                                seconds: 2,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isAmount = false,
    bool showDivider = true,
  }) {
    final theme = returnTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 9.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight:
                      isAmount
                          ? FontWeight.bold
                          : FontWeight.w600,
                  color:
                      isAmount
                          ? theme.lightModeColor.prColor300
                          : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isSuccess = status.toLowerCase() == 'success';
    final isPending = status.toLowerCase() == 'initialized';

    final Color bgColor =
        isSuccess
            ? const Color(0xFFE8F5E9)
            : isPending
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFFFEBEE);

    final Color textColor =
        isSuccess
            ? const Color(0xFF2E7D32)
            : isPending
            ? const Color(0xFFF57F17)
            : const Color(0xFFC62828);

    final String label =
        isSuccess
            ? 'Successful'
            : isPending
            ? 'Pending'
            : 'Failed';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  String _getDateFilterText(SubPaymentProvider provider) {
    if (provider.selectedDate != null &&
        provider.selectedEndDate != null) {
      return '${formatDateTime(provider.selectedDate!)} - ${formatDateTime(provider.selectedEndDate!)}';
    } else if (provider.selectedDate != null) {
      return formatDateTime(provider.selectedDate!);
    }
    return 'All Dates';
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final paymentProvider = Provider.of<SubPaymentProvider>(
      context,
    );
    final payments = paymentProvider.paymentHistory;
    final hasDateFilter =
        paymentProvider.selectedDate != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: appBar(
        context: context,
        title: 'Payment History',
        widget: IconButton(
          mouseCursor: SystemMouseCursors.click,
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            final shop = returnShopProvider().userShop();
            paymentProvider.fetchPaymentHistory(
              userId: shop?.userId,
              date: paymentProvider.selectedDate,
              endDate: paymentProvider.selectedEndDate,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      onTap: () {
                        mainDatePicker(
                          context: context,
                          theme: theme,
                          singleDate: (date) {
                            if (date != null) {
                              paymentProvider.setDateFilter(
                                date,
                              );
                            }
                          },
                          rangeDate: (firstDate, lastDate) {
                            if (firstDate != null &&
                                lastDate != null) {
                              paymentProvider.setDateFilter(
                                firstDate,
                                endDate: lastDate,
                              );
                            }
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color:
                              hasDateFilter
                                  ? theme
                                      .lightModeColor
                                      .prColor300
                                      .withOpacity(0.08)
                                  : Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                hasDateFilter
                                    ? theme
                                        .lightModeColor
                                        .prColor300
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color:
                                  hasDateFilter
                                      ? theme
                                          .lightModeColor
                                          .prColor300
                                      : Colors
                                          .grey
                                          .shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getDateFilterText(
                                  paymentProvider,
                                ),
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      hasDateFilter
                                          ? FontWeight.bold
                                          : FontWeight
                                              .normal,
                                  color:
                                      hasDateFilter
                                          ? theme
                                              .lightModeColor
                                              .prColor300
                                          : Colors
                                              .grey
                                              .shade800,
                                ),
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasDateFilter)
                              GestureDetector(
                                onTap: () {
                                  paymentProvider
                                      .clearDateFilter();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                    left: 4.0,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.lightModeColor.prColor300,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                    onPressed: () {
                      final shop =
                          returnShopProvider().userShop();
                      paymentProvider.fetchPaymentHistory(
                        userId: shop?.userId,
                        date: paymentProvider.selectedDate,
                        endDate:
                            paymentProvider.selectedEndDate,
                      );
                    },
                    icon: const Icon(
                      Icons.sync_rounded,
                      size: 18,
                    ),
                    label: Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize:
                            returnTheme(
                              context,
                            ).mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content List
            Expanded(
              child:
                  paymentProvider.isLoadingHistory
                      ? const Center(
                        child: CircularProgressIndicator(),
                      )
                      : RefreshIndicator(
                        onRefresh: () async {
                          final shop =
                              returnShopProvider()
                                  .userShop();
                          await paymentProvider
                              .fetchPaymentHistory(
                                userId: shop?.userId,
                                date:
                                    paymentProvider
                                        .selectedDate,
                                endDate:
                                    paymentProvider
                                        .selectedEndDate,
                              );
                        },
                        child:
                            payments.isEmpty
                                ? ListView(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.45,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(
                                                    20,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade200,
                                                shape:
                                                    BoxShape
                                                        .circle,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .receipt_long_outlined,
                                                size: 35,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade500,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              'No Payment Records Found',
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .h4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade800,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              hasDateFilter
                                                  ? 'No payments found for the selected date.'
                                                  : 'Your subscription payments will appear here.',
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade600,
                                              ),
                                            ),
                                            if (hasDateFilter) ...[
                                              const SizedBox(
                                                height: 14,
                                              ),
                                              TextButton.icon(
                                                onPressed: () {
                                                  paymentProvider
                                                      .clearDateFilter();
                                                },
                                                icon: const Icon(
                                                  Icons
                                                      .filter_alt_off_rounded,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'Clear Date Filter',
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                  itemCount:
                                      payments.length,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    final payment =
                                        payments[index];
                                    final isSuccess =
                                        payment.isSuccess;

                                    return Container(
                                      margin:
                                          const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),
                                        border: Border.all(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade200,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors
                                                .black
                                                .withOpacity(
                                                  0.02,
                                                ),
                                            blurRadius: 6,
                                            offset:
                                                const Offset(
                                                  0,
                                                  2,
                                                ),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        child: InkWell(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          borderRadius:
                                              BorderRadius.circular(
                                                5,
                                              ),
                                          onTap:
                                              () =>
                                                  _showPaymentDetails(
                                                    context,
                                                    payment,
                                                  ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(
                                                  16.0,
                                                ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                // Top Row: Plan & Amount
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          38,
                                                      width:
                                                          38,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isSuccess
                                                                ? const Color(
                                                                  0xFFE8F5E9,
                                                                )
                                                                : const Color(
                                                                  0xFFFFF8E1,
                                                                ),
                                                        shape:
                                                            BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        isSuccess
                                                            ? Icons.check_circle_outline_rounded
                                                            : Icons.schedule_rounded,
                                                        color:
                                                            isSuccess
                                                                ? const Color(
                                                                  0xFF2E7D32,
                                                                )
                                                                : const Color(
                                                                  0xFFF57F17,
                                                                ),
                                                        size:
                                                            20,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width:
                                                          12,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${payment.getPlanName()} Plan',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b2.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color:
                                                                  Colors.black87,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height:
                                                                2,
                                                          ),
                                                          Text(
                                                            payment.getDurationText(),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              color:
                                                                  Colors.grey.shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          formatMoneyMid(
                                                            amount:
                                                                payment.amount ??
                                                                0,
                                                            context:
                                                                context,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b2.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                theme.lightModeColor.prColor300,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height:
                                                              4,
                                                        ),
                                                        _buildStatusBadge(
                                                          payment.status,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(
                                                  height:
                                                      12,
                                                ),
                                                Divider(
                                                  height: 1,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade100,
                                                ),
                                                const SizedBox(
                                                  height:
                                                      10,
                                                ),

                                                // Bottom Row: Date & Reference preview
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.access_time_rounded,
                                                          size:
                                                              14,
                                                          color:
                                                              Colors.grey.shade500,
                                                        ),
                                                        const SizedBox(
                                                          width:
                                                              5,
                                                        ),
                                                        Text(
                                                          formatDateWithTime(
                                                            payment.createdAt,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            color:
                                                                Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (payment.paymentChannel !=
                                                        null)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal:
                                                              8,
                                                          vertical:
                                                              2,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey.shade100,
                                                          borderRadius: BorderRadius.circular(
                                                            4,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          payment.paymentChannel!.toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize:
                                                                8,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.grey.shade700,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
