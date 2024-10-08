import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clarify/api/auth_service.dart';
import 'package:clarify/providers/auth_provider.dart';

class SignInBottomSheet extends ConsumerStatefulWidget {
  const SignInBottomSheet({super.key});

  @override
  _SignInBottomSheetState createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends ConsumerState<SignInBottomSheet> {
  final FocusNode _emailFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes = List.generate(4, (_) => FocusNode());
  final FocusNode _nameFocusNode = FocusNode();
  bool _isCodeSent = false;
  bool _isNameRequired = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  String? _errorMessage;
  String? _email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _emailController.dispose();
    _nameController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    try {
      await AuthService.sendVerificationCode(email);
      setState(() {
        _isCodeSent = true;
        _email = email;
        // Removed auto-focus on the first code input field
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSendingCode = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((controller) => controller.text).join();

    if (code.isEmpty || code.length != 4) {
      setState(() {
        _errorMessage = 'Please enter the 4-digit verification code';
      });
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.verifyCode(_email!, code);
      if (result['nameRequired'] == true) {
        setState(() {
          _isNameRequired = true;
          _isVerifyingCode = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _nameFocusNode.requestFocus();
          });
        });
      } else {
        final token = result['token'];
        await ref.read(authStateProvider.notifier).signInWithToken(token);
        setState(() {
          _isVerifyingCode = false;
        });
        Navigator.of(context)
            .pop(); // Close the bottom sheet after successful login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully signed in')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isVerifyingCode = false;
      });
    }
  }

  Future<void> _createUser() async {
    final name = _nameController.text;
    final code = _codeControllers.map((controller) => controller.text).join();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthService.createUser(_email!, code, name);
      await ref.read(authStateProvider.notifier).signInWithToken(token);
      setState(() {
        _isVerifyingCode = false;
      });
      Navigator.of(context)
          .pop(); // Close the bottom sheet after successful login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully signed in')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isVerifyingCode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isCodeSent
                    ? _isNameRequired
                        ? _buildNameInputView()
                        : _buildCodeInputView()
                    : _buildEmailInputView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your email',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Email',
          ),
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSendingCode ? null : _sendVerificationCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: _isSendingCode
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _isCodeSent = false;
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Enter the 4-digit code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Check your email for the verification code sent to $_email'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 50,
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _codeFocusNodes[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                onChanged: (value) async {
                  if (value.isNotEmpty && index < 3) {
                    // Debounce the focus change by adding a small delay
                    await Future.delayed(const Duration(milliseconds: 100));
                    _codeFocusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    // Debounce the focus change by adding a small delay
                    await Future.delayed(const Duration(milliseconds: 100));
                    _codeFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isVerifyingCode ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: _isVerifyingCode
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'Verify',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        const Text(
          'Welcome to Clarify!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('What should we call you?'),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Name',
          ),
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isVerifyingCode ? null : _createUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: _isVerifyingCode
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'Complete Sign Up',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
