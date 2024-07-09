import 'package:clarify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/api/user_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserHistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
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
      final List<Map<String, dynamic>> newItems =
          List<Map<String, dynamic>>.from(response['userHistory']);

      state = [...state, ...newItems];
      _nextPageToken = response['nextPageToken'];
      _hasMore = _nextPageToken != null;
    } catch (e) {
      // Handle error
      print('Error fetching user history: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchInitialUserHistory() async {
    print("AREE: fetching initial user history");
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
      final List<Map<String, dynamic>> newItems =
          List<Map<String, dynamic>>.from(response['userHistory']);

      state = [...newItems, ...state];
    } catch (e) {
      // Handle error
      print('Error refreshing user history: $e');
    } finally {
      isRefreshing = false;
      state = [...state]; // Trigger state change to update the UI
    }
  }

  void addNewHistory(Map<String, dynamic> newHistoryItem) {
    state = [newHistoryItem, ...state];
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
    StateNotifierProvider<UserHistoryNotifier, List<Map<String, dynamic>>>(
  (ref) => UserHistoryNotifier(ref),
);
