import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white), // Add an error icon
          const SizedBox(width: 10), // Add some spacing
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.redAccent, // Set background color for error
      duration: const Duration(seconds: 3), // Adjust duration as needed
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String successMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white), // Add an error icon
          const SizedBox(width: 10), // Add some spacing
          Expanded(
            child: Text(
              successMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.greenAccent, // Set background color for error
      duration: const Duration(seconds: 3), // Adjust duration as needed
    ),
  );
}
