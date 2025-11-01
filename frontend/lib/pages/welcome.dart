import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Report incidents easily',
      'subtitle': 'Capture and submit incidents in real-time to keep your community informed.',
      'image': 'assets/images/a.png',
    },
    {
      'title': 'Stay alert & connected',
      'subtitle': 'Get real-time updates and alerts about nearby safety issues.',
      'image': 'assets/images/b.png',
    },
    {
      'title': 'Together, we stay safe',
      'subtitle': 'Join others in building a safer and more responsive city.',
      'image': 'assets/images/c.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPrimaryButtonPressed() {
    if (_pageIndex == _pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final nextPage = _pageIndex + 1;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Fallback: update index immediately if controller not available
        setState(() => _pageIndex = nextPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final item = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item['image']!, height: 250, fit: BoxFit.contain),
                        const SizedBox(height: 30),
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _pageIndex == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _pageIndex == index ? AppColors.safetyBlue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50, // fixed height to match typical login button size
                child: ElevatedButton(
                  onPressed: _onPrimaryButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safetyBlue,
                    minimumSize: const Size.fromHeight(50),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _pageIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
