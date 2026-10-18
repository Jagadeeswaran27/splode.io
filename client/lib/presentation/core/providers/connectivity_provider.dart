import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final checker = InternetConnection();

  // Yield initial status
  yield await checker.hasInternetAccess;

  // Listen for changes
  await for (final status in checker.onStatusChange) {
    yield status == InternetStatus.connected;
  }
});
