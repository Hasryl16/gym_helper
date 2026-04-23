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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AppAuthProvider>();
    final ok = await auth.signUpWithEmail(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? AppStrings.errorGeneric)),
      );
    }
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
          onPressed: () => context.go(RouteNames.signIn),
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
                  AppStrings.signUp,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Start tracking your form today.',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Name
                AuthTextField(
                  controller: _nameController,
                  label: AppStrings.displayNameLabel,
                  autofillHints: const [AutofillHints.name],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AppStrings.errorDisplayNameRequired;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppSpacing.md),

                // Email
                AuthTextField(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.newUsername, AutofillHints.email],
                  validator: emailValidator,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppSpacing.md),

                // Password
                AuthTextField(
                  controller: _passwordController,
                  label: AppStrings.passwordLabel,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: passwordValidator,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signUp(),
                ),

                const SizedBox(height: AppSpacing.xxl),

                PrimaryButton(
                  label: AppStrings.signUp,
                  onPressed: isLoading ? null : _signUp,
                  isLoading: isLoading,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Sign in link
                Center(
                  child: GestureDetector(
                    onTap: () => context.go(RouteNames.signIn),
                    child: RichText(
                      text: TextSpan(
                        text: '${AppStrings.hasAccount} ',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.signInLink,
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
