# Recorded evidence — 2026-10-27

Four qualified fresh debug processes on official Light presentation: iOS A/B and Android A/B. The frozen `lib/main.dart` SHA-256 is `89c9d2c40b344ff35928618fe60390eec4b64eb9d22cc512d8bbbfbfc5fb9cbb`. The publication source is byte-identical to the measured fixture.

## Observations

All four runs visibly select `draft`, while both Dart selection getters retain the initialization value with listener count 0. Native X yields `Unsent X`, `[8,8]` and listener count 1. Selecting `Unsent` after this edit leaves Dart at `[8,8]` with listener count still 1. Native Y yields `Y X`, `[1,1]` and count 2. Each text-edit listener call precedes its corresponding `onChanged`.

| Record | iOS A | iOS B | Android A | Android B |
|---|---|---|---|---|
| Complete process trace | [15 events](traces/ios-A-events.json) | [15 events](traces/ios-B-events.json) | [18 events](traces/android-A-events.json) | [16 events](traces/android-B-events.json) |
| `draft` selected | [Original](screenshots/ios-A-draft-selected.png) | [Original](screenshots/ios-B-draft-selected.png) | [Original](screenshots/android-A-draft-selected-settled.png) | [Original](screenshots/android-B-draft-selected-settled.png) |
| X replacement | [Original](screenshots/ios-A-X.png) | [Original](screenshots/ios-B-X.png) | [Original](screenshots/android-A-first-replacement.png) | [Original](screenshots/android-B-first-replacement.png) |
| Post-edit `Unsent` selected | [Original](screenshots/ios-A-unsent-selected.png) | [Original](screenshots/ios-B-unsent-selected.png) | [Original](screenshots/android-A-post-edit-unsent-selected.png) | [Original](screenshots/android-B-post-edit-unsent-selected.png) |
| Y replacement | [Original](screenshots/ios-A-Y.png) | [Original](screenshots/ios-B-Y.png) | [Original](screenshots/android-A-second-replacement.png) | [Original](screenshots/android-B-second-replacement.png) |

For iOS, settled/timed selection observations are events 4/6 and 10/12; listeners are 7/13, followed by `onChanged` 8/14 and settled captures 9/15. For Android the selection observations are 6/7 and 12/13; listeners are 8/14, followed by `onChanged` 9/15 and settled captures 10/16. All 64 records have contiguous sequence numbers, monotonic times, stable per-process Dart identities and agreeing getters. Dart identities are not native-object identity evidence.

On iOS the timer was armed after the selection menu was dismissed by tapping the heading; screenshots and replacement show the selection remained. On Android it was armed before the gesture and completed after selection. The five-second timer is a scheduled delay, not an exact callback deadline. Two early Android host extractions sampled `onChanged` before the pending capture output flushed; the full traces retain the subsequent settled captures. Android A's final events 17–18 are an extra selection of `X` after `Y X`; no Copy/Paste was executed or claimed.

## Environment and provenance

[Run metadata](run-metadata.json) records SDK/build/input details with local device names, UDIDs, serials, home paths and private repository references omitted. The four JSON traces retain synthetic text, process-local numeric identifiers and original ordered values. [Capture manifest](capture-manifest.json) records hashes, byte sizes and dimensions for the 16 unedited originals published here, selected from the larger local capture set.

The required [doctor summary](doctor-sanitized.txt) retains all five diagnostic statuses and both warning categories: Flutter/Dart PATH resolution and some Android licenses not accepted. Builds used the explicit DartNative SDK executable. It is a sanitized summary, not the full unredacted verbose transcript; device discovery, verbose subprocess/Info.plist output and local paths are omitted. Raw build/run logs and license configuration are not published. Generated personal iOS signing-team assignments were removed from the public project and its unpublished history; the simulator build was checked again after this redaction.

The first iOS A attempt was excluded after a capture tap hit the overlapping native Cut menu. A subsequent direct simulator launch lacked the fixture console trace and was excluded. Qualified A was a new process launched through `dn run`; B was also fresh. No evidence from those excluded attempts appears here. The qualified A binary was not separately rehashed before B replaced the build, so no exact artifact hash is asserted for that process. Source/flag/SDK and the qualified trace remain recorded. This does not change the observed controller/selection result.

[Publication validation](publication-validation.json) separates fresh source/build checks from the earlier native interaction evidence. Publication does not imply an SDK fix, a new interaction run, all-theme qualification, physical-device proof or release readiness.
