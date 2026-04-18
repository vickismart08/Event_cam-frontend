import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/glamora_brand_assets.dart';
import '../widgets/responsive_container.dart';
import '../widgets/soft_card.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _loading = false;
  var _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Enter your email';
    if (!t.contains('@') || !t.contains('.')) return 'Enter a valid email';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await authController.sendPasswordResetEmail(_email.text.trim());
      if (!mounted) return;
      setState(() {
        _sent = true;
        _loading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No account uses that email. Sign up first, or fix a typo — we don’t send a reset link if the address isn’t registered.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      final message = _mapAuthError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address doesn’t look valid.';
      default:
        return e.message ?? 'Could not send reset email. Try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: const GlamoraAppBarTitle(title: 'Reset password'),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ResponsiveContainer(
              maxWidth: 440,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: SoftCard(
                      padding: const EdgeInsets.all(28),
                      child: _sent ? _buildSent(context) : _buildForm(context),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Forgot your password?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the email you used to sign up. We’ll send a link to choose a new password.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 28),
          AuthTextField(
            controller: _email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: _emailValidator,
          ),
          const SizedBox(height: 28),
          PrimaryAppButton(
            label: _loading ? 'Sending…' : 'Send reset link',
            onPressed: _loading ? null : _submit,
            minimumSize: const Size(double.infinity, 52),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }

  Widget _buildSent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 56, color: AppColors.primary.withValues(alpha: 0.9)),
        const SizedBox(height: 16),
        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          'If an account exists for ${_email.text.trim()}, you’ll receive an email with a link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 28),
        PrimaryAppButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.of(context).pop(),
          minimumSize: const Size(double.infinity, 52),
        ),
      ],
    );
  }
}
