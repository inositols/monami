import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Consumer;
import 'package:monami/src/shared/base_scaffold.dart';
import 'package:monami/src/shared/monami_logo.dart';
import 'package:monami/src/utils/constants/app_colors.dart';

import 'splash_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _gradientController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Start animations sequentially
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _rotateController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _gradientController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      backgroundColor: AppColor.bgColor,
      builder: (_) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _fadeController,
            _scaleController,
            _rotateController,
            _gradientController,
          ]),
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      AppColor.bgColor,
                      const Color(0xFF667EEA),
                      _gradientAnimation.value * 0.3,
                    )!,
                    Color.lerp(
                      AppColor.bgColor,
                      const Color(0xFF764BA2),
                      _gradientAnimation.value * 0.2,
                    )!,
                  ],
                ),
              ),
              child: SizedBox.expand(
                child: Consumer(
                  builder: (_, ref, __) {
                    ref.read(splashViewModelProvider);
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Logo
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: RotationTransition(
                                turns: _rotateAnimation,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA)
                                            .withOpacity(
                                                _gradientAnimation.value * 0.3),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const MonamiLogo(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Animated Loading Text
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Welcome to Monami',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                                    .withOpacity(_fadeAnimation.value),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Animated Loading Indicator
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: 200,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: AnimatedBuilder(
                                animation: _gradientController,
                                builder: (context, child) {
                                  return LinearProgressIndicator(
                                    value: _gradientAnimation.value,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
