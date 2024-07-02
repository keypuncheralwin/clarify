import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BottomSheetContent extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic>? result;
  final String? errorMessage;

  const BottomSheetContent({super.key, required this.isLoading, required this.result, this.errorMessage});

  @override
  BottomSheetContentState createState() => BottomSheetContentState();
}

class BottomSheetContentState extends State<BottomSheetContent> {
  late bool _isLoading;
  Map<String, dynamic>? _result;
  String? _errorMessage;
  OverlayEntry? _tooltipOverlay;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _result = widget.result;
    _errorMessage = widget.errorMessage;
  }

  void updateContent(bool isLoading, Map<String, dynamic>? result, String? errorMessage) {
    setState(() {
      _isLoading = isLoading;
      _result = result;
      _errorMessage = errorMessage;
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

  void _showTooltip(BuildContext context, String explanation) {
    _removeTooltip(); // Ensure any existing tooltip is removed

    final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

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
              top: position.dy + renderBox.size.height + 10,
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

    overlayState!.insert(_tooltipOverlay!);
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (_tooltipOverlay != null) {
          _removeTooltip();
        } else {
          Navigator.of(context).pop();
        }
      },
      behavior: HitTestBehavior.opaque, // Ensure tap outside bottom sheet is detected
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Override onTap to prevent closing when tapping the sheet
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2B2B2B) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close bottom sheet on dash tap
                  },
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                _isLoading
                    ? _buildLoadingContent(isDarkMode)
                    : _errorMessage != null
                        ? SelectableText(
                            _errorMessage!,
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          )
                        : _result != null
                            ? _buildResultContent(_result!, isDarkMode)
                            : SelectableText(
                                'No data available',
                                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[350]!,
          highlightColor: isDarkMode ? Colors.grey[500]! : Colors.grey[50]!,
          child: Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[350]!,
          highlightColor: isDarkMode ? Colors.grey[500]! : Colors.grey[50]!,
          child: Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[350]!,
          highlightColor: isDarkMode ? Colors.grey[500]! : Colors.grey[50]!,
          child: Container(
            width: double.infinity,
            height: 100,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(Map<String, dynamic> result, bool isDarkMode) {
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
        SelectableText(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          key: _buttonKey,
          onPressed: () {
            _showTooltip(context, explanation);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getClarityScoreColor(clarityScoreValue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 0), // Removes default minimum size constraints
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks the tap target size
          ),
          child: Text(
            'Clarity Score: $clarityScore',
            style: const TextStyle(color: Colors.white, fontSize: 12), // Smaller font size
          ),
        ),
        const SizedBox(height: 10),
        SelectableText(
          answer,
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        SelectableText(
          summary,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
