# LAN sync: how it fits the app

Each entity still has one provider (online work) and one Hive Func per box (offline work). LAN sync does **not** add a third class per entity. Instead:

- **On a till**, one switch, `backend()`, decides where every provider query goes: Supabase, the store server, or nowhere (offline).
- **On the store server**, each entity has a **table definition** in [`rest/`](rest/). It says how the server answers that table from its Hive boxes, and which of the app's own queues a write goes into.

So the LAN part of an entity is one declaration, not a third copy of its logic. The provider and the Func are the same code on every device.

## Device states
Decided by `LanRouting` ([`lan_routing.dart`](lan_routing.dart)) and held in `RemoteRouter.route` ([`../remote/remote_client.dart`](../remote/remote_client.dart)).

| State (`LanRoute`) | When | `backend()` returns | `ConnectivityProvider.isConnected` |
|---|---|---|---|
| `standalone` | No store server for this store, or signed out | Supabase, as before | A network interface is up |
| `server` | This desktop serves the store | Supabase (the server syncs like any device) | A network interface is up |
| `lanUp` | A till whose store server answers | A LAN client that sends every request to the server over pinned TLS ([`../remote/lan_remote.dart`](../remote/lan_remote.dart), [`../remote/lan_http_client.dart`](../remote/lan_http_client.dart)) | `true` |
| `lanDown` | On the store's network, but the server isn't answering | A client whose every request fails as a network error, so the providers' existing offline path runs and queues wait | `false` |
| `offLan` | A till away from the store's network | Supabase directly; each sync first replays what the server took but hasn't synced (handoffs) | A network interface is up |

## Trace 1: creating a product
1. **`DataProvider.createProduct`** ([`providers/data_provider.dart`](../../providers/data_provider.dart)) writes the product to `ProductsFunc().productBox` and queues it in `CreatedProductFunc`, then calls `syncData()`. This is unchanged.
2. **`syncData()`** checks `isConnected` (route-aware, per the table above). It runs `RemoteRouter.beforeSync` (off the LAN, this replays handoffs), then `createProductsSync()`, which calls `supabase.from('products')…`. In every provider, `supabase` is `backend()`.
3. **Where it goes:**
   - `standalone`, `server`, `offLan`: Supabase. Done.
   - `lanDown`: the request fails like being offline, and the entry stays queued until the next sync on `lanUp` or `offLan`.
   - `lanUp`: `POST /rest/v1/products` goes to the store server. Steps 4–6 follow.
4. **On the server**, [`lan_server.dart`](lan_server.dart) hands the request to `HiveRestEngine` ([`rest/hive_rest_engine.dart`](rest/hive_rest_engine.dart)). The engine looks up the `products` table definition, `productsTable` in [`rest/lan_table_registry.dart`](rest/lan_table_registry.dart). Product writes run under the stock lock.
5. **The table's writes**, `productWrites()` in [`rest/lan_table_writes.dart`](rest/lan_table_writes.dart), put the row in the server's `ProductsFunc` box and queue it in the server's `CreatedProductFunc`. This is the same offline path the app uses. The server then runs its own `syncData()`, which pushes the product to Supabase.
6. **Back on the till**, the queue entry is deleted as after Supabase. A copy is kept as a *handoff* ([`lan_handoffs.dart`](lan_handoffs.dart)) until the server says it has synced it (`GET /v1/handoff/status`). The server says so only when its sync isn't running and every queue its LAN writes add to is empty (`serverQueuesEmpty` in [`lan_routing.dart`](lan_routing.dart), built from `lanQueues()`): the entities' created/updated/deleted queues, the stock and account queues, the logo queue, and queues `isSynced()` never looked at, such as expense categories and error logs. If the till leaves the LAN first, it replays the copy to Supabase itself. Meanwhile the server's invalidator ([`sync/lan_invalidator.dart`](sync/lan_invalidator.dart)) tells the other tills that `products` changed, and they refetch.

## Trace 2: a sale with stock holds and checkout
1. **Adding to the cart:** `SalesProvider.holdInCart` calls `LanStockClient.hold` ([`stock/lan_stock_client.dart`](stock/lan_stock_client.dart)). On a till on `lanUp`, that calls the RPC `lan_stock_reserve` on the server. On the server desktop's own till, it makes the same call in-process (`LanTransport.stockLink`). On the server, `LanStockService` ([`stock/lan_stock_service.dart`](stock/lan_stock_service.dart)) holds the stock under the stock lock, or refuses with what is available.
   - Every till gets a `stock` event and shows what is held elsewhere.
   - On `lanDown` the change is allowed (nothing can be asked). On `standalone` and `offLan` nothing is held.
