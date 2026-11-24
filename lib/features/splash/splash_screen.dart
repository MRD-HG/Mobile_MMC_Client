import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/common.dart';

/// Shows the MMC identity while content loads (no fixed 5-second wait).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const minDuration = Duration(milliseconds: 900);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final content = AppScope.of(context).content;
    unawaited(Future.wait([
      content.load(),
      Future<void>.delayed(SplashScreen.minDuration),
    ]).whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Image.asset(
                isDark
                    ? 'assets/images/brand/mmc_logo_dark.png'
                    : 'assets/images/brand/mmc_logo.png',
                semanticLabel: 'Morocco Microsoft Community',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: MmcSpacing.xxl),
            const SizedBox(width: 120, child: LogoStripe()),
            const Spacer(flex: 3),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: MmcSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
