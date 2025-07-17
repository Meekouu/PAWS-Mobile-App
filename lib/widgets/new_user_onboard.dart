import 'package:flutter/material.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/widgets/buttons_input_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Controllers for forms
  final ownerNameController = TextEditingController();
  final ownerBirthdayController = TextEditingController();
  String selectedCountry = 'United States';

  final petNameController = TextEditingController();
  final petBreedController = TextEditingController();
  final petBirthdayController = TextEditingController();
  String petType = 'Canine';

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

  void _nextPage() {
    if (_currentPage == 0) {
      if (ownerNameController.text.trim().isEmpty || _validateDate(ownerBirthdayController.text.trim()) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete your info')),
        );
        return;
      }
    } else if (_currentPage == 1) {
      if (petNameController.text.trim().isEmpty || petBreedController.text.trim().isEmpty || _validateDate(petBirthdayController.text.trim()) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete pet info')),
        );
        return;
      }
    }

    if (_currentPage < 2) {
      _controller.animateToPage(_currentPage + 1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  HomePage()));
    }
  }

  List<Widget> _buildPages() {
    return [
      _buildFormPage(
        title: 'Owner Info',
        backgroundColor: Colors.indigo,
        content: Column(
          children: [
            LoginBtn1(controller: ownerNameController, hintText: 'Name', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            LoginBtn1(controller: ownerBirthdayController, hintText: 'Birthday (dd/mm/yyyy)', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              items: ['United States', 'Canada', 'UK', 'Philippines'].map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
              onChanged: (val) => setState(() => selectedCountry = val ?? selectedCountry),
              decoration: const InputDecoration(labelText: 'Country', fillColor: Colors.white, filled: true, border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      _buildFormPage(
        title: 'Pet Info',
        backgroundColor: Colors.teal,
        content: Column(
          children: [
            LoginBtn1(controller: petNameController, hintText: 'Pet Name', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            LoginBtn1(controller: petBreedController, hintText: 'Breed', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            LoginBtn1(controller: petBirthdayController, hintText: 'Birthday (dd/mm/yyyy)', obscureText: false, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: petType,
              items: ['Canine', 'Feline', 'Other'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => petType = val ?? petType),
              decoration: const InputDecoration(labelText: 'Pet Type', fillColor: Colors.white, filled: true, border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      _buildFormPage(
        title: 'Welcome to PAWS!',
        backgroundColor: Colors.orange,
        content: const Text('Thank you for registering. Enjoy the app!', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    ];
  }

  Widget _buildFormPage({required String title, required Widget content, required Color backgroundColor}) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SafeArea(
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Expanded(child: SingleChildScrollView(child: content)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _nextPage,
              icon: Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentPage == 2 ? 'Finish' : 'Next'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: backgroundColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: _buildPages(),
      ),
    );
  }
}
