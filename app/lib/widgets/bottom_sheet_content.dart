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
  OverlayEntry? _tooltipOverlay;

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

  void _showTooltip(BuildContext context, String explanation, Offset position) {
    _removeTooltip(); // Ensure any existing tooltip is removed

    OverlayState? overlayState = Overlay.of(context);

    _tooltipOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _removeTooltip();
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + 40,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            _removeTooltip();
                          },
                          child: const Icon(Icons.close, color: Colors.white70, size: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, right: 0, left: 0, bottom: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5, right: 15, left: 15, bottom: 15),
                              child: Text(
                                explanation,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlayState.insert(_tooltipOverlay!);
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_tooltipOverlay != null) {
          _removeTooltip();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
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
    final explanation = result['explanation'] ?? 'No explanation available';
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
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final Offset position = renderBox.localToGlobal(Offset.zero);
                _showTooltip(context, explanation, position);
              },
              child: Container(
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
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          answer,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        Text(
          summary,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
