import 'package:flutter/material.dart';
import 'package:paws/pages/home_page.dart'; // make sure black color is defined here
import 'package:paws/widgets/buttons_input_widgets.dart';

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

      return SlideTransition(position: offsetAnimation, child: child);
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
            title: 'Name',
            description: 'Start by filling up your information!',
            bgColor: Colors.indigo,
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Pet Name',
            description: ' ',
            bgColor: const Color(0xff1eb090),
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Welcome to PAWS!',
            description: 'Thank you for registering. Enjoy the app.',
            bgColor: const Color(0xfffeae4f),
            textColor: Colors.white,
          ),
        ],
        onFinish: onFinish ?? () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final VoidCallback? onFinish;

  const OnboardingPagePresenter({
    super.key,
    required this.pages,
    this.onFinish,
  });

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPagePresenterState();
}

class _OnboardingPagePresenterState extends State<OnboardingPagePresenter> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final GlobalKey<_OwnerInfoFormState> ownerFormKey = GlobalKey<_OwnerInfoFormState>();
  final GlobalKey<_PetInfoFormState> petFormKey = GlobalKey<_PetInfoFormState>();

  late OwnerInfoForm ownerInfoForm;
  late PetInfoForm petInfoForm;

  Map<String, dynamic> ownerInfo = {};
  Map<String, dynamic> petInfo = {};

  @override
  void initState() {
    super.initState();
    ownerInfoForm = OwnerInfoForm(
      key: ownerFormKey, 
      onSaved: (data) {
        ownerInfo = data; //colt owner data
      }
    );
    petInfoForm = PetInfoForm(
      key: petFormKey, 
      onSaved: (data) {
        petInfo = data;  //colt same here, but pet
      }
    );
  }

