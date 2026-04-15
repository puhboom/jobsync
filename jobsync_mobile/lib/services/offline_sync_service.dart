import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../data/sources/local_storage.dart';
import '../../../data/sources/api_client.dart';
import '../../../data/repositories/jobs_repository.dart';

class OfflineSyncService {
  final LocalStorage _storage;
  final ApiClient _apiClient;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  OfflineSyncService({
    required LocalStorage storage,
    required ApiClient apiClient,
    JobsRepository? jobsRepository,
  })  : _storage = storage,
        _apiClient = apiClient;

  Future<void> init() async {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      // Check if connectivity is restored
      final hasConnectivity = result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet;
      if (hasConnectivity) {
        debugPrint('Connectivity restored, syncing pending operations...');
        syncPendingOperations();
      }
    });
  }

  Future<void> queueOperation(Map<String, dynamic> operation) async {
    await _storage.addPendingOperation({
      ...operation,
      'timestamp': DateTime.now().toIso8601String(),
      'retries': 0,
    });
  }

  Future<void> syncPendingOperations() async {
    final operations = await _storage.getPendingOperations();

    for (final op in operations) {
      try {
        await _processOperation(op);
        // Remove from queue on success
      } catch (e) {
        final retries = (op['retries'] ?? 0) + 1;
        if (retries >= 3) {
          // Mark as failed after max retries
          debugPrint('Operation failed after 3 retries: $e');
        } else {
          // Update retry count
        }
      }
    }
  }

  Future<void> _processOperation(Map<String, dynamic> op) async {
    final type = op['type'];
    final endpoint = op['endpoint'];
    final data = op['data'];

    switch (type) {
      case 'create':
        await _apiClient.post(endpoint, data: data);
        break;
      case 'update':
        await _apiClient.put(endpoint, data: data);
        break;
      case 'delete':
        await _apiClient.delete(endpoint, data: data);
        break;
    }

    // Remove from queue on success
    final operations = await _storage.getPendingOperations();
    final remaining = operations.where((o) => o['timestamp'] != op['timestamp']).toList();
    await _storage.clearPendingOperations();
    for (final op in remaining) {
      await _storage.addPendingOperation(op);
    }
  }
}
