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

    // Adjust sizes based on screen width
    final horizontalPadding = screenWidth * 0.05; // e.g. 20 on 400px screen
    final contentPadding = screenWidth * 0.035; // ~14 on 400px
    final fontSize = screenWidth.clamp(320, 600) * 0.045;
 // ~18 on 400px

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(40),
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: contentPadding),
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
                style: TextStyle(fontSize: fontSize),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(contentPadding),
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
                    height: 0.8,
                    fontSize: fontSize * 0.8,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.01), // small bottom spacing
            ],
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