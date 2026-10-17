import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({Key? key, required this.optionText, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.15) : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
              border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3), width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? primaryColor : Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(optionText, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
