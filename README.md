# DartNative manual-selection controller reproduction

A minimal official DartNative starter reproducing **native text selection changes that leave the Dart controller range stale and do not notify its ordinary listener**. Native typing still replaces the selected word correctly, then updates the controller and calls the listener before `onChanged`.

This was reproduced on DartNative **1.4.0**, iOS **26.5 simulator** and Android **14 / API 34 arm64 emulator**, in debug builds. Two initialization controls use the same source: an explicit initial selection and a text-only controller. Both reproduce before and after a successful text edit. [Results, original screenshots and complete traces](evidence/README.md).

## Run

Install the [official SDK](https://dartnative.com/docs/getting-started/installation/) and configure your own framework license locally as required for a custom app. No key, SDK binary or built application is included here. Use the `dn` executable from the intended SDK, rather than another Flutter installation on your PATH.

```sh
git clone https://github.com/ManmohanTalwar/dartnative-manual-selection-repro.git
cd dartnative-manual-selection-repro
dn --suppress-analytics pub get
dn --suppress-analytics run --no-pub -d DEVICE_ID
```

The recorded environment used SDK 1.4.0 and `pub get --offline` with its existing cache. The dependency declarations and locks match the measured fixture. The repository includes the generated iOS/Android hosts, original assets and Android Gradle wrapper. `dn pub get` regenerates the ignored plugin registrant and machine-local configuration. Normal CLI/CocoaPods build configuration migration is expected; no functional native-host or SDK patch is required. The generated personal iOS signing-team assignments were removed for publication; configure your own signing if targeting a physical iOS device.

## Controls and steps

Terminate the app and start a **fresh process** for each case; do not hot reload/restart between controls.

- **A — default:** `TextEditingController.fromValue`, text `Unsent draft`, selection `[1,5]`.
- **B — text only:** run with `--dart-define=INITIAL_RANGE=false`; controller initially reports `[-1,-1]`.

```sh
dn --suppress-analytics run --no-pub --dart-define=INITIAL_RANGE=false -d DEVICE_ID
```

For each case:

1. Tap **Focus input**, then **Capture state** after focus settles.
2. Use native long-press, **Select**, or selection handles to select `draft`. On iOS, the first long-press may only position the caret; long-press again if necessary, then use **Select**.
3. Observe the highlight and capture the controller state. **On iOS the native Cut menu can overlap Capture state. Tap the heading to dismiss that menu first, and verify the highlight remains before touching the app buttons.** Use **Capture state**, then **Capture in 5s** and leave the selected text unchanged until its passive capture prints. On Android the recorded run armed the timer before long-press and then took another settled capture. A timer that fires before selection is not evidence for that selection.
4. Type uppercase `X` through native input. Expected and observed native result: `Unsent X`, proving `draft` was selected. The listener and `onChanged` now fire.
5. Manually select `Unsent` in the edited text. Repeat the settled and passive observations: Dart's range remains the previous caret `[8,8]`, and the listener count remains 1.
6. Type uppercase `Y`. Expected and observed native result: `Y X`; the listener count becomes 2, followed by `onChanged` count 2.

The iOS evidence used software Shift + X/Y keys. Android used native `adb shell input text X` / `Y`, not Dart assignments or software-key taps. Selection proof comes from original native highlights/handles and actual replacement; this fixture has no native offset getter.

## Trace interpretation

Every `DN_MANUAL_SELECTION` JSON record includes a monotonic sequence/time, process and Dart identities, text, `controller.value.selection`, the separate `controller.selection` getter, composing range, focus and callback counts. `mount-listener-attached` records that the ordinary listener is already registered. `focus-requested` is immediate and is not a settled focus observation.

| Action | A: Dart range / listener count | B: Dart range / listener count |
|---|---|---|
| Select `draft` in `Unsent draft` | `[1,5]` / 0 | `[-1,-1]` / 0 |
| Native X replacement | `[8,8]` / 1 | `[8,8]` / 1 |
| Select `Unsent` after that edit | `[8,8]` / 1 | `[8,8]` / 1 |
| Native Y replacement | `[1,1]` / 2 | `[1,1]` / 2 |

The table holds for both measured platforms. Text edits call the listener before the corresponding `onChanged`; selection-only intervals have no listener call in the complete traces. Expected behavior for selection-dependent application logic is current controller readback and notification when native selection changes without changing text. The vendor-supported contract and internal cause need clarification.

## Isolation and limits

`lib/main.dart` is the only hand-replaced application source. It has one stable field/controller/focus node, ordinary callbacks and read-only captures; no selection setter, mirroring, reset, native hook, service extension or observer rebuild. The scaffold's unused starter example test/tool and editor-local files are omitted from publication. SDK/native implementations were not changed. Removing the generated personal signing-team assignments is a publication redaction, not a behavior fix.

This tests official Light presentation only, one qualified fresh process per platform/control. It does not certify Dark/OG themes, complex composition, emoji/RTL, physical devices, release builds or all input behavior. It adds no matched Flutter listener run. The post-edit and text-only controls show that declaring an initial range is not necessary; a common cause with [initial-selection issue #80](https://github.com/DartNative/dartnative/issues/80) remains unproved.
