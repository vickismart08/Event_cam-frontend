import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/responsive_container.dart';
import '../widgets/soft_card.dart';
import 'host_dashboard_page.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  var _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Enter your email';
    if (!t.contains('@') || !t.contains('.')) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Choose a password';
    if (v.length < 6) return 'Use at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await authController.signUpWithEmail(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const HostDashboardPage()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Create an account',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hosts manage events and guest galleries.',
                                style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                              ),
                              const SizedBox(height: 28),
                              AuthTextField(
                                controller: _email,
                                label: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                                validator: _emailValidator,
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                controller: _password,
                                focusNode: _passwordFocus,
                                label: 'Password',
                                obscure: true,
                                autofillHints: const [AutofillHints.newPassword],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                validator: _passwordValidator,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'At least 6 characters.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 20),
                              PrimaryAppButton(
                                label: _loading ? 'Creating…' : 'Sign up',
                                onPressed: _loading ? null : _submit,
                                minimumSize: const Size(double.infinity, 52),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        Navigator.of(context).pushReplacement<void, void>(
                                          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                                        );
                                      },
                                child: const Text('Already have an account? Sign in'),
                              ),
                            ],
                          ),
                        ),
                      ),
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
}
