import 'package:flutter/material.dart';
import 'root_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _data = [
    OnboardingData(
      title: 'Plan with Ease',
      description: 'Organize weddings, parties, and meetings etc - all in one place.',
      icon: Icons.celebration,
    ),
    OnboardingData(
      title: 'Everything You Need',
      description: 'Customize every detail to match your style and budget. Venues, catering, decor, and more - just a tap away',
      icon: Icons.dashboard_customize,
    ),
    OnboardingData(
      title: 'Simplify Your Planning',
      description: 'Your perfect event is just a tap away. Let\'s begin!',
      icon: Icons.event_available,
      isLast: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _data.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _data[index].icon,
                              size: 150,
                              color: const Color(0xFF904CC1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _data[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF904CC1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _data[index].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _data.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF904CC1)
                              : Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _data.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RootWrapper()),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(_currentPage == _data.length - 1 ? 'Get Started' : 'Next'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RootWrapper()),
                      );
                    },
                    child: const Text('Skip', style: TextStyle(color: Color(0xFF904CC1))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final bool isLast;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    this.isLast = false,
  });
}
