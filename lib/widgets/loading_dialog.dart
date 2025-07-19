import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> showLoadingDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Lottie.asset(
          'assets/lottie/loading.json',
          width: 120,
          height: 120,
          repeat: true,
        ),
      ),
    ),
  );
}
