// screens/splash_screen.dart

import 'package:chatforge/core/config.dart';
import 'package:chatforge/data/storage/init_service.dart';
import 'package:chatforge/screens/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  final Duration fadeOutDuration;
  final Curve progressCurve;

  const SplashScreen({
    required this.child,
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.progressCurve = Curves.easeInOut,
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _initialized = false;
  String _status = 'Initializing...';
  double _targetProgress = 0.0;
  bool _errored = false;
  String _error_message = "";
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(parent: _progressController, curve: widget.progressCurve)
    );

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Run heavy initialization tasks in parallel
      await Future.wait([
        InitService.initialize(
          onProgress: (status, progress) {
            if (!mounted) return;
            setState(() {
              _status = status;
              _targetProgress = progress;
              _progressAnimation = Tween<double>(
                begin: _progressAnimation.value,
                end: _targetProgress,
              ).animate(CurvedAnimation(
                parent: _progressController,
                curve: widget.progressCurve,
              ));
              _progressController.forward(from: 0);
            });
          },
          onError: (error) {
            _error_message = error;
          }
        ),
      ]);

      if (_targetProgress >= 1.0) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        setState(() => _isFadingOut = true);
        await Future.delayed(widget.fadeOutDuration);
        if (!mounted) return;
        setState(() => _initialized = true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errored = true;
        _status = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return widget.child;
    } else if (_errored) {
      return ErrorScreen(
        error: _error_message.isNotEmpty ? _error_message : _status,
        onRetry: () => Restart.restartApp(),
      );
    }

    return Material(
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) => AnimatedOpacity(
          duration: _isFadingOut ? widget.fadeOutDuration : Duration.zero,
          opacity: _isFadingOut ? 0.0 : 1.0,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(BuildConfig.isPro ? 'assets/icon/icon_pro.png' : 'assets/icon/icon.png', height: 96),
                      const SizedBox(height: 32),
                      Text(
                        'ChatForge',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 32),
                      LinearProgressIndicator(value: _progressAnimation.value),
                      const SizedBox(height: 16),
                      Text(
                        _status,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
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
  }
}