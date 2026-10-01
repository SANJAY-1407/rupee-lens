import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final AnimationController _entranceController;
  late final AnimationController _backgroundController;

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _entranceController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService.signInWithEmail(email: email, password: password);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed. Please try again.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password for registration'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService.signUpWithEmail(email: email, password: password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Account created successfully! Logging in...')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your email to reset password')),
      );
      return;
    }

    try {
      await AuthService.sendPasswordReset(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password reset email sent! Check your inbox.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to send password reset email.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: RepaintBoundary(
                child: _GeminiSplashBackground(
                  controller: _backgroundController,
                  accent: colors.primary,
                  isDark: isDark,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.surface.withOpacity(isDark ? 0.38 : 0.48),
                    colors.surface.withOpacity(isDark ? 0.72 : 0.80),
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, keyboardInset + 24),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: Center(
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _entranceController,
                          curve: Curves.easeOutCubic,
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.045),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _entranceController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colors.surface.withOpacity(
                                      isDark ? 0.86 : 0.92,
                                    ),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: colors.outline.withOpacity(
                                        isDark ? 0.34 : 0.18,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          isDark ? 0.32 : 0.12,
                                        ),
                                        blurRadius: 32,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: _LoginContent(
                                      colors: colors,
                                      isDark: isDark,
                                      entranceAnimation: _entranceController,
                                      emailController: emailController,
                                      passwordController: passwordController,
                                      obscurePassword: obscurePassword,
                                      isLoading: isLoading,
                                      onPasswordVisibilityPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                      onLogin: login,
                                      onSignUp: signUp,
                                      onForgotPassword: forgotPassword,
                                    ),
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent({
    required this.colors,
    required this.isDark,
    required this.entranceAnimation,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onPasswordVisibilityPressed,
    required this.onLogin,
    required this.onSignUp,
    required this.onForgotPassword,
  });

  final ColorScheme colors;
  final bool isDark;
  final Animation<double> entranceAnimation;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onPasswordVisibilityPressed;
  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fieldFill = colors.surface.withOpacity(isDark ? 0.70 : 0.78);

    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. HERO RUPEELENS BRANDING IMAGE WITH FADE + SCALE ANIMATION
          Center(
            child: _RupeeLensBrandingHero(
              isDark: isDark,
              animation: entranceAnimation,
            ),
          ),
          const SizedBox(height: 18),

          // 2. WELCOME / LOGIN TITLE
          Text(
            'RupeeLens',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track every rupee. Spend wisely.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome back💓',
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to continue managing your expenses.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // 3. EMAIL FIELD
          TextField(
            controller: emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: _fieldDecoration(
              colors: colors,
              fillColor: fieldFill,
              label: 'Email address',
              hint: 'info@gmail.com',
              icon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: 16),

          // 4. PASSWORD FIELD
          TextField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => isLoading ? null : onLogin(),
            autofillHints: const [AutofillHints.password],
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: _fieldDecoration(
              colors: colors,
              fillColor: fieldFill,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: onPasswordVisibilityPressed,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),

          // FORGOT PASSWORD
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 5. LOGIN BUTTON
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Row(
                        key: ValueKey('login'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // DIVIDER
          Row(
            children: [
              Expanded(child: Divider(color: colors.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'NEW HERE?',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Expanded(child: Divider(color: colors.outlineVariant)),
            ],
          ),
          const SizedBox(height: 12),

          // 6. CREATE ACCOUNT / SIGN UP
          TextButton(
            onPressed: isLoading ? null : onSignUp,
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Create an account',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required ColorScheme colors,
    required Color fillColor,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.outline.withOpacity(0.45)),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colors.primary, width: 1.8),
      ),
    );
  }
}

/// Prominently displays the exact RupeeLens gold/black branding image in a
/// premium container with scale + fade entrance animation.
class _RupeeLensBrandingHero extends StatelessWidget {
  const _RupeeLensBrandingHero({
    required this.isDark,
    required this.animation,
  });

  final bool isDark;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 160,
            maxWidth: 240,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.38),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(isDark ? 0.22 : 0.14),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/rupeelens_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFFFFD700),
                  size: 48,
                ),
                SizedBox(height: 6),
                Text(
                  'RupeeLens',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An in-file adaptation of FlutterFX's Gemini Splash composition: a glowing
/// four-point star forms, falls, and creates a soft burst of expanding waves.
class _GeminiSplashBackground extends StatelessWidget {
  const _GeminiSplashBackground({
    required this.controller,
    required this.accent,
    required this.isDark,
  });

  final Animation<double> controller;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => CustomPaint(
        painter: _GeminiSplashPainter(
          progress: controller.value,
          accent: accent,
          isDark: isDark,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GeminiSplashPainter extends CustomPainter {
  const _GeminiSplashPainter({
    required this.progress,
    required this.accent,
    required this.isDark,
  });

  final double progress;
  final Color accent;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final base = isDark ? const Color(0xFF07120E) : const Color(0xFFF1FAF5);
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    final fog = Paint()
      ..shader = RadialGradient(
        colors: [accent.withOpacity(isDark ? 0.26 : 0.18), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.18, size.height * 0.20),
        radius: size.width * 0.9,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.20),
      size.width * 0.9,
      fog,
    );

    final t = progress;
    final fallT = ((t - 0.20) / 0.58).clamp(0.0, 1.0);
    final burstT = ((t - 0.76) / 0.24).clamp(0.0, 1.0);
    final origin = Offset(size.width * 0.52, size.height * 0.25);
    final destination = Offset(size.width * 0.52, size.height * 0.82);
    final position = Offset.lerp(
      origin,
      destination,
      Curves.easeInQuart.transform(fallT),
    )!;

    if (fallT > 0 && burstT < 1) {
      final trail = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, accent.withOpacity(0.38)],
        ).createShader(Rect.fromPoints(
          Offset(position.dx - 16, origin.dy),
          Offset(position.dx + 16, position.dy),
        ))
        ..strokeWidth = 3 + fallT * 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(origin, position, trail);
    }

    if (burstT > 0) {
      for (var i = 0; i < 3; i++) {
        final radius = (30 + i * 38) * Curves.easeOut.transform(burstT);
        canvas.drawCircle(
          destination,
          radius,
          Paint()
            ..color = accent.withOpacity((0.18 - i * 0.04) * (1 - burstT))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
      _drawWaves(canvas, size, burstT);
    }

    final formT = (t / 0.24).clamp(0.0, 1.0);
    if (burstT < 0.82) {
      final starSize = 20 + 26 * Curves.easeOutBack.transform(formT);
      final glowPaint = Paint()
        ..color = accent.withOpacity(isDark ? 0.55 : 0.40)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + 12 * fallT);
      canvas.drawCircle(position, starSize * 0.9, glowPaint);
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(t * math.pi * 1.8);
      canvas.scale(1, 1 + fallT * 2.4);
      canvas.translate(-position.dx, -position.dy);
      canvas.drawPath(
        _starPath(position, starSize),
        Paint()..color = Color.lerp(accent, Colors.white, 0.28)!,
      );
      canvas.restore();
    }
  }

  void _drawWaves(Canvas canvas, Size size, double burstT) {
    final y = size.height * 0.88;
    for (var layer = 0; layer < 3; layer++) {
      final amplitude = (9 + layer * 6) * (1 - burstT * 0.5);
      final path = Path()..moveTo(0, y + layer * 10);
      for (var x = 0.0; x <= size.width; x += 8) {
        final phase = x / size.width * math.pi * 3 + burstT * math.pi * 4;
        path.lineTo(x, y + layer * 10 + math.sin(phase) * amplitude);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = accent.withOpacity((0.09 - layer * 0.02) * (1 - burstT)),
      );
    }
  }

  Path _starPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + i * math.pi / 2;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        final previous = -math.pi / 2 + (i - 1) * math.pi / 2;
        final controlAngle = previous + math.pi / 4;
        path.quadraticBezierTo(
          center.dx + math.cos(controlAngle) * radius * 0.25,
          center.dy + math.sin(controlAngle) * radius * 0.25,
          point.dx,
          point.dy,
        );
      }
    }
    path.quadraticBezierTo(center.dx + radius * 0.18, center.dy - radius * 0.18,
        center.dx, center.dy - radius);
    return path;
  }

  @override
  bool shouldRepaint(covariant _GeminiSplashPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.isDark != isDark;
  }
}
