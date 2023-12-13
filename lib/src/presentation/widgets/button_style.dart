import 'package:flutter/material.dart';

class ButtonStyles {
  static Widget button(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 36, 161, 157)),
    );
  }
}
