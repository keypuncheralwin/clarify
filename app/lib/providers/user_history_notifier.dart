import 'package:clarify/api/get_deviceId.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/api/user_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clarify/types/user_history_response.dart';
import 'auth_provider.dart';

class UserHistoryNotifier extends StateNotifier<List<UserHistoryItem>> {
  UserHistoryNotifier(this.ref) : super([]) {
    fetchInitialHistory();
    ref.listen<User?>(authStateProvider, (previous, next) {
      if (previous == null && next != null) {
        fetchInitialHistory();
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

  Future<void> fetchHistory() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final response = await _fetchHistory();
      final newItems = response.userHistory;
      print('HISTORY');
      print(response.userHistory);
      state = [...state, ...newItems];
      _nextPageToken = response.nextPageToken; // Set the next page token
      _hasMore =
          response.nextPageToken != null; // Determine if there are more pages
    } catch (e) {
      // Handle error
      print('Error fetching history: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchInitialHistory() async {
    isInitialLoading = true;
    state = [];
    _nextPageToken = null; // Reset next page token
    _hasMore = true; // Reset hasMore
    await fetchHistory();
    isInitialLoading = false;
    state = [...state]; // Trigger state change to update the UI
  }

  Future<void> refreshHistory() async {
    if (isRefreshing) return;

    isRefreshing = true;

    try {
      _nextPageToken = null; // Reset next page token
      final response = await _fetchHistory();
      final newItems = response.userHistory;
      print('FETCHED ITEMS');
      print(newItems);
      state = newItems; // Replace existing state with new items
      _nextPageToken = response.nextPageToken; // Reset the next page token
      _hasMore =
          response.nextPageToken != null; // Determine if there are more pages
    } catch (e) {
      // Handle error
      print('Error refreshing history: $e');
    } finally {
      isRefreshing = false;
    }
  }

  void addNewHistory(UserHistoryItem newHistoryItem) {
    if (newHistoryItem.analysedLink.isAlreadyInHistory != true) {
      state = [newHistoryItem, ...state];
    }
  }

  Future<void> fetchMoreHistory() async {
    if (isLoadingMore || !_hasMore) return;

    isLoadingMore = true;
    state = [...state]; // Trigger state change to update the UI

    await fetchHistory();

    isLoadingMore = false;
    state = [...state]; // Trigger state change to update the UI
  }

  Future<UserHistoryResponse> _fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('NO USER');
      final deviceId = await DeviceIdProvider.getDeviceId() ?? 'NO_DEVICE_ID';
      return UserHistoryService.fetchDeviceHistory(deviceId, 10,
          pageToken: _nextPageToken);
    } else {
      print('USER IS IN');
      return UserHistoryService.fetchUserHistory(10, pageToken: _nextPageToken);
    }
  }
}

final userHistoryProvider =
    StateNotifierProvider<UserHistoryNotifier, List<UserHistoryItem>>(
  (ref) => UserHistoryNotifier(ref),
);