2. **Checkout:** `SalesProvider._lanCheckout` calls `LanStockClient.checkout` (RPC `lan_checkout`). In one step this applies the sale's stock changes and releases the cart's holds. The changes are `update_product_quantities` deltas ([`rest/lan_delta_rpcs.dart`](rest/lan_delta_rpcs.dart)), each applied once per `hiveUuid`.
   - The server queues the change for Supabase ([`rest/lan_delta_registry.dart`](rest/lan_delta_registry.dart)).
   - When the till's own queued stock change for the same sale arrives later, it is recognised by its `hiveUuid` and not applied twice.
   - The receipt itself syncs as in Trace 1 (table `receipts`).
3. **If the server can't be reached at checkout,** the checkout is kept on the till and sent when the server is back.
4. **A till that drops** loses its holds `LanConstants.holdGrace` (20 s) after its last socket closes. They can also be released by hand under Settings › Store Network › Devices.

## Trace 3: a pull from Supabase (server only)
1. **`LanServerScheduler`** ([`sync/lan_server_scheduler.dart`](sync/lan_server_scheduler.dart)) ticks while the server is online and runs `LanPuller` ([`sync/lan_puller.dart`](sync/lan_puller.dart)).
2. **The first backfill goes in groups**, set in `lanPullPlans`: first the store and its lists, then what a sale needs, then documents. After that it pulls incrementally by each table's cursor column (cursors are kept in `LanPullCursorsFunc`).
3. **Each pulled row goes to the table's `LanPullStore`:** the main box only, no queue. A row with local work still queued is never overwritten. Stock changes still queued are added back on top ([`sync/lan_pending_deltas.dart`](sync/lan_pending_deltas.dart)), so stock never rolls back.
4. **The invalidator tells the tills,** and they refetch from the server. Tills on `lanUp` never pull from Supabase themselves.
5. **While the server pulls,** `LanServerSync.pullerActive` ([`sync/lan_server_sync.dart`](sync/lan_server_sync.dart)) makes the server's providers skip their own Supabase fetches.

## Where each entity's server-side table lives
| Entities | Definition | Writes |
|---|---|---|
| products, receipts, invoices, orders, customers, expenses | [`rest/lan_table_registry.dart`](rest/lan_table_registry.dart) (`productsTable`, …) | [`rest/lan_table_writes.dart`](rest/lan_table_writes.dart) (`productWrites`, …) |
| drafts, customer_account_receipts, categories, departments, suppliers, sub_staff, storage_products, storage_item_history, item_history, inventory_updates, event_logs, error_logs, purchases, production_materials, production_materials_usage, production_items, production_item_history, production_materials_item_history, production_records, expense_categories | [`rest/lan_more_tables.dart`](rest/lan_more_tables.dart) (registered in `moreLanTables`) | Same file, through `queuedWrites` / `appendOnlyWrites` ([`rest/lan_queued_writes.dart`](rest/lan_queued_writes.dart)) |
| shops, users, permissions | [`rest/lan_store_tables.dart`](rest/lan_store_tables.dart) | Shop settings in the same file; `users` writes are forwarded to Supabase (see below) |
| Stock and account changes: RPCs `update_product_quantities`, `update_materials_quantities`, `update_production_items_quantities`, `update_customer_account` | [`rest/lan_delta_registry.dart`](rest/lan_delta_registry.dart) | Applied once by [`rest/lan_delta_rpcs.dart`](rest/lan_delta_rpcs.dart) |
| Cart holds: `lan_stock_reserve`, `lan_stock_sync`, `lan_stock_release`, `lan_checkout` | [`stock/lan_stock_service.dart`](stock/lan_stock_service.dart) | — |
| Internet-only: subscription, subscription_payments, app_version, utility_constants, notifications (and 2 RPCs) | `LanConstants.onlineOnlyTables` / `onlineOnlyRpcs` in [`lan_constants.dart`](lan_constants.dart) | Forwarded to Supabase while the server is online, refused otherwise |

Which tables the server pulls, and in what order: `lanPullPlans` in [`sync/lan_puller.dart`](sync/lan_puller.dart).

