import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovieCardBackEditBody extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final VoidCallback onSaveDate;

  const MovieCardBackEditBody({
    super.key,
    required this.selectedDate,
    required this.onPickDate,
    required this.onSaveDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF5C6AC4).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF5C6AC4).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Half: Date Picker Trigger
          InkWell(
            onTap: onPickDate,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(selectedDate),
                          style: const TextStyle(
                            color: Color(0xFF9EA7F2),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMMM yyyy').format(selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6AC4).withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Color(0xFF9EA7F2),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(height: 1, color: const Color(0xFF5C6AC4).withOpacity(0.3)),
          // Bottom Half: Save Action CTA Button
          InkWell(
            onTap: onSaveDate,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(9),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF5C6AC4),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(9)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Save Watch Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
