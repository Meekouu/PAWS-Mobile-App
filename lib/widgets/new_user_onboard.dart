import 'package:flutter/material.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/buttons_input_widgets.dart';
import 'package:paws/widgets/database_service.dart';
import 'package:paws/widgets/loading_dialog.dart';
import 'package:paws/animations/animations.dart';
class OnboardingScreen extends StatefulWidget {
  final String? firebaseUID;
  const OnboardingScreen({super.key, required this.firebaseUID});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _checking = true;
  bool _revealing = false;
  Offset _revealOffset = Offset.zero;

  // Controllers for input
  final ownerNameController = TextEditingController();
  final ownerBirthdayController = TextEditingController();
  String selectedCountry = 'United States';

  final petNameController = TextEditingController();
  final petBreedController = TextEditingController();
  final petBirthdayController = TextEditingController();
  String petType = 'Canine';
  String petSex = 'Male';

  Map<String, dynamic> ownerInput = {};
  Map<String, dynamic> petInput = {};

  @override
  void initState() {
    super.initState();
    _checkIfUserExists();
  }

  @override
  void dispose() {
    _controller.dispose();
    ownerNameController.dispose();
    ownerBirthdayController.dispose();
    petNameController.dispose();
    petBreedController.dispose();
    petBirthdayController.dispose();
    super.dispose();
  }

  String? _validateDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length != 3) return 'Use dd/mm/yyyy';
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final parsed = DateTime(year, month, day);
      if (parsed.day != day || parsed.month != month || parsed.year != year) {
        return 'Invalid date';
      }
      return null;
    } catch (_) {
      return 'Invalid date';
    }
  }

 void _nextPage({required Offset originOffset}) async {
    if (_currentPage == 1) {
      if (ownerNameController.text.trim().isEmpty ||
          _validateDate(ownerBirthdayController.text.trim()) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete your info')),
        );
        return;
      }
    } else if (_currentPage == 2) {
      if (petNameController.text.trim().isEmpty ||
          petBreedController.text.trim().isEmpty ||
          _validateDate(petBirthdayController.text.trim()) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete pet info')),
        );
        return;
      } else {
        final uid = widget.firebaseUID;
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in.')),
          );
          return;
        }
        ownerInput = {
          'owner': ownerNameController.text.trim(),
          'ownerBirthday': ownerBirthdayController.text.trim(),
          'ownerCountry': selectedCountry,
        };
        petInput = {
          'petName': petNameController.text.trim(),
          'petBreed': petBreedController.text.trim(),
          'petBirthday': petBirthdayController.text.trim(),
          'petType': petType,
          'petSex': petSex,
        };
        await DatabaseService().create(path: 'users/$uid', data: ownerInput);
        await DatabaseService().create(path: 'pet/$uid', data: petInput);
      }
    }

    if (_currentPage == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  HomePage()));
      return;
    }

    setState(() {
      _revealOffset = originOffset;
      _revealing = true;
    });
  }



  void _checkIfUserExists() async {
    WidgetsBinding.instance.addPostFrameCallback((_) => showLoadingDialog(context));
    await Future.delayed(const Duration(seconds: 2));

    if (widget.firebaseUID != null) {
      final exists = await DatabaseService().exists(path: 'users/${widget.firebaseUID}');
      if (exists && context.mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  HomePage()));
        return;
      }
    }

    if (context.mounted) {
      Navigator.pop(context); // Close dialog
      setState(() => _checking = false);
    }
  }

  final List<Color> pageColors = [
  Color(0xFF28262C), // Page 0 - Raisin Black
  Color(0xFF998FC7), // Page 1 - Tropical Indigo
  Color(0xFFD4C2FC), // Page 2 - Periwinkle
  Color(0xFFF9F5FF), // Page 3 - Magnolia
];



  List<Widget> _buildPages() {
    return [
      _buildWelcomePage(),
      _buildFormPage(
  title: 'Owner Info',
  backgroundColor: pageColors[1],
  content: Column(
    children: [
      FadeSlideIn(
              delay: const Duration(milliseconds: 0),
              child: LoginBtn1(
                controller: ownerNameController,
                hintText: 'Name',
                obscureText: false,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delay: const Duration(milliseconds: 150),
              child: LoginBtn1(
                controller: ownerBirthdayController,
                hintText: 'Birthday (dd/mm/yyyy)',
                obscureText: false,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: DropdownButtonFormField<String>(
                value: selectedCountry,
                items: ['United States', 'Canada', 'UK', 'Philippines']
                    .map((country) => DropdownMenuItem(
                        value: country, child: Text(country)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => selectedCountry = val ?? selectedCountry),
                decoration: const InputDecoration(
                  labelText: 'Country',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      _buildFormPage(
        title: 'Pet Info',
        backgroundColor: pageColors[2],
        content: Column(
          children: [
            LoginBtn1(controller: petNameController, hintText: 'Pet Name', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            LoginBtn1(controller: petBreedController, hintText: 'Breed', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            LoginBtn1(controller: petBirthdayController, hintText: 'Birthday (dd/mm/yyyy)', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: petSex,
              items: ['Male', 'Female'].map((sex) => DropdownMenuItem(
                value: sex,
                child: Text(sex),
              )).toList(),
              onChanged: (val) => setState(() => petSex = val ?? petSex),
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: petType,
              items: ['Canine', 'Feline', 'Other'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => petType = val ?? petType),
              decoration: const InputDecoration(
              fillColor: Colors.white, 
              filled: true, 
              border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      _buildFormPage(
        title: 'Welcome to PAWS!',
        backgroundColor: pageColors[3],
        content: const Text('Thank you for registering. Enjoy the app!', style: TextStyle(fontSize: 18, color: primaryColor)),
      ),
    ];
  }

  Widget _buildFormPage({
    required String title,
    required Widget content,
    required Color backgroundColor,
  }) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      content,
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final offset = renderBox.localToGlobal(Offset.zero) + Offset(renderBox.size.width / 2, renderBox.size.height / 2);
                  _nextPage(originOffset: offset);
                },
              label: Text(_currentPage == 3 ? 'Finish' : 'Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: pageColors[
                  (_currentPage + 1) < pageColors.length ? _currentPage + 1 : _currentPage
                ],
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Container(
      color: pageColors[0],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeSlideIn(
              delay: const Duration(milliseconds: 0),
              child: const Text(
              "Let's Get You Started!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                "We'll ask you for some quick details about you and your pet to personalize your experience.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              delay: const Duration(milliseconds: 400),
              child: ElevatedButton.icon(
                onPressed: () {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final offset = renderBox.localToGlobal(Offset.zero) + Offset(renderBox.size.width / 2, renderBox.size.height / 2);
                  _nextPage(originOffset: offset);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Get Started"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  if (_checking) return const Scaffold();

  return Stack(
    children: [
      Scaffold(
        body: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentPage = index),
          children: _buildPages(),
        ),
      ),
      if (_revealing)
        CircularRevealTransition(
          centerOffset: _revealOffset,
          revealColor: pageColors[(_currentPage + 1).clamp(0, pageColors.length - 1)],
          onComplete: () {
            setState(() {
              _revealing = false;
              _currentPage = (_currentPage + 1).clamp(0, pageColors.length - 1);
              _controller.jumpToPage(_currentPage); // ← fixes page not moving
            });
          },
        ),
    ],
  );
}
}
