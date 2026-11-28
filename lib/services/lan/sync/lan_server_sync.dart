/// Whether this device's LAN server pulls the served store's data from
/// Supabase itself. Pure Dart: every provider reads it, on every
/// platform.
///
/// While it does (from the moment the server starts serving until it
/// stops), the providers' own Supabase fetches are skipped: they
/// replace their whole box (`insertAll…` clears it first), so a LAN client
/// reading during the refill would see an empty table, and they overwrite
/// rows the puller keeps with pending local work. The providers then read
/// Hive, which the puller keeps current, exactly as they do offline.
class LanServerSync {
  LanServerSync._();

  /// Set by the LAN transport when the server starts and stops.
  static bool pullerActive = false;
}
