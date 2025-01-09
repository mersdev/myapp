import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  String? _message;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _message = null;
    });

    try {
      await AuthService.instance.resendVerificationEmail();
      setState(() {
        _message = 'Verification email sent! Please check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to send verification email. Please try again.';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_unread,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'We\'ve sent a verification email to your inbox. Please verify your email to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          if (_message != null) ...[
                            Text(
                              _message!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _message!.contains('Failed') 
                                  ? Colors.red 
                                  : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          ElevatedButton(
                            onPressed: _isResending ? null : _resendVerificationEmail,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: _isResending
                                ? const CircularProgressIndicator()
                                : const Text('Resend Verification Email'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => AuthService.instance.signOut(),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 