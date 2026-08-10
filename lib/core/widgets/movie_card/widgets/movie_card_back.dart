import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/movie.dart';
import '../../../../providers/history_provider.dart';

class MovieCardBack extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;
  final bool initialEditMode;

  const MovieCardBack({
    super.key,
    required this.movie,
    required this.onTap,
    this.initialEditMode = false,
  });

  @override
  State<MovieCardBack> createState() => _MovieCardBackState();
}

class _MovieCardBackState extends State<MovieCardBack> {
  late bool _isEditing;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.movie.watchDate ?? DateTime.now();
    _isEditing = widget.initialEditMode || widget.movie.watchDate == null;
  }

  void _confirmDelete() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Remove History',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Remove "${widget.movie.title}" from your watch history?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<HistoryProvider>(
                context,
                listen: false,
              ).removeFromHistory(widget.movie.id, isTv: widget.movie.isTv);
              widget.movie.watchDate = null;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed "${widget.movie.title}" from history'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _pickCustomDate() async {
    HapticFeedback.lightImpact();
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5C6AC4),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1D2E),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: Center(
            child: FittedBox(fit: BoxFit.contain, child: child!),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveDate() async {
    HapticFeedback.mediumImpact();
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );

    widget.movie.watchDate = _selectedDate;
    await historyProvider.addToHistory(widget.movie, _selectedDate);

    if (mounted) {
      setState(() {
        _isEditing = false;
      });
      final dateStr = DateFormat('dd MMMM yyyy').format(_selectedDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "${widget.movie.title}" to History ($dateStr)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF161927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing
              ? const Color(0xFF5C6AC4).withOpacity(0.35)
              : Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                _isEditing
                    ? Icons.calendar_month_rounded
                    : Icons.history_rounded,
                size: 200,
                color: _isEditing
                    ? const Color(0xFF5C6AC4).withOpacity(0.04)
                    : Colors.greenAccent.withOpacity(0.03),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _isEditing
                        ? const Color(0xFF5C6AC4).withOpacity(0.08)
                        : Colors.greenAccent.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isEditing
                              ? const Color(0xFF5C6AC4).withOpacity(0.2)
                              : Colors.greenAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isEditing
                              ? Icons.edit_calendar_rounded
                              : Icons.history_toggle_off_rounded,
                          color: _isEditing
                              ? const Color(0xFF8B95E5)
                              : Colors.greenAccent,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'SELECT WATCH DATE' : 'WATCH HISTORY',
                            style: TextStyle(
                              color: _isEditing
                                  ? const Color(0xFF8B95E5)
                                  : Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            _isEditing
                                ? 'Tap box below to pick date'
                                : 'Activity Log',
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (!_isEditing)
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
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            onSelected: (value) {
                              if (value == 'change_date') {
                                setState(() {
                                  _isEditing = true;
                                });
                              } else if (value == 'delete') {
                                _confirmDelete();
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
                          onPressed: () {
                            if (widget.movie.watchDate != null) {
                              setState(() {
                                _isEditing = false;
                                _selectedDate = widget.movie.watchDate!;
                              });
                            } else {
                              widget.onTap();
                            }
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white54,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Body Content (Editing vs Viewing)
                  if (_isEditing) ...[
                    // Date Display Box
                    InkWell(
                      onTap: _pickCustomDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C6AC4).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF5C6AC4).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE').format(_selectedDate),
                                    style: const TextStyle(
                                      color: Color(0xFF9EA7F2),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    DateFormat(
                                      'dd MMMM yyyy',
                                    ).format(_selectedDate),
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
                                color: const Color(
                                  0xFF5C6AC4,
                                ).withOpacity(0.25),
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

                    const SizedBox(height: 10),

                    // Large Prominent Save Date Button
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C6AC4),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: const Color(0xFF5C6AC4).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _saveDate,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Save Watch Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // View Mode Body
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
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
                          if (widget.movie.watchDate != null) ...[
                            Text(
                              DateFormat(
                                'EEEE',
                              ).format(widget.movie.watchDate!),
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                'dd MMMM yyyy',
                              ).format(widget.movie.watchDate!),
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
                    ),
                  ],

                  const Spacer(),

                  // Footer Row
                  Container(
                    padding: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white10, width: 0.8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: widget.onTap,
                          child: Row(
                            children: [
                              Icon(
                                Icons.flip_to_front_rounded,
                                color: _isEditing
                                    ? const Color(0xFF8B95E5)
                                    : Colors.greenAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isEditing ? 'Cancel' : 'Return',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
