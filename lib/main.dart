// Replace only lib/main.dart in a fresh official `dn create` starter.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartnative/dartnative.dart';

import 'dartnative_plugin_registrant.dart';

const initialRange = bool.fromEnvironment('INITIAL_RANGE', defaultValue: true);

void main() {
  DartNativePluginRegistrant.registerAll();
  SystemChrome.defaultStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
  runApp(const ManualSelectionRepro());
}

class ManualSelectionRepro extends StatefulWidget {
  const ManualSelectionRepro({super.key});

  @override
  State<ManualSelectionRepro> createState() => _ManualSelectionReproState();
}

class _ManualSelectionReproState extends State<ManualSelectionRepro> {
  final controller = initialRange
      ? TextEditingController.fromValue(
          const TextEditingValue(
            text: 'Unsent draft',
            selection: TextSelection(baseOffset: 1, extentOffset: 5),
          ),
        )
      : TextEditingController(text: 'Unsent draft');
  final focus = FocusNode();
  final clock = Stopwatch()..start();
  Timer? captureTimer;
  int sequence = 0;
  int listenerCount = 0;
  int changeCount = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(onControllerChanged);
    record('mount-listener-attached');
  }

  void onControllerChanged() {
    listenerCount++;
    record('controller-listener');
  }

  void record(String action) {
    final value = controller.value;
    final selection = controller.selection;
    print(
      'DN_MANUAL_SELECTION ${jsonEncode({
        'sequence': ++sequence,
        'elapsed_us': clock.elapsedMicroseconds,
        'action': action,
        'pid': pid,
        'initial_range': initialRange,
        'state': identityHashCode(this),
        'controller': identityHashCode(controller),
        'focus_node': identityHashCode(focus),
        'text': value.text,
        'selection': [value.selection.baseOffset, value.selection.extentOffset],
        'selection_getter': [selection.baseOffset, selection.extentOffset],
        'composing': [value.composing.start, value.composing.end],
        'listener_count': listenerCount,
        'on_changed_count': changeCount,
        'focused': focus.hasFocus,
      })}',
    );
  }

  void requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      focus.requestFocus();
      record('focus-requested');
    });
  }

  void captureLater() {
    captureTimer?.cancel();
    record('capture-5s-armed');
    captureTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) record('capture-5s');
    });
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    record('dispose');
    controller.removeListener(onControllerChanged);
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    brightness: Brightness.light,
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('Manual selection readback')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(initialRange ? 'Initial range: 1 to 5' : 'Initial range: none'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            focusNode: focus,
            autocorrect: false,
            onChanged: (_) {
              changeCount++;
              record('onChanged');
            },
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: requestFocus, child: const Text('Focus input')),
          TextButton(
            onPressed: () => record('capture'),
            child: const Text('Capture state'),
          ),
          TextButton(
            onPressed: captureLater,
            child: const Text('Capture in 5s'),
          ),
          const Text('Manually select draft, then type X.'),
          const Text('Expected: Unsent X. Select Unsent, then type Y.'),
          const Text('Expected: Y X. No selection setters or repair writes.'),
        ],
      ),
    ),
  );
}
