import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routing/route_names.dart';
import '../widgets/auth_form.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AppAuthProvider>();
    final ok = await auth.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (!ok && mounted) {
      _showError(auth.errorMessage ?? AppStrings.errorGeneric);
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<AppAuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!ok && mounted) {
      _showError(auth.errorMessage ?? AppStrings.errorGeneric);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final isLoading = auth.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go(RouteNames.welcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                Text(
                  AppStrings.signIn,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Good to have you back.',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Email
                AuthTextField(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: emailValidator,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppSpacing.md),

                // Password
                AuthTextField(
                  controller: _passwordController,
                  label: AppStrings.passwordLabel,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  validator: passwordValidator,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Sign in button
                PrimaryButton(
                  label: AppStrings.signIn,
                  onPressed: isLoading ? null : _signIn,
                  isLoading: isLoading,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'OR',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Google sign in
                GoogleSignInButton(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  isLoading: isLoading,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: () => context.go(RouteNames.signUp),
                    child: RichText(
                      text: TextSpan(
                        text: '${AppStrings.noAccount} ',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.signUpLink,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
