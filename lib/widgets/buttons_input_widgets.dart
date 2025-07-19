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
    final height = isLandscape ? screenHeight * 0.10 : screenHeight * 0.05;

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
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: true, // Reduce vertical space
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Less vertical padding
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
                height: 0.8, // Reduce error text height
                fontSize: fontSize * 0.7, // Smaller error font
                color: Colors.redAccent,
              ),
              alignLabelWithHint: true,
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
  final Widget? icon;

  const CTAButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final horizontalPadding = screenWidth * 0.05;
    final buttonHeight = screenHeight * 0.075;

    final shortestSide = screenSize.shortestSide;
    final fontSize = (shortestSide * 0.04).clamp(14.0, 24.0);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Container(
          height: buttonHeight.clamp(48.0, 70.0),
          decoration: BoxDecoration(
            color: black,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

