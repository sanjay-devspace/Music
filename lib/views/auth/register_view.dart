import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/core/theme/tunehive_colors.dart';
import 'package:tunehive/app/theme/app_motion.dart';
import 'package:tunehive/app/theme/app_radius.dart';
import 'package:tunehive/app/theme/app_spacing.dart';
import 'package:tunehive/app/theme/app_typography.dart';
import 'package:tunehive/core/animation/fade_slide.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TuneHiveColors.charcoalBlack,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 720;
            if (isDesktop) {
              return _buildDesktopLayout(constraints);
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          child: _buildBrandingPanel(),
        ),
        Container(
          width: constraints.maxWidth * 0.45,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildFormContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TuneHiveColors.cardSurface, TuneHiveColors.charcoalBlack],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeSlide(
                delay: AppMotion.staggerBase,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: TuneHiveColors.electricBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.equalizer_rounded,
                    color: TuneHiveColors.electricBlue,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeSlide(
                delay: AppMotion.staggerBase + AppMotion.staggerStep,
                child: Text(
                  'TuneHive',
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FadeSlide(
                delay: AppMotion.staggerBase + AppMotion.staggerStep * 2,
                child: Text(
                  'Discover, save, and share\nthe music you love.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: TuneHiveColors.coolWhite,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return FadeSlide(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            _buildLogo(),
            const SizedBox(height: AppSpacing.xl),
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
            _buildNameField(),
            const SizedBox(height: AppSpacing.md),
            _buildEmailField(),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(),
            const SizedBox(height: AppSpacing.md),
            _buildConfirmPasswordField(),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildErrorText(),
            ],
            const SizedBox(height: AppSpacing.xl),
            _buildCreateAccountButton(),
            const SizedBox(height: AppSpacing.xl),
            _buildDivider(),
            const SizedBox(height: AppSpacing.xl),
            _buildSocialButtons(),
            const SizedBox(height: AppSpacing.xxl),
            _buildSignInLink(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const FadeSlide(
      delay: Duration.zero,
      child: Center(
        child: Icon(
          Icons.equalizer_rounded,
          color: TuneHiveColors.electricBlue,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        FadeSlide(
          delay: AppMotion.staggerBase,
          child: Text(
            'Create Account',
            style: AppTextStyles.headline.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FadeSlide(
          delay: AppMotion.staggerBase + AppMotion.staggerStep,
          child: Text(
            'Join the hive',
            style: AppTextStyles.body.copyWith(
              color: TuneHiveColors.coolWhite,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 2,
      child: _AuthTextField(
        controller: _nameController,
        hintText: 'Full name',
        prefixIcon: Icons.person_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter your name';
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 3,
      child: _AuthTextField(
        controller: _emailController,
        hintText: 'Email address',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter your email';
          if (!value.contains('@')) return 'Please enter a valid email';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 4,
      child: _AuthTextField(
        controller: _passwordController,
        hintText: 'Password',
        prefixIcon: Icons.lock_outlined,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: TuneHiveColors.mutedText,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter a password';
          if (value.length < 8) return 'Password must be at least 8 characters';
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 5,
      child: _AuthTextField(
        controller: _confirmPasswordController,
        hintText: 'Confirm password',
        prefixIcon: Icons.lock_outlined,
        obscureText: _obscureConfirmPassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: TuneHiveColors.mutedText,
            size: 20,
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please confirm your password';
          if (value != _passwordController.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  Widget _buildErrorText() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 6,
      child: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: _isLoading ? null : _handleRegister,
          style: FilledButton.styleFrom(
            backgroundColor: TuneHiveColors.electricBlue,
            foregroundColor: TuneHiveColors.coolWhite,
            disabledBackgroundColor: TuneHiveColors.electricBlue.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: TuneHiveColors.coolWhite,
                  ),
                )
              : const Text('Create Account'),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 7,
      child: Row(
        children: [
          const Expanded(child: Divider(color: TuneHiveColors.elevatedSurface, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'or continue with',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: TuneHiveColors.mutedText,
              ),
            ),
          ),
          const Expanded(child: Divider(color: TuneHiveColors.elevatedSurface, height: 1)),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 8,
      child: Row(
        children: [
          Expanded(
            child: _SocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Google',
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _SocialButton(
              icon: Icons.apple,
              label: 'Apple',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInLink() {
    return FadeSlide(
      delay: AppMotion.staggerBase + AppMotion.staggerStep * 9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              color: TuneHiveColors.coolWhite,
            ),
          ),
          GestureDetector(
            onTap: () => context.go(RoutePaths.login),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: TuneHiveColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared text field ───────────────────────────────────────────────────────

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 15,
        color: TuneHiveColors.coolWhite,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          color: TuneHiveColors.mutedText,
        ),
        prefixIcon: Icon(prefixIcon, color: TuneHiveColors.mutedText, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: TuneHiveColors.cardSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: TuneHiveColors.elevatedSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: TuneHiveColors.elevatedSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: TuneHiveColors.electricBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        errorStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          color: Colors.red,
        ),
      ),
    );
  }
}

// ─── Social button ───────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: TuneHiveColors.coolWhite,
          backgroundColor: TuneHiveColors.cardSurface,
          side: const BorderSide(color: TuneHiveColors.elevatedSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: TuneHiveColors.coolWhite),
            const SizedBox(width: AppSpacing.sm),
            Text(label),
          ],
        ),
      ),
    );
  }
}
