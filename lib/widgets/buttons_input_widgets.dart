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
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    final horizontalPadding = screenWidth * 0.05;
    final fontSize = (isLandscape ? screenHeight : screenWidth).clamp(320, 600) * 0.045;

    final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    final height = isLandscape ? screenHeight * 0.13 : screenHeight * 0.08;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: Container(
          height: height.clamp(56.0, 100.0),
          width: maxWidth,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: fontSize),
            textAlignVertical: TextAlignVertical.center, // center vertically
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20), // control top/bottom
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              suffixIcon: icon,
              suffixIconColor: black,
              errorText: errorText,
              errorStyle: TextStyle(
                height: 1.2,
                fontSize: fontSize * 0.75,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class CTAButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const CTAButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final horizontalPadding = screenWidth * 0.05; // 5% of width
    final buttonHeight = screenHeight * 0.075; // 7.5% of height
    final fontSize = screenWidth * 0.05; // ~20 on 400px width

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Container(
          height: buttonHeight.clamp(48.0, 70.0), // optional max/min height
          decoration: BoxDecoration(
            color: black, // from your theme
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize.clamp(16.0, 24.0),
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}