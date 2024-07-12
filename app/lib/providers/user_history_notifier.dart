import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/api/user_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarify/types/user_history_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth_provider.dart';

class UserHistoryNotifier extends StateNotifier<List<UserHistoryItem>> {
  UserHistoryNotifier(this.ref) : super([]) {
    fetchInitialUserHistory();
    ref.listen<User?>(authStateProvider, (previous, next) {
      if (previous == null && next != null) {
        fetchInitialUserHistory();
      }
    });
  }

  final Ref ref;
  bool _isLoading = false;
  bool isLoadingMore = false;
  bool isInitialLoading = true; // Track initial loading state
  bool isRefreshing = false; // Track refreshing state
  String? _nextPageToken;
  bool _hasMore = true;

  Future<void> fetchUserHistory() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final response = await UserHistoryService.fetchUserHistory(10,
          pageToken: _nextPageToken);
      final newItems = response.userHistory;
      state = [...state, ...newItems];
      _nextPageToken = null; // Assuming response doesn't have nextPageToken
      _hasMore = false; // Assuming no more pages
    } catch (e) {
      // Handle error
      print('Error fetching user history: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchInitialUserHistory() async {
    isInitialLoading = true;
    state = [];
    await fetchUserHistory();
    isInitialLoading = false;
    state = [...state]; // Trigger state change to update the UI
  }

  Future<void> refreshHistory() async {
    if (isRefreshing) return;

    isRefreshing = true;

    try {
      final response = await UserHistoryService.fetchUserHistory(10);
      final newItems = response.userHistory;
      state = [...newItems, ...state];
    } catch (e) {
      // Handle error
      print('Error refreshing user history: $e');
    } finally {
      isRefreshing = false;
      state = [...state]; // Trigger state change to update the UI
    }
  }

  void addNewHistory(UserHistoryItem newHistoryItem) {
    if (newHistoryItem.analysedLink.isAlreadyInHistory != true) {
      state = [newHistoryItem, ...state];
    }
  }

  Future<void> updateHistoryFromLocal() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // Set<String> keys = prefs.getKeys();

    // if (keys.isEmpty) {
    //   print("********************************");
    //   return;
    // }

    // print("Shared Preferences:");
    // final historyJson = prefs.getString('localUserHistory');
    // print("historyJson");
    // print(historyJson);
    // print("###########################################");
    // for (String key in keys) {
    //   var value = prefs.get(key);
    //   print("$key: $value");
    // }
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('localUserHistory') ?? '[]';
      debugPrint('Local history JSON: $historyJson');
      final List<dynamic> historyList = json.decode(historyJson);

      if (historyList.isNotEmpty) {
        final List<UserHistoryItem> newItems = historyList.map((item) {
          return UserHistoryItem.fromJson(item as Map<String, dynamic>);
        }).toList();

        state = [...newItems, ...state];
        debugPrint('New items added to history: ${newItems.length}');
      }

      await prefs
          .remove('flutter.localUserHistory'); // Clear the shared preferences
      debugPrint('Local history cleared');
    } catch (e) {
      debugPrint('Error in updateHistoryFromLocal: $e');
    }
  }

  Future<void> fetchMoreHistory() async {
    if (isLoadingMore || !_hasMore) return;

    isLoadingMore = true;
    state = [...state]; // Trigger state change to update the UI

    await fetchUserHistory();

    isLoadingMore = false;
    state = [...state]; // Trigger state change to update the UI
  }
}

final userHistoryProvider =
    StateNotifierProvider<UserHistoryNotifier, List<UserHistoryItem>>(
  (ref) => UserHistoryNotifier(ref),
);
