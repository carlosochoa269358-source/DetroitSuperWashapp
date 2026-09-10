import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Escucha `controller` directamente (en vez de depender de que el widget
/// se reconstruya con cada tecla) y llama `onDebounced` con el texto actual
/// `duration` después de la última tecla presionada.
void useDebouncedTextListener(
  TextEditingController controller,
  void Function(String text) onDebounced, {
  Duration duration = const Duration(milliseconds: 400),
}) {
  useEffect(() {
    Timer? timer;
    void listener() {
      timer?.cancel();
      timer = Timer(duration, () => onDebounced(controller.text));
    }

    controller.addListener(listener);
    return () {
      timer?.cancel();
      controller.removeListener(listener);
    };
  }, [controller]);
}
