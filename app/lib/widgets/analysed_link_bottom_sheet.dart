import 'package:clarify/utils/clarity_score_calculator.dart';
import 'package:clarify/utils/link_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clarify/types/analysed_link_response.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class AnalysedLinkBottomSheet extends StatefulWidget {
  final bool isLoading;
  final AnalysedLinkResponse? result;
  final String? errorMessage;

  const AnalysedLinkBottomSheet({
    super.key,
    required this.isLoading,
    required this.result,
    this.errorMessage,
  });

  @override
  AnalysedLinkBottomSheetState createState() => AnalysedLinkBottomSheetState();
}

class AnalysedLinkBottomSheetState extends State<AnalysedLinkBottomSheet> {
  late bool _isLoading;
  AnalysedLinkResponse? _result;
  String? _errorMessage;
  OverlayEntry? _tooltipOverlay;
  final GlobalKey _buttonKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _result = widget.result;
    _errorMessage = widget.errorMessage;

    // Check initial scroll extent to update shadow visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollExtent();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollExtent() {
    if (_scrollController.hasClients) {
      setState(() {
        _isAtBottom = _scrollController.position.atEdge &&
            _scrollController.position.pixels != 0;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        setState(() {
          _isAtBottom = false;
        });
      } else {
        setState(() {
          _isAtBottom = true;
        });
      }
    } else {
      setState(() {
        _isAtBottom = false;
      });
    }
  }

  void updateContent(
      bool isLoading, AnalysedLinkResponse? result, String? errorMessage) {
    setState(() {
      _isLoading = isLoading;
      _result = result;
      _errorMessage = errorMessage;
    });
  }

  void _showTooltip(BuildContext context, String explanation) {
    _removeTooltip(); // Ensure any existing tooltip is removed

    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
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
                          child: const Icon(Icons.close,
                              color: Colors.white70, size: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 25.0, right: 0, left: 0, bottom: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, right: 15, left: 15, bottom: 15),
                              child: Text(
                                explanation,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
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

  void _copyToClipboard(
      String title, String clarityScore, String answer, String summary) {
    final text =
        'Title: $title\nClarity Score: $clarityScore\nMain Point: $answer\nSummary: $summary';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clarified link copied to clipboard!')),
    );
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
      behavior:
          HitTestBehavior.opaque, // Ensure tap outside bottom sheet is detected
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap:
              () {}, // Override onTap to prevent closing when tapping the sheet
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
                    Navigator.of(context)
                        .pop(); // Close bottom sheet on dash tap
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
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                          )
                        : _result != null
                            ? _buildResultContent(_result!, isDarkMode)
                            : SelectableText(
                                'No data available',
                                style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                              ),
                if (_result != null) const SizedBox(height: 10),
                if (_result != null) _buildActionButtons(),
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

  Widget _buildResultContent(AnalysedLinkResponse result, bool isDarkMode) {
    final title = result.title;
    final clarityScore = result.clarityScore.toString();
    final clarityScoreValue = result.clarityScore;
    final explanation = result.explanation;
    final answer = result.answer;
    final summary = result.summary;
    final combinedLength = answer.length + summary.length;
    String clarityScoreDefinition =
        'The clarity score is a measure from 0 to 10 indicating how clear and accurate the title is, with higher scores indicating greater clarity and accuracy. Tap on the clarity score to see the reason behind the score.';

    double containerHeight =
        MediaQuery.of(context).size.height * 0.5; // 50% of the screen height
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
        const SizedBox(height: 0),
        Row(
          children: [
            ElevatedButton(
              key: _buttonKey,
              onPressed: () {
                _showTooltip(context, explanation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: getClarityScoreColor(clarityScoreValue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(
                    0, 0), // Removes default minimum size constraints
                tapTargetSize: MaterialTapTargetSize
                    .shrinkWrap, // Shrinks the tap target size
              ),
              child: Text(
                'Clarity Score: $clarityScore',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12), // Smaller font size
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero, // Remove internal padding
              constraints: const BoxConstraints(), // Remove default constraints
              icon: Icon(Icons.help,
                  color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                _showTooltip(context, clarityScoreDefinition);
              },
            ),
            IconButton(
              padding: EdgeInsets.zero, // Remove internal padding
              constraints: const BoxConstraints(), // Remove default constraints
              icon: Icon(Icons.copy_all_rounded,
                  color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                _copyToClipboard(title, clarityScore, answer, summary);
              },
            ),
          ],
        ),
        const SizedBox(height: 0),
        combinedLength > 900
            ? Stack(
                children: [
                  SizedBox(
                    height: containerHeight,
                    child: Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              answer,
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
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
                        ),
                      ),
                    ),
                  ),
                  if (!_isAtBottom &&
                      _scrollController.hasClients &&
                      _scrollController.position.maxScrollExtent > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent.withOpacity(0.1),
                              Colors.transparent.withOpacity(0.2),
                              Colors.transparent.withOpacity(0.3),
                              Colors.transparent.withOpacity(0.4),
                              Colors.transparent.withOpacity(0.5),
                              isDarkMode
                                  ? const Color(0xFF2B2B2B)
                                  : const Color(0xFFFFFFFF),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
              ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isVideo = _result?.isVideo ?? false;
    final String url = _result?.url ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Share.share(url, subject: 'Check out this link!');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: isDarkMode ? Colors.white : Colors.deepPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Share Link',
              style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.deepPurple),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _openLink(url, isVideo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              isVideo ? 'Watch Video' : 'Visit Link',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _openLink(String url, bool isVideo) {
    openLink(context, url, isVideo);
  }
}
