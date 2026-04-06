import 'package:flutter/material.dart';

import '../auth/auth_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/responsive_container.dart';
import '../widgets/soft_card.dart';
import 'host_dashboard_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    if (v == null || v.isEmpty) return 'Enter your password';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await authController.signInWithEmail(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(builder: (_) => const HostDashboardPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: $e'),
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
      appBar: AppBar(title: const Text('Sign in')),
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
                                'Welcome back',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hosts use this account to manage events.',
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
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                validator: _passwordValidator,
                              ),
                              const SizedBox(height: 28),
                              PrimaryAppButton(
                                label: _loading ? 'Signing in…' : 'Sign in',
                                onPressed: _loading ? null : _submit,
                                minimumSize: const Size(double.infinity, 52),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        Navigator.of(context).push<void>(
                                          MaterialPageRoute<void>(builder: (_) => const SignUpPage()),
                                        );
                                      },
                                child: const Text('Create an account'),
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
