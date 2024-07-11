import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/api/user_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarify/types/user_history_response.dart';
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
    StateNotifierProvider<UserHistoryNotifier, List<UserHistoryItem>>(
  (ref) => UserHistoryNotifier(ref),
);
