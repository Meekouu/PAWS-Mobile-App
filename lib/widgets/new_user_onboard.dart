import 'package:flutter/material.dart';
import 'package:paws/pages/home_page.dart'; 


Route createRouteToOnboarding(VoidCallback onFinish) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OnboardingPage1(
      onFinish: onFinish,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); 
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback? onFinish;

  const OnboardingPage1({super.key, this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPagePresenter(
        pages: [
          OnboardingPageModel(
            title: 'eahdyua',
            description: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
            bgColor: Colors.indigo,
          ),
          OnboardingPageModel(
            title: 'eiasdhaiusdfh',
            description: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
            bgColor: const Color(0xff1eb090),
          ),
          OnboardingPageModel(
            title: 'euagsdyuags',
            description: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
            bgColor: const Color(0xfffeae4f),
          ),
          OnboardingPageModel(
            title: 'YEEEEEEEEEEEET',
            description: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
            bgColor: Colors.purple,
          ),
        ],
        onFinish: () {
          if (onFinish != null) {
            onFinish!();
          } else {
            // Navigate to HomePage by default
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
      ),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;

  const OnboardingPagePresenter({
    super.key,
    required this.pages,
    this.onSkip,
    this.onFinish,
  });

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPagePresenterState();
}

class _OnboardingPagePresenterState extends State<OnboardingPagePresenter> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: widget.pages[_currentPage].bgColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.pages.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = widget.pages[idx];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: item.textColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: item.textColor,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pages.map((item) {
                  int index = widget.pages.indexOf(item);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _currentPage == index ? 30 : 8,
                    height: 8,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.comfortable,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        widget.onSkip?.call();
                      },
                      child: const Text("Skip"),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.comfortable,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (_currentPage == widget.pages.length - 1) {
                          widget.onFinish?.call();
                        } else {
                          _pageController.animateToPage(
                            _currentPage + 1,
                            curve: Curves.easeInOutCubic,
                            duration: const Duration(milliseconds: 250),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Text(_currentPage == widget.pages.length - 1 ? "Finish" : "Next"),
                          const SizedBox(width: 8),
                          Icon(_currentPage == widget.pages.length - 1 ? Icons.done : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPageModel {
  final String title;
  final String description;
  final Color bgColor;
  final Color textColor;

  OnboardingPageModel({
    required this.title,
    required this.description,
    this.bgColor = Colors.blue,
    this.textColor = Colors.white,
  });
}

