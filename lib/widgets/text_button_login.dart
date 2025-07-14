import 'package:flutter/material.dart';
import 'package:paws/themes/themes.dart';

class LoginBtn1 extends StatelessWidget {
  final String hintText;
  final Icon? icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const LoginBtn1({
    super.key,
    required this.hintText,
    required this.controller,
    this.icon,
    required this.obscureText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        // Removed fixed height for flexibility
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(40),
            right: Radius.circular(40),
          ),
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.horizontal(
            end: Radius.circular(40),
            start: Radius.circular(40),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                obscureText: obscureText,
                validator: validator,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18), // input text size
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20),
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  suffixIcon: icon,
                  suffixIconColor: black,
                  errorStyle: const TextStyle(
                    height: 1.2, // adjusts spacing between field and error text
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 4), // spacing between input and error (if visible)
            ],
          ),
        ),
      ),
    );
  }
}