**What the server forwards to Supabase** (`users` writes, the internet-only tables and RPCs, writes for another store) goes out with the **server's own Supabase session**, not the till's. So the server checks the till's permissions first (`LanAccessPolicy`, including an RPC map), then limits the request to this store ([`rest/lan_online_scope.dart`](rest/lan_online_scope.dart)):
- `users` updates and deletes must name one member of this store by `user_id=eq.`; the owner's row only for the owner; no upserts;
- `notifications` get `shop_id=eq.<this store>`, and `mark_all_notifications_viewed` only for this store;
- `subscription` and `subscription_payments` get `user_id=eq.<this store's owner>`, and the payments RPC's answer is filtered to that owner;
- `app_version` and `utility_constants` are read-only.

## Trust between devices
- **Pairing is done by a person:** the code shown on the server, or its QR code (valid for 10 minutes). The till pins the server's certificate and gets a secret; the server keeps only its hash ([`../../local_database/lan/lan_paired_devices_func.dart`](../../local_database/lan/lan_paired_devices_func.dart)). Only paired devices may sign in (`/v1/auth/login` refuses others with `not_paired`, and the till's status then asks to pair again). Pairings from before this rule must be made again.
- **A stored password goes only to a trusted certificate:** one a person paired, or one *vouched for* by a move (below). A server proven only with the shop key is never followed automatically; the status shows "Pair again".
- **Vouched moves:** a server that steps down broadcasts a `moved` event signed with its own TLS key, naming the new server and listing the devices paired with it ([`lan_move_proof.dart`](lan_move_proof.dart)). A till follows it only if the signature matches the certificate it pinned, keeps the event until its first sign-in there, and presents it; the new server accepts it if the signer is a former server it proved it outranks (or one it trusts itself) and the event lists that till, then gives the till its own secret.
- **Epochs** may jump at most `LocalServerRecord.maxEpochJump` (2) above the highest this device knows.
- **The shop key** a device holds is never replaced by one a login answer carries.

## Adding a table or a provider function
1. **Do everything the app already needs:** the model, its unsynced wrappers, a Func per box registered in `initHive()`, the provider's `*Sync()` methods, and a step in `syncData()` (see `CLAUDE.md`).
2. **In the provider,** query through `SupabaseClient get supabase => backend();`, never `Supabase.instance.client`. Guard the provider's own fetch-and-store from Supabase with `!LanServerSync.pullerActive`, like the other providers' `isSynced()` checks.
3. **Add the server table** in [`rest/lan_more_tables.dart`](rest/lan_more_tables.dart) and add it to `moreLanTables`:
   - columns: the `toJson` keys the app filters or sorts on;
   - `shopIdOf`, and its department rule (match the provider's `matchesCurrentDepartment` call);
   - `writes:` `queuedWrites(...)` naming the **same main box and created/updated/deleted queues** as the app's offline path, or `appendOnlyWrites` for logs;
   - a `LanPullStore`.

   Without a definition, the server answers "unknown table" and the till's request fails.
4. **Pull it:** add it to `lanPullPlans`, with its group and cursor column.
5. **A new RPC:**
   - every RPC needs an entry in `LanAccessPolicy`'s RPC map ([`lan_access_policy.dart`](lan_access_policy.dart)) naming the permissions whose screens call it; one that isn't there is refused;
   - a stock or account change goes in [`rest/lan_delta_registry.dart`](rest/lan_delta_registry.dart) and `LanConstants.deltaRpcs`;
   - an internet-only one goes in `LanConstants.onlineOnlyRpcs`;
   - anything else is answered "unknown function" on the LAN.
6. **Filters:** the server answers PostgREST filters itself. A filter or select form it doesn't support is refused with `PGRST100`, so add a read test in `test/lan_engine_read_test.dart` for any new one.
7. **Internet-only screens:** wrap their entry points in `OnlineOnly` ([`../../components/online_only.dart`](../../components/online_only.dart)), so they hide on a till while the store server is offline.
8. **Tests:** update [`test/lan_registry_parity_test.dart`](../../../test/lan_registry_parity_test.dart). It checks every table's columns against `toJson` and the table count. Add a write test in `test/lan_engine_write_test.dart`.

**Hive type IDs:** the usual rule applies to LAN models (`lib/classes/lan/`). Take the next ID and bump `highestHiveClassIndex`.
