import 'package:clarify/widgets/clarity_score_pill.dart';
import 'package:clarify/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/api/user_history_service.dart';
import 'package:clarify/providers/auth_provider.dart';
import 'package:clarify/widgets/analysed_link_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Map<String, dynamic>> _userHistory = [];
  bool _isLoading = false;
  String? _nextPageToken;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUserHistory();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchUserHistory();
      }
    });
  }

  Future<void> _fetchUserHistory() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await UserHistoryService.fetchUserHistory(10, pageToken: _nextPageToken);
      final List<Map<String, dynamic>> newItems = List<Map<String, dynamic>>.from(response['userHistory']);
      setState(() {
        _userHistory.addAll(newItems);
        _nextPageToken = response['nextPageToken'];
        _hasMore = _nextPageToken != null;
      });
    } catch (e) {
      // Handle error
      print('Error fetching user history: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);

    return Scaffold(
      body: user == null
          ? _buildWelcomeMessage()
          : _buildUserHistory(),
    );
  }

  Widget _buildWelcomeMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Clarify!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "Get started by sharing a link to the Clarify app or paste a link here by tapping the link button below",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHistory() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _userHistory.length + (_hasMore ? 3 : 0), // Show 3 skeleton items while loading
      itemBuilder: (context, index) {
        if (index >= _userHistory.length) {
          return const SkeletonListTile();
        }

        final item = _userHistory[index];
        final analysedAt = (item['analysedAt'] as Timestamp).toDate();
        
        return Column(
          children: [
            InkWell(
              onTap: () {
                _showBottomSheet(item);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  item['analysedLink']['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClarityScorePill(clarityScore: item['analysedLink']['clarityScore']),
                    const SizedBox(height: 4),
                    Text('Analysed At: ${analysedAt.toLocal()}'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_drop_down),
              ),
            ),
            const Divider(height: 1, thickness: 1),
          ],
        );
      },
    );
  }

  void _showBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AnalysedLinkBottomSheet(
          isLoading: false,
          result: item['analysedLink'],
          errorMessage: null,
        );
      },
    );
  }
}
