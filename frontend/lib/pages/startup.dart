import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import '../initialization.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _gradientAnimation;

  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = [
    'Initializing security protocols...',
    'Connecting to safety network...',
    'Loading community updates...',
    'Preparing your dashboard...',
    'Almost ready...',
  ];

  Timer? _messageTimer;
  int _tapCount = 0;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _startMessageRotation();
    _navigateAfterDelay();
  }

  void _setupAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Gradient animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_gradientController);
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
        _pulseController.repeat(reverse: true);
        _gradientController.repeat();
      }
    });
  }

  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  void _navigateAfterDelay() {
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      
      // Wait for Firebase initialization to complete
      if (AppInitialization.initialization != null) {
        await AppInitialization.initialization;
      }

      if (!mounted) return;

      final user = AuthService().currentUser;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  void _handleTap() {
    _tapCount++;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 3), () {
      _tapCount = 0;
    });

    if (_tapCount >= 3) {
      // Easter egg - show a fun message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You found the secret! Stay safe out there!'),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
      _tapCount = 0;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _gradientController.dispose();
    _pulseController.dispose();
    _messageTimer?.cancel();
    _tapResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    AppColors.safetyBlue,
                    Colors.blueAccent.shade700,
                    _gradientAnimation.value,
                  )!,
                  Color.lerp(
                    const Color.fromARGB(255, 32, 1, 207),
                    Colors.blue.shade700,
                    _gradientAnimation.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles/dots
                ...List.generate(20, (index) {
                  return _buildFloatingDot(index);
                }),

                // Main content
                Center(
                  child: GestureDetector(
                    onTap: _handleTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo
                        FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/usable.png',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Animated Title
                        FadeTransition(
                          opacity: _textFadeAnimation,
                          child: AnimatedBuilder(
                            animation: _textSlideAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _textSlideAnimation.value),
                                child: child,
                              );
                            },
                            child: const Text(
                              'Safetify',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                // shadows: [
                                //   Shadow(
                                //     color: Colors.black26,
                                //     offset: Offset(0, 4),
                                //     blurRadius: 8,
                                //   ),
                                // ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Animated Tagline
                        FadeTransition(
                          opacity: _textFadeAnimation,
                          child: AnimatedBuilder(
                            animation: _textSlideAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _textSlideAnimation.value + 20),
                                child: child,
                              );
                            },
                            child: const Text(
                              'Empowering Safety Everywhere',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Custom Loading Indicator
                        // _buildCustomLoader(),

                        const SizedBox(height: 24),

                        // Rotating Loading Messages
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _loadingMessages[_currentMessageIndex],
                            key: ValueKey<int>(_currentMessageIndex),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Version number at bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: const Text(
                      'Version 1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingDot(int index) {
    final random = index * 0.1;
    final size = 4.0 + (index % 3) * 2.0;
    final duration = 3 + (index % 5);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: duration),
      builder: (context, value, child) {
        return Positioned(
          left: (index % 5) * MediaQuery.of(context).size.width / 5 + (value * 50 - 25),
          top: (index % 4) * MediaQuery.of(context).size.height / 4 + (value * 100 - 50),
          child: Opacity(
            opacity: 0.3 + (value * 0.4),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildCustomLoader() {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          // Outer ring
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          // Inner pulsing circle
          Center(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}