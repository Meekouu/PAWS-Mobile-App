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
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        // Adjust height if needed, validation errors might need extra space
        height: 60,
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
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(20),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              suffixIcon: icon,
              suffixIconColor: black,
              errorStyle: const TextStyle(
                height: 0.1, // reduces vertical space of error text
                fontSize: 8,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
