import 'package:clarify/providers/user_history_notifier.dart';
import 'package:clarify/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/providers/auth_provider.dart';
import 'package:clarify/widgets/analysed_link_bottom_sheet.dart';
import 'package:clarify/widgets/clarity_score_pill.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(userHistoryProvider.notifier).fetchMoreHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final userHistory = ref.watch(userHistoryProvider);
    final userHistoryNotifier = ref.read(userHistoryProvider.notifier);
    final isLoadingMore = userHistoryNotifier.isLoadingMore;
    final isInitialLoading = userHistoryNotifier.isInitialLoading;

    return Scaffold(
      body: user == null
          ? _buildWelcomeMessage()
          : isInitialLoading
              ? _buildInitialLoadingSkeleton()
              : RefreshIndicator(
                  onRefresh: () => ref.read(userHistoryProvider.notifier).refreshHistory(),
                  child: _buildUserHistory(userHistory, isLoadingMore),
                ),
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

  Widget _buildInitialLoadingSkeleton() {
    return ListView.builder(
      itemCount: 7, // Number of skeleton items
      itemBuilder: (context, index) {
        return const SkeletonListTile();
      },
    );
  }

  Widget _buildUserHistory(List<Map<String, dynamic>> userHistory, bool isLoadingMore) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: userHistory.length + (isLoadingMore ? 3 : 0), // Show skeleton items only when loading more
      itemBuilder: (context, index) {
        if (index >= userHistory.length) {
          return const SkeletonListTile();
        }

        final item = userHistory[index];
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
            const Divider(height: 1, thickness: 1), // Add a divider between items
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
