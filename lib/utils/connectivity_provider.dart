import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetCheckerSubscription;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    // Check initial connectivity state
    final initialResults = await Connectivity().checkConnectivity();
    // Take the first result if available, otherwise assume no connectivity
    final initialState = initialResults.isNotEmpty
        ? initialResults.first
        : ConnectivityResult.none;
    await _updateConnectionState(initialState);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      // Handle the first result from the list, or assume no connectivity if empty
      final state =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      await _updateConnectionState(state);
    });

    // Regular internet connection checker
    _internetCheckerSubscription = InternetConnectionChecker()
        .onStatusChange
        .listen((InternetConnectionStatus status) {
      _updateConnectionStatus(status == InternetConnectionStatus.connected);
    });
  }

  Future<void> _updateConnectionState(ConnectivityResult state) async {
    if (state != ConnectivityResult.none) {
      final bool isOnline = await InternetConnectionChecker().hasConnection;
      _updateConnectionStatus(isOnline);
    } else {
      _updateConnectionStatus(false);
    }
  }

  void _updateConnectionStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _internetCheckerSubscription?.cancel();
    super.dispose();
  }

  // Helper method to check current connectivity
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      // If we have no connectivity results or the first result is none, return false
      if (connectivityResults.isEmpty ||
          connectivityResults.first == ConnectivityResult.none) {
        return false;
      }
      return await InternetConnectionChecker().hasConnection;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      return false;
    }
  }
}
