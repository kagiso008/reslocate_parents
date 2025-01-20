import 'package:flutter/material.dart';

class MyToast {
  static void showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Create a Toast widget with improved design
    final toastWidget = Positioned(
      bottom: isKeyboardVisible
          ? MediaQuery.of(context).size.height * 0.85
          : 50, // Adjust position based on keyboard visibility
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blueAccent, // Change to a color of your choice
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4), // Shadow position
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline, // Icon can change based on message type
                color: Colors.white,
              ),
              const SizedBox(width: 8), // Space between icon and text
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // Bold text
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Create an overlay entry
    final overlayEntry = OverlayEntry(builder: (context) => toastWidget);

    // Show the toast
    overlay.insert(overlayEntry);

    // Remove the toast after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
