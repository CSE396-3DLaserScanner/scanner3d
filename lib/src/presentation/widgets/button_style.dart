import 'package:flutter/material.dart';

class ButtonStyles {
  Widget button(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        fixedSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        onPressed();
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
