/// Whether generated documents (A4 PDFs, thermal receipts) show the
/// "Created by Stockall" branding watermark.
///
/// TODO: Show only for Free/Basic plans (hide for Premium and above), e.g.
///   final plan = SubscriptionProvider().subscription?.plan;
///   return plan == null ||
///       subPlans.firstWhere((p) => p.plan == plan)
///           .salesAuth.addStockallNameOnReceipt;
/// The existing `addStockallNameOnReceipt` flag in `subscription_func.dart`
/// is currently true for Free only; set it true for Basic too when enabling.
/// Also swap the text for the Stockall logo at that point.
bool shouldShowBrandingWatermark() => false;
