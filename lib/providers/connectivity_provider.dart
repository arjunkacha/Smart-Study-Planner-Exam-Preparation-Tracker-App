import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state provider - streams connectivity changes
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Emit current state
  final initial = await connectivity.checkConnectivity();
  yield !initial.contains(ConnectivityResult.none);

  // Stream subsequent changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield !results.contains(ConnectivityResult.none);
  }
});

/// Simple bool provider for quick connectivity checks
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        data: (v) => v,
        orElse: () => false,
      );
});