bool _validateAndSaveCurrentPage() {
  if (_currentPage == 0 && ownerFormKey.currentState != null) {
    final valid = ownerFormKey.currentState!.validate();
    if (valid) ownerFormKey.currentState!._notifyParent();
    return valid;
  }
  if (_currentPage == 1 && petFormKey.currentState != null) {
    final valid = petFormKey.currentState!.validate();
    if (valid) petFormKey.currentState!._notifyParent();
    return valid;
  }
  return true;
}
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.pages.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, idx) {
                    final item = widget.pages[idx];
                    final formWidget = idx == 0
                        ? ownerInfoForm
                        : idx == 1
                            ? petInfoForm
                            : null;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.7),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: item.textColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: screenWidth > 600 ? 400 : screenWidth * 0.8,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: item.textColor,
                                    ),
                              ),
                            ),
                            if (formWidget != null) ...[
                              const SizedBox(height: 24),
                              formWidget,
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pages.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _currentPage == entry.key ? 30 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage > 0
                          ? TextButton(
                              onPressed: () {
                                if (_currentPage > 0) {
                                  _pageController.animateToPage(
                                    _currentPage - 1,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: const Text("Back", style: TextStyle(color: Colors.white)),
                            )
                          : const SizedBox(width: 70),
                      TextButton.icon(
                        onPressed: () {
                          if (!_validateAndSaveCurrentPage()) return;

                          if (_currentPage == widget.pages.length - 1) {
                            widget.onFinish?.call();
                          } else {
                            _pageController.animateToPage(
                              _currentPage + 1,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        icon: Icon(
                          _currentPage == widget.pages.length - 1 ? Icons.done : Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(
                          _currentPage == widget.pages.length - 1 ? 'Finish' : 'Next',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
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

class OwnerInfoForm extends StatefulWidget {
  final Function(Map<String, dynamic> ownerData) onSaved;

  const OwnerInfoForm({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<OwnerInfoForm> createState() => _OwnerInfoFormState();
}
class _OwnerInfoFormState extends State<OwnerInfoForm> {
  final _nameController = TextEditingController();
  String? nameError;

  String selectedCountry = 'United States';
  final List<String> countries = [
  'United States',
  'Canada',
  'United Kingdom',
  'Australia',
  'Germany',
  'France',
  'India',
  'Philippines',
  'Singapore',
  'Japan',
  'China',
  'South Korea',
  'Brazil',
  'Mexico',
  'Italy',
  'Spain',
  'Russia',
  'Netherlands',
  'Sweden',
  'Switzerland',
];

  final _birthdayController = TextEditingController();
  String? birthdayError;

  // Helper to validate date in dd/mm/yyyy format
  bool _isValidDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      // Additional checks if day/month/year matches after parsing (e.g., no overflow)
      return date.day == day && date.month == month && date.year == year;
    } catch (_) {
      return false;
    }
  }

  bool validate() {
    bool valid = true;

    if (_nameController.text.trim().isEmpty) {
      setState(() => nameError = 'Owner name is required');
      valid = false;
    } else {
      setState(() => nameError = null);
    }

    final birthdayText = _birthdayController.text.trim();
    if (birthdayText.isEmpty) {
      setState(() => birthdayError = 'Birthday is required');
      valid = false;
    } else if (!_isValidDate(birthdayText)) {
      setState(() => birthdayError = 'Invalid date format (dd/mm/yyyy)');
      valid = false;
    } else {
      setState(() => birthdayError = null);
    }

    return valid;
  }

  //colt - values are sent here.
  void _notifyParent() {
    final ownerData = {
      'name': _nameController.text.trim(),
      'country': selectedCountry,
      'birthday': _birthdayController.text.trim(), // you could parse to DateTime here if needed
    };
    widget.onSaved(ownerData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Owner Name Input
            //colt just in case youre having conflict with the custom made text form input, the widget is located at widgets/text_button_login.dart
          LoginBtn1(
            controller: _nameController,
            hintText: 'Owner Name',
            obscureText: false,
            errorText: nameError,
            onChanged: (val) {
              _notifyParent();
              if (nameError != null) validate();
            },
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          LoginBtn1(
            controller: _birthdayController,
            hintText: 'Birthday (dd/mm/yyyy)',
            obscureText: false,
            errorText: birthdayError,
            keyboardType: TextInputType.datetime,
            onChanged: (val) {
              _notifyParent();
              if (birthdayError != null) validate();
            },
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedCountry,
            items: countries
                .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedCountry = val;
                });
                _notifyParent();
              }
            },
            decoration: const InputDecoration(
              labelText: 'Country',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          
        ],
      ),
    );
  }
}
class PetInfoForm extends StatefulWidget {
  final Function(Map<String, dynamic> petData) onSaved;

  const PetInfoForm({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<PetInfoForm> createState() => _PetInfoFormState();
}

class _PetInfoFormState extends State<PetInfoForm> {
  final _nameController = TextEditingController();
  String petType = 'Canine';
  final _breedController = TextEditingController();
  final _birthdayController = TextEditingController();

  String? nameError;
  String? breedError;
  String? birthdayError;

  // Validate date in dd/mm/yyyy format
  bool _isValidDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);

      return date.day == day && date.month == month && date.year == year;
    } catch (_) {
      return false;
    }
  }

  bool validate() {
    bool valid = true;

    if (_nameController.text.trim().isEmpty) {
      setState(() => nameError = 'Pet name is required');
      valid = false;
    } else {
      setState(() => nameError = null);
    }

    if (_breedController.text.trim().isEmpty) {
      setState(() => breedError = 'Breed is required');
      valid = false;
    } else {
      setState(() => breedError = null);
    }

    final birthdayText = _birthdayController.text.trim();
    if (birthdayText.isEmpty) {
      setState(() => birthdayError = 'Birthday is required');
      valid = false;
    } else if (!_isValidDate(birthdayText)) {
      setState(() => birthdayError = 'Invalid date format (dd/mm/yyyy)');
      valid = false;
    } else {
      setState(() => birthdayError = null);
    }

    return valid;
  }

  //colt values sent here
  void _notifyParent() {
    // Optionally convert birthday to ISO string or null if invalid/empty
    String? isoBirthday;
    if (_birthdayController.text.trim().isNotEmpty && _isValidDate(_birthdayController.text.trim())) {
      final parts = _birthdayController.text.trim().split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      isoBirthday = date.toIso8601String();
    } else {
      isoBirthday = null;
    }

    final petData = {
      'name': _nameController.text.trim(),
      'type': petType,
      'breed': _breedController.text.trim(),
      'birthday': isoBirthday,
    };
    widget.onSaved(petData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoginBtn1(
            controller: _nameController,
            hintText: 'Pet Name',
            obscureText: false,
            errorText: nameError,
            onChanged: (val) {
              _notifyParent();
              if (nameError != null) validate();
            },
          ),
          const SizedBox(height: 12),
          LoginBtn1(
            controller: _breedController,
            hintText: 'Breed',
            obscureText: false,
            errorText: breedError,
            onChanged: (val) {
              _notifyParent();
              if (breedError != null) validate();
            },
          ),
          const SizedBox(height: 12),
          LoginBtn1(
            controller: _birthdayController,
            hintText: 'Birthday (dd/mm/yyyy)',
            obscureText: false,
            errorText: birthdayError,
            keyboardType: TextInputType.datetime,
            onChanged: (val) {
              _notifyParent();
              if (birthdayError != null) validate();
            },
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: petType,
                  items: ['Canine', 'Feline', 'Other']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        petType = val;
                      });
                      _notifyParent();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pet Type',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

