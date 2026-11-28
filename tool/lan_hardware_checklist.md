# LAN sync: hardware checklist

These rows cover what the in-process tests can't: real mDNS, real network interfaces, OS prompts and firewalls, cameras, and pulling plugs. Each row is driven from the app, mostly from **Settings › Store Network**. This file replaces `lan_p2_hardware_checklist.md`, which held the P2 and P3 rows; the rows from P6, P7, P8 and P10 are merged in here.

## Before you start
- **Supabase (test project):** run both migrations in `supabase/migrations/`: `*_manage_local_server_permission.sql` and `*_shops_lan_key.sql`.
- **The tester:** give them the **Manage Local Server** permission. Keep a second user without it for the rows that check permission.
- **Builds:** from `feat/lan-sync`. Use `flutter run -d <device>` unless a row says Release or MSIX.
- **The store server:** a desktop. While it is online, open Settings › Store Network › **Make this desktop the store server** and type your password. This also loads staff sign-ins from the cloud.
- **Pairing a till:** on the till, open Settings › Store Network. Use **Find the store server**, **Type its address**, or **Scan QR code** (on a phone; the server shows the code under **Show QR code**). Then type the 8-character code the server shows.
- **Record for every row:**
  - the OS and version of each device;
  - the link (Wi-Fi, Ethernet, or a direct cable with no router);
  - the server's `mainLog.log` lines that start with `LAN`;
  - pass or fail.

**Devices:**

| Name | Device |
|---|---|
| Mac | macOS 15 desktop or laptop |
| Win | Windows 11 desktop, unpackaged and MSIX builds |
| Android | Android phone |
| iPhone | iPhone |

## 1. Discovery and connection
| # | Server | Till | Link | Expected | Also record |
|---|---|---|---|---|---|
| 1.1 | Mac | Win | Same Wi-Fi | **Find the store server** lists the server; pairing and connecting succeed | The addresses found |
| 1.2 | Mac | Win | Ethernet switch | As 1.1 | Whether fe80 addresses carry a `%zone` |
| 1.3 | Mac | Win | Direct cable, no router | Found over 169.254.x.x or fe80, and connected | Which address won |
| 1.4 | Win | Mac | Direct cable | As 1.3 | As 1.3 |
| 1.5 | Mac | Android | Wi-Fi | Found and connected | Android version; any permission prompt |
| 1.6 | Mac | iPhone | Wi-Fi | The Local Network prompt appears; after allowing, found and connected | The prompt text |
| 1.7 | Mac | any | Wi-Fi with client isolation or multicast blocked | Find shows nothing. **Type its address**, the QR code, or the last known address still reaches the server | Which way worked; how long it took |
| 1.8 | Mac | Android | Wi-Fi | After a release build, the merged Android manifest has the permissions bonsoir needs (`CHANGE_WIFI_MULTICAST_STATE`, `ACCESS_WIFI_STATE`) or discovery works without them | `build/app/outputs/logs/manifest-merger-*.txt` |

## 2. Pairing
| # | Setup | Expected | Also record |
|---|---|---|---|
| 2.1 | Typed code, correct | The server shows an 8-character code; the till accepts it, says "Paired and signed in", and the status shows **Connected** | Time from Find to paired |
| 2.2 | Typed code, one character wrong | "The code doesn't match…"; nothing saved; the server's code goes **at once** | |
| 2.3 | Right after 2.2, a second till starts pairing | It isn't told "busy": it gets its own code straight away | |
| 2.4 | A till is pairing; tap **Cancel this pairing** on the server | The code goes; typing it on the till doesn't pair; the till can start again | |
| 2.5 | QR code scanned on Android and on iPhone | Paired and signed in without typing | Camera prompt text |
| 2.6 | A till signed in with a password the server doesn't know (changed elsewhere) | After pairing it asks for the password; the right one signs in | |
| 2.7 | Six pairing starts within a minute | The sixth is refused (rate limited) | |
| 2.8 | Pair a Mac laptop by code as a second till | As 2.1 | |
| 2.9 | A second till starts while another is mid-pairing (code shown, not typed yet) | The second is told the server is busy until the first finishes, mistypes, or is cancelled | |

## 3. Signing in on the store network
| # | Setup | Expected | Also record |
|---|---|---|---|
| 3.1 | Phone with no internet, paired with a Mac server; sign in as an employee, then as the owner | Both sign in; afterwards the login page works offline on the phone | Time from Login to the home page |
| 3.2 | Wrong password | The standard "Login Failed" message | |
| 3.3 | Six wrong passwords for one email | The sixth shows "Too many sign-in attempts…" | |
| 3.4 | Employee removed in Supabase, then the server restarts while online | Their login fails and their existing session stops working | |
| 3.5 | Password changed in the app, then the server restarts while online | The new password works on the store network and the old one fails | |
| 3.6 | Paired server switched off | Login falls back to the normal (online) flow within about 6 s | Seconds before the fallback |

## 4. Status, the server's internet, online-only screens
| # | Setup | Expected | Also record |
|---|---|---|---|
| 4.1 | Dashboard on each device | The app bar shows the status: a chip on desktop, a dot on a phone (hover or long-press explains). Nothing on a device without a store server | Screenshot |
| 4.2 | Make a desktop the server with a fresh install while online | "Store server · loading" and "Loading store data from the cloud (…)" until done; the Store Network page shows a progress bar | How long it takes |
| 4.3 | Unplug the server's internet; keep the store network up | On the tills, these hide: notifications (drawer, side bar, bell), subscription buttons ("Available when the store server is back online."), the update check, and Forgot / Change Password. They come back when the internet does | Seconds to hide and to return |
| 4.4 | As 4.3, on the server itself | Its screens are as before (it is online or not by itself) | |

## 5. The server and the cloud
| # | Setup | Expected | Also record |
|---|---|---|---|
| 5.1 | Make a desktop the server with a fresh install while online | The products and stock screens fill in before the receipts do; a till sees products within a minute | |
| 5.2 | Edit a product on a device off the store network (straight to Supabase) | A till on the network shows the change within about 60 s, without reopening the screen | |
| 5.3 | Sell on the server with its internet off, then reconnect | Stock never jumps back while the sale is still queued; then everything reaches Supabase with the right quantities | Supabase quantities before and after |
| 5.4 | Delete a product on Supabase | It disappears from the server by the next daily reconcile, or at once if you trigger the reconcile | |

## 6. Cart stock holds
| # | Setup | Expected | Also record |
|---|---|---|---|
| 6.1 | Two tills and the server's own till; one adds the last unit | Refused on the others; once it is removed, another till can take it | |
| 6.2 | Kill a till with a cart open | About 20–40 s later the others can sell its stock. Restarted, its conflict dialog lists what it lost | Seconds to release |
| 6.3 | A till's holds on the server: Store Network › Devices › **Release this device's holds** | The stock is free on every till at once | |
| 6.4 | On a till: Store Network › **Stock held by this device** › Release | As 6.3 | |
| 6.5 | Unplug the server | The banner shows on tills, sales go through, and after reconnecting the stock is right (or reported below zero) | |
| 6.6 | Check out on a till while the server is briefly unreachable | The holds stay until it is back, then release when the checkout arrives | |
| 6.7 | Edit a receipt to add 2 units | Only 2 are held | |

## 7. Failover
| # | Setup | Expected | Also record |
|---|---|---|---|
| 7.1 | Till on Ethernet and Wi-Fi; unplug Ethernet | It reconnects over Wi-Fi within a few seconds | Seconds to reconnect |
| 7.2 | The server app quits | Tills show **Server not answering** and keep selling | |
| 7.3 | The server restarts | It serves again by itself; tills reconnect to the same server | |

## 8. One server per store
| # | Setup | Expected | Also record |
|---|---|---|---|
| 8.1 | A second desktop tries **Make this desktop the store server** while the first serves | "Another desktop already serves this store." | |
| 8.2 | **Remove the store server** on the serving desktop | Its tills go to working on their own; the record shows cleared | |
| 8.3 | A phone last saw epoch 7; a desktop that knew 5 makes itself the server | Its claim gets epoch 8 | |
| 8.4 | Split the network and make a server on both halves; sell on both with a till on each; then rejoin | Within about 30 s one stops serving and its till follows. Nothing is lost: receipts and stock changes are applied once. Conflicts are shown, and the alert lists products below zero | Seconds to settle |
| 8.5 | Pull the server's plug; on a manager's phone, Store Network | "Clear the store server (in N s)" counts down from 60; after that, with the password, it clears; the alert lists stock changes still held | |
| 8.6 | After 8.5, make the other desktop the server; then power the old one back up | The old one doesn't serve, and its tills move to the new one | |
| 8.7 | Restart a desktop that stopped serving (8.4 or 8.6) | It stays a till | |
| 8.8 | Store Network › alerts, as a manager | Each alert is listed, newest first, and opens with its table (a table on desktop, cards on a phone) | |
| 8.9 | The same pages as a user without Manage Local Server | No server role, devices or alerts; pairing and their own held stock only | |

## 9. Windows firewall and MSIX
| # | Setup | Expected | Also record |
|---|---|---|---|
| 9.1 | Unpackaged server, Private network | A firewall prompt the first time it serves; after allowing, tills connect | Prompt text; which boxes are ticked |
| 9.2 | Unpackaged server, Public network or direct cable | Tills connect only if Public was allowed | Both ways |
| 9.3 | MSIX (`internetClient,privateNetworkClientServer,internetClientServer`), Private network | Tills connect | Any prompt |
| 9.4 | MSIX as 9.3, Public network or direct cable | Tills connect | Any prompt |

## 10. Apple platforms
| # | Setup | Expected | Also record |
|---|---|---|---|
| 10.1 | macOS 15 server, Release build | Local Network prompt; serving works after allowing; the `network.server` entitlement is honoured | |
| 10.2 | macOS with the customer display (second window) open | Only the main window serves; the second window never starts a server | |
| 10.3 | iPhone till, Release build | The Local Network prompt names the store server; Find works after allowing | Prompt text |

## 11. The whole store, start to finish
No internet anywhere. Mac server, a Win till on a direct cable, and an Android phone on Wi-Fi.
1. Pair both tills and sign in on both; both load the same dashboard.
2. Two cashiers add the last unit: the second is refused. One removes it, and the other can now add it.
3. Kill a till with a cart open: its stock stays held for about 20 s after it drops, then is released.
4. Connect the server to the internet: everything reaches Supabase with the right quantities.
5. Split the network and make a server on both desktops, then rejoin: one stops serving, nothing is lost, and the manager is alerted.

## Optional: Linux
| # | Server | Till | Link | Expected | Also record |
|---|---|---|---|---|---|
| L.1 | Mac | Linux | Ethernet switch | As 1.1 | Whether fe80 addresses carry a `%zone` |
| L.2 | Linux | Win | Direct cable | Connects over fe80 with a zone | Whether Linux has any IPv4 on the cable |
