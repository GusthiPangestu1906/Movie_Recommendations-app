import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/movie.dart';
import '../../../../providers/history_provider.dart';
import 'back_card/movie_card_back_edit_body.dart';
import 'back_card/movie_card_back_footer.dart';
import 'back_card/movie_card_back_header.dart';
import 'back_card/movie_card_back_view_body.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Icon(
                  _isEditing
                      ? Icons.calendar_month_rounded
                      : Icons.history_rounded,
                  key: ValueKey<bool>(_isEditing),
                  size: 200,
                  color: _isEditing
                      ? const Color(0xFF5C6AC4).withOpacity(0.04)
                      : Colors.greenAccent.withOpacity(0.03),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Column(
                  key: ValueKey<bool>(_isEditing),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Component
                    MovieCardBackHeader(
                      isEditing: _isEditing,
                      onChangeDate: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      onDelete: _confirmDelete,
                      onClose: () {
                        if (widget.movie.watchDate != null) {
                          setState(() {
                            _isEditing = false;
                            _selectedDate = widget.movie.watchDate!;
                          });
                        } else {
                          widget.onTap();
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    // Body Component (Editing vs Viewing)
                    if (_isEditing)
                      MovieCardBackEditBody(
                        selectedDate: _selectedDate,
                        onPickDate: _pickCustomDate,
                        onSaveDate: _saveDate,
                      )
                    else
                      MovieCardBackViewBody(
                        watchDate: widget.movie.watchDate,
                        onTapEdit: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),

                    const Spacer(),

                    // Footer Component
                    MovieCardBackFooter(
                      movieTitle: widget.movie.title,
                      isEditing: _isEditing,
                      onTapReturn: widget.onTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
