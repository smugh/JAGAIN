import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/services/permission_service.dart';
import '../../i18n/app_locale.dart';
import '../../theme/app_theme.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _taglineFadeAnimation;

  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _animController.forward();

    // Trigger permission checks during splash load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestInitialPermissions();
    });

    // Automatically navigate to MainShell after delay
    _timer = Timer(const Duration(milliseconds: 2300), () {
      _navigateToMain();
    });
  }

  void _navigateToMain() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor =
        isDark ? JagainColors.darkBackground : JagainColors.canvas;
    final cardBg = isDark ? JagainColors.darkSurface : Colors.white;
    final primaryAccent =
        isDark ? JagainColors.primaryLight : JagainColors.primaryDark;

    return GestureDetector(
      onTap: _navigateToMain,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // Ambient soft background glow
            PositionCenterGlow(isDark: isDark),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Centered Animated Logo without Text
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF04B185).withValues(
                                  alpha: isDark ? 0.35 : 0.22,
                                ),
                                blurRadius: 28,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: primaryAccent.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/icons/vaficon_hijau.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Welcome Message & Brand Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            strings.isId
                                ? 'Selamat Datang di'
                                : 'Welcome to',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: isDark
                                  ? JagainColors.darkMuted
                                  : JagainColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'JAGAIN',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                              color: isDark
                                  ? Colors.white
                                  : JagainColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Official JAGAIN Tagline
                    FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: primaryAccent.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  size: 15,
                                  color: primaryAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  strings.isId
                                      ? 'Jaga yang Berarti'
                                      : 'Care for what matters',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryAccent,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strings.primaryTagline, // "Jangan cuma punya, JAGAIN."
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? JagainColors.darkMuted
                                  : JagainColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Subtle loading indicator and tap to skip
                    FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 140,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strings.isId
                                ? 'Ketuk untuk melanjutkan'
                                : 'Tap anywhere to continue',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: (isDark
                                      ? JagainColors.darkMuted
                                      : JagainColors.muted)
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PositionCenterGlow extends StatelessWidget {
  const PositionCenterGlow({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF04B185).withValues(
                  alpha: isDark ? 0.18 : 0.12,
                ),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
