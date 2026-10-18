import 'dart:async';
import 'package:flutter/foundation.dart';

/// Converts a [Stream] into a [Listenable]
///
/// This is specifically used to make GoRouter's `refreshListenable` react
/// to Stream events (like Supabase Auth state changes).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
