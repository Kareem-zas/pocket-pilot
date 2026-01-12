import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool enabled;
  final TextInputType keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final double width;
  final double fontSize;

  const AppTextField({
    Key? key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.onChanged,
    this.width = 260,
    this.fontSize = 11,
  }) : super(key: key);

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: GlobalColors.textColor, fontSize: fontSize),
      filled: true,
      fillColor: GlobalColors.textFieldColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(color: GlobalColors.textColor2),
        decoration: _decoration(),
        onChanged: onChanged,
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double fontSize;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = 260,
    this.height = 63,
    this.fontSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: GlobalColors.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: GlobalColors.textColor2,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
