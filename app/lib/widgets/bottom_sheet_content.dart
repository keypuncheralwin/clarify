import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BottomSheetContent extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic>? result;

  const BottomSheetContent({super.key, required this.isLoading, required this.result});

  @override
  BottomSheetContentState createState() => BottomSheetContentState();
}

class BottomSheetContentState extends State<BottomSheetContent> {
  late bool _isLoading;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _result = widget.result;
  }

  void updateContent(bool isLoading, Map<String, dynamic>? result) {
    setState(() {
      _isLoading = isLoading;
      _result = result;
    });
  }

  Color _getClarityScoreColor(int score) {
    if (score >= 0 && score <= 4) {
      return const Color(0xFFfe2712);
    } else if (score >= 5 && score <= 6) {
      return const Color(0xFFfb9902);
    } else if (score >= 7 && score <= 10) {
      return const Color(0xFF66b032);
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          _isLoading
              ? _buildLoadingContent()
              : _result != null
                  ? _buildResultContent(_result!)
                  : const Text('No data available'),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Container(
            width: double.infinity,
            height: 100,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(Map<String, dynamic> result) {
    final title = result['title'] ?? 'No title available';
    final clarityScore = result['clarityScore']?.toString() ?? 'N/A';
    final clarityScoreValue = result['clarityScore'] ?? -1;
    final answer = result['answer'] ?? 'No answer available';
    final summary = result['summary'] ?? 'No summary available';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getClarityScoreColor(clarityScoreValue),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Clarity Score: $clarityScore',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          answer,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        Text(
          summary,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
