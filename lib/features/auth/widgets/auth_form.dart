import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../core/constants/app_strings.dart';

/// Reusable styled text input for auth forms.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && _obscure,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      style: GoogleFonts.dmSans(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}

/// Standard required field validator.
String? requiredValidator(String? v) {
  if (v == null || v.trim().isEmpty) return AppStrings.errorRequiredField;
  return null;
}

/// Email format validator.
String? emailValidator(String? v) {
  if (v == null || v.trim().isEmpty) return AppStrings.errorInvalidEmail;
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailRegex.hasMatch(v.trim())) return AppStrings.errorInvalidEmail;
  return null;
}

/// Password minimum length validator.
String? passwordValidator(String? v) {
  if (v == null || v.isEmpty) return AppStrings.errorWeakPassword;
  if (v.length < 8) return AppStrings.errorWeakPassword;
  return null;
}

/// Google sign-in button.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onPressed == null ? 0.5 : 1.0,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: const Border.fromBorderSide(
              BorderSide(color: AppColors.borderDefault),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                  ),
                )
              else ...[
                // Google "G" colored icon via text (avoids asset dependency)
                _GoogleIcon(),
                const SizedBox(width: AppSpacing.md),
                Text(
                  AppStrings.continueWithGoogle,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Simplified colored arc representation of Google G
    final colors = [
      const Color(0xFF4285F4), // blue
      const Color(0xFFEA4335), // red
      const Color(0xFFFBBC05), // yellow
      const Color(0xFF34A853), // green
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.butt;

    const sweepAngle = 1.5; // ~86 degrees each
    double startAngle = -0.4;

    for (final color in colors) {
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1.5),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_GoogleIconPainter oldDelegate) => false;
}
