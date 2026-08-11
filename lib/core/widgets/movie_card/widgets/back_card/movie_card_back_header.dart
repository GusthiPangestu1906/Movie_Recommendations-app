import 'package:flutter/material.dart';

class MovieCardBackHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onChangeDate;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const MovieCardBackHeader({
    super.key,
    required this.isEditing,
    required this.onChangeDate,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isEditing
                ? const Color(0xFF5C6AC4).withOpacity(0.2)
                : Colors.greenAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isEditing
                ? Icons.edit_calendar_rounded
                : Icons.history_toggle_off_rounded,
            color: isEditing ? const Color(0xFF8B95E5) : Colors.greenAccent,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'SELECT WATCH DATE' : 'WATCH HISTORY',
              style: TextStyle(
                color: isEditing ? const Color(0xFF8B95E5) : Colors.greenAccent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              isEditing ? 'Tap box below to pick date' : 'Activity Log',
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (!isEditing)
          Theme(
            data: Theme.of(
              context,
            ).copyWith(cardColor: const Color(0xFF1A1D2E)),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white70,
                size: 20,
              ),
              color: const Color(0xFF1A1D2E),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              onSelected: (value) {
                if (value == 'change_date') {
                  onChangeDate();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'change_date',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_calendar_rounded,
                        color: Color(0xFF9EA7F2),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Change Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete History',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white54,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
