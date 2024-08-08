// lib/widgets/feedback_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/providers/auth_provider.dart';
import 'package:clarify/api/submit_feedback.dart';

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackBottomSheetState createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _feedbackError;

  void _onStarTapped(int rating) {
    setState(() {
      if (_selectedRating == rating) {
        _selectedRating = 0; // Unselect if the same rating is tapped
      } else {
        _selectedRating = rating;
      }
    });
  }

  Future<void> _submitFeedback(WidgetRef ref) async {
    setState(() {
      _feedbackError =
          _feedbackController.text.isEmpty ? 'Feedback cannot be empty' : null;
    });

    if (_feedbackError != null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(authStateProvider);
      final email = user?.email ?? _emailController.text;

      await FeedbackService.submitFeedback(
        email: email.isEmpty ? null : email,
        rating: _selectedRating,
        feedbackContent: _feedbackController.text,
      );

      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context)
          .pop(); // Close the bottom sheet after successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully')),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final user = ref.watch(authStateProvider);
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.deepPurple,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: const Text(
                              'We greatly appreciate your feedback! Thank you for taking the time to complete our feedback form.',
                              style:
                                  TextStyle(fontSize: 13), // Smaller text size
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'How would you rate your experience with Clarify?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStarRating(),
                          const SizedBox(height: 16),
                          _buildMessageBox(
                              'What do you like or dislike about Clarify? How can we improve it?'),
                          const SizedBox(height: 16),
                          if (user == null)
                            _buildEmailBox('Email address (optional)'),
                          const SizedBox(height: 16),
                          if (_errorMessage != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          _buildSubmitButton(ref),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => _onStarTapped(index + 1),
          child: Icon(
            Icons.star,
            color: index < _selectedRating ? Colors.deepPurple : Colors.grey,
            size: 40,
          ),
        );
      }),
    );
  }

  Widget _buildMessageBox(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          if (_feedbackError != null)
            Text(
              _feedbackError!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode ? Colors.white : Colors.deepPurple,
                width: 1,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _feedbackController,
              maxLines: 6, // Increase the size of the message box
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your feedback here...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onChanged: (value) {
                if (_feedbackError != null && value.isNotEmpty) {
                  setState(() {
                    _feedbackError = null;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailBox(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode ? Colors.white : Colors.deepPurple,
                width: 1,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your email here...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : () => _submitFeedback(ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
