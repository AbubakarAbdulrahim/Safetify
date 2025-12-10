import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Report Incidents Easily',
      'subtitle': 'Capture and submit incidents in real-time to keep your community informed and safe.',
      'image': 'assets/images/7.png',
      'color': AppColors.alertRed,
      'icon': Icons.camera_alt_rounded,
    },
    {
      'title': 'Stay Alert & Connected',
      'subtitle': 'Get real-time updates and alerts about nearby safety issues in your area.',
      'image': 'assets/images/9.png',
      'color': const Color(0xFF10B981),
      'icon': Icons.notifications_active_rounded,
    },
    {
      'title': 'Track Safety Analytics',
      'subtitle': 'View comprehensive analytics and insights about safety trends in your community.',
      'image': 'assets/images/8.png',
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.analytics_rounded,
    },
    {
      'title': 'AI-Powered Assistance',
      'subtitle': 'Get instant help and safety recommendations from our intelligent AI assistant.',
      'image': 'assets/images/7.png',
      'color': const Color(0xFFF59E0B),
      'icon': Icons.psychology_rounded,
    },
    {
      'title': 'Together, We Stay Safe',
      'subtitle': 'Join thousands of users building a safer and more responsive community.',
      'image': 'assets/images/8.png',
      'color': AppColors.safetyBlue,
      'icon': Icons.groups_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/home');
        });
      }
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _onPageChanged(int index) {
    setState(() => _pageIndex = index);
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _onPrimaryButtonPressed() {
    if (_pageIndex == _pages.length - 1) {
      _markOnboardingComplete();
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_pageIndex];
    final pageColor = currentPage['color'] as Color;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              pageColor.withOpacity(0.1),
              pageColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Logo
                    // Row(
                    //   children: [
                    //     // Image.asset(
                    //     //   'assets/images/usable.png',
                    //     //   height: 28,
                    //     // ),
                    //     const SizedBox(width: 8),
                    //     // Text(
                    //     //   'Safetify',
                    //     //   style: GoogleFonts.poppins(
                    //     //     fontSize: 20,
                    //     //     fontWeight: FontWeight.bold,
                    //     //     color: pageColor,
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
                    // Skip Button
                    if (_pageIndex < _pages.length - 1)
                      TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final item = _pages[i];
                    final isActive = i == _pageIndex;

                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Icon
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: (item['color'] as Color).withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (item['color'] as Color).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 80,
                                color: item['color'] as Color,
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Animated Title
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Text(
                                item['title']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Animated Subtitle
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Text(
                                item['subtitle']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),

                          // // Feature Highlights (only on last page)
                          // if (i == _pages.length - 1) ...[
                          //   const SizedBox(height: 30),
                          //   FadeTransition(
                          //     opacity: _fadeAnimation,
                          //     // child: Container(
                          //     //   padding: const EdgeInsets.all(20),
                          //     //   decoration: BoxDecoration(
                          //     //     color: Theme.of(context).cardColor,
                          //     //     borderRadius: BorderRadius.circular(16),
                          //     //     border: Border.all(
                          //     //       color: Theme.of(context).dividerColor,
                          //     //     ),
                          //     //   ),
                          //     //   // child: Column(
                          //     //   //   children: [
                          //     //   //     _buildStatItem('10,000+', 'Active Users', Icons.people),
                          //     //   //     const Divider(height: 20),
                          //     //   //     _buildStatItem('50,000+', 'Reports Filed', Icons.report),
                          //     //   //     const Divider(height: 20),
                          //     //   //     _buildStatItem('24/7', 'Support', Icons.support_agent),
                          //     //   //   ],
                          //     //   // ),
                          //     // ),
                          //   ),
                          // ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) {
                    final isActive = _pageIndex == index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive ? pageColor : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Primary Button (Next/Get Started)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onPrimaryButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pageColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _pageIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Secondary Button (only on last page)
                    if (_pageIndex == _pages.length - 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            _markOnboardingComplete();
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: pageColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              color: pageColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _pages[_pageIndex]['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _pages[_pageIndex]['color'],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
