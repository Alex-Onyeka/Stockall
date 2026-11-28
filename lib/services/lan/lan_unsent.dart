import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';

/// Changes made on the store network that this device still holds:
/// handoffs not yet sent to the store server or Supabase, and checkouts
/// the store server hasn't confirmed. A logout or store switch waits for
/// them (kept over it, they would wait unsent until this store is signed
/// in again). Null when there are none.
String? lanUnsentMessage({
  required String before,
  int Function()? handoffs,
  int Function()? checkouts,
}) {
  final h = (handoffs ?? () => LanHandoffs().all().length)();
  final c = (checkouts ?? () => LanPendingCheckoutsFunc().all().length)();
  if (h == 0 && c == 0) return null;
  final parts = [
    if (h > 0) '$h ${h == 1 ? 'change' : 'changes'}',
    if (c > 0) '$c ${c == 1 ? 'checkout' : 'checkouts'}',
  ];
  return 'This device has ${parts.join(' and ')} from the store network '
      'that have not been sent yet. Connect to the store network, or sign '
      'in to sync, and let them send before $before.';
}
