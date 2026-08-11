import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovieCardBackViewBody extends StatelessWidget {
  final DateTime? watchDate;
  final VoidCallback onTapEdit;

  const MovieCardBackViewBody({
    super.key,
    required this.watchDate,
    required this.onTapEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Watched On',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          if (watchDate != null) ...[
            Text(
              DateFormat('EEEE').format(watchDate!),
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd MMMM yyyy').format(watchDate!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ] else ...[
            const Text(
              'Tap to set watch date',
              style: TextStyle(
                color: Color(0xFF9EA7F2),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
