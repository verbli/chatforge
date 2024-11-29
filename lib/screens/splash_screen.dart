// screens/splash_screen.dart

import 'dart:math';

import 'package:chatforge/data/storage/init_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({required this.child, Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialized = false;
  String _status = 'Initializing...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await InitService.initialize(
        onProgress: (status, progress) {
          setState(() {
            _status = status;
            _progress = progress;
            if (progress >= 1.0) _initialized = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return widget.child;
    }

    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icon/icon.png', height: 96,),
                  const SizedBox(height: 32),
                  Text(
                    'ChatForge',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  LinearProgressIndicator(value: _progress),
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
    );
  }
}