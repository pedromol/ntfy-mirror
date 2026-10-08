# AGENTS.md

Always-on Android companion: captures notifications (and optional SMS) and forwards them, as JSON, to a user-configured HTTP endpoint. Fork of https://github.com/pedromol/ntfy-mirror. UI on top is in **English** (keep new user-facing strings English).

## Stack

- Flutter/Dart (lib/) + minimal Kotlin (android/app/src/main/kotlin/).
- Android app id / Kotlin package: `br.mol.net.br` (source dir is the historical `lol/arian/notifmirror/` — do not rename to "match", the dir name is just leftovers).
- Dart deps: `http`, `permission_handler`, `package_info_plus`, `url_launcher`. No state-management package — plain `StatefulWidget`.

## Commands

```bash
flutter pub get
flutter analyze                # must stay clean of new issues
flutter test                   # Dart/widget tests (41)
cd android && ./gradlew :app:testDebugUnitTest -x :app:copyFlutterAssetsDebug   # Kotlin tests (7)
flutter build apk --release -t lib/main.dart
```

- Kotlin unit tests fail without `-x :app:copyFlutterAssetsDebug` (Gradle 9 + Flutter AGP implicit-dependency validation error). Keep the flag.
- CI: `.github/workflows/release.yml` builds a signed release APK on tag `v*`/manual dispatch.
- `analysis_options.yaml`: `package:flutter_lints/flutter.yaml`; `android/**` and `build/**` are excluded from analysis.

## Architecture / Key Paths

- `lib/main.dart` — all UI screens live here (ConfigScreen, QueueScreen, AppSelector, PayloadTemplate), plus the background entrypoint `backgroundMain`. Do not scatter new screens into this file; add separate files for large screens like `logs_screen.dart` does.
- `lib/message_stream.dart` — core logic: `MessageStream`, `SendResult` enum, `ValidationReport`, retry queue + backoff, payload rendering and dedup. Receives events on the `msg_mirror` channel.
- `lib/auth/auth.dart` — `AuthType` (none/bearer/apiKey/basic) + `AuthConfig` (produces `headers` map). `lib/auth_settings.dart` is its UI.
- `lib/prefs.dart` — wrappers over `msg_mirror_prefs` (Native Channel-backed prefs). No direct `SharedPreferences` calls in Dart.
- `android/app/src/main/kotlin/.../MainActivity.kt` — registers: `msg_mirror_ctrl` (start/stop service, `postTestNotification`, `cancelTestNotification`), `msg_mirror_prefs`, `msg_mirror_perm`, `msg_mirror_logs`, `msg_mirror_apps`. Also `SecureAuthStore` (AES/GCM via Android Keystore) for auth config.
- `android/app/src/main/kotlin/.../AlwaysOnService.kt` — foreground service; caches engine as `always_on_engine`. `MainActivity` caches `ui_engine`.
- `android/app/src/main/kotlin/.../MsgNotificationListener.kt` — `NotificationListenerService`; filters (allowed packages, skip ongoing/group-summary), logs, then emits via broadcast `br.mol.net.br.NOTIF_EVENT`, direct channel, or native HTTP fallback (`ApiSender`).
- `android/app/src/main/kotlin/.../ValidationCoordinator.kt` — round-trip test: posts a local test notification carrying a token; the listener bypasses filters and confirms the echo.

## Round-trip validation ("Test connectivity + authentication")

Button in `ConfigScreen` → `_runValidation()` → `MessageStream.runValidation()` (`lib/message_stream.dart`):

1. POST a test payload to the endpoint (this is what tests connectivity + auth; 401/403 → "Authentication failed", not retried).
2. Listener gate: notification access granted AND `MsgNotificationListener.isConnected` (`msg_mirror_perm` → `isListenerConnected`/`rebindListener`). If disconnected it requests `requestRebind()` and polls for `listenerWait` (default 4s), then returns an actionable error instead of waiting for the timeout.
3. Post a local test notification with a unique token (`MMV-...`) via `msg_mirror_test` → `ValidationCoordinator`.
4. Wait for the token to come back through `msg_mirror_result` (`onValidationEcho`) within the timeout.

The test event is exempt from self-app/allowlist filters via `isTest` — never regress that exemption when changing filters.

Gotcha: MIUI/HyperOS keeps notification access "granted" while refusing to bind the listener (`MIUILOG- Reject service`), so nothing is mirrored and validation used to time out. `MainActivity` requests a rebind on startup; step 2 surfaces the state. Off-device, `PermissionService` short-circuits on `Platform.isAndroid` — tests fake the gate with `MessageStream.debugListenerGate`.

## Conventions & Gotchas

- Notice listeners/SMS run in a headless engine; static state (`_pendingToken`, `MessageStream` channel handlers) is shared deliberately. Don't "fix" single-instance assumptions without checking both engines.
- `SendResult.authFailure` (HTTP 401/403) → NOT enqueued for retry; `failure` → enqueued with exponential backoff (2s→60s, cap 50).
- Auth config is stored encrypted on Android; nothing ever logs secret values (`_sanitizeEndpoint`, redaction).
- New platform features need wiring in BOTH the relevant Kotlin file and its Dart wrapper in `lib/`, plus tests in `test/` (Dart) and `android/app/src/test/...` (Kotlin).
- Method channel mock namespaces in tests: `msg_mirror_prefs` returns raw JSON strings; small helpers like `_mockAuth` exist in `test/message_stream_auth_test.dart` — reuse instead of re-mocking.
- App UI is English; match existing Material 3 card/button patterns (`_ModernCard`, `FilledButton.icon` 56px) rather than inventing new widgets.