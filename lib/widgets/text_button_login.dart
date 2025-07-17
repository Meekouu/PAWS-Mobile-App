import 'package:flutter/material.dart';
import 'package:paws/themes/themes.dart';
class LoginBtn1 extends StatelessWidget {
  final String hintText;
  final Widget? icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? errorText; 
  final Color? backgroundColor;

  const LoginBtn1({
    super.key,
    required this.hintText,
    required this.controller,
    this.icon,
    required this.obscureText,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.errorText,
    this.backgroundColor, // add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(40),
            right: Radius.circular(40),
          ),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
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
                onChanged: onChanged,
                keyboardType: keyboardType,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18),
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
                  errorText: errorText,  // Pass errorText here!
                  errorStyle: const TextStyle(
                    height: 1.2,
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
