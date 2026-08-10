import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import 'movie_card/widgets/horizontal_movie_card.dart';
import 'movie_card/widgets/movie_card_back.dart';
import 'movie_card/widgets/standard_movie_card.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final bool isHorizontal;

  const MovieCard({super.key, required this.movie, this.isHorizontal = false});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    if (_isRevealed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isRevealed = !_isRevealed;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontal) {
      return HorizontalMovieCard(movie: widget.movie);
    }

    final revealLimit = MediaQuery.of(context).size.width * 0.75;

    Widget currentCard;
    if (widget.movie.watchDate == null) {
      currentCard = StandardMovieCard(movie: widget.movie);
    } else {
      currentCard = GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragExtent += details.primaryDelta!;
            if (_dragExtent > 0) _dragExtent = 0;
            if (_dragExtent < -revealLimit) _dragExtent = -revealLimit;
            _controller.value = _dragExtent.abs() / revealLimit;
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragExtent.abs() > revealLimit / 2 ||
              details.primaryVelocity! < -500) {
            _controller.forward();
            _isRevealed = true;
            _dragExtent = -revealLimit;
          } else {
            _controller.reverse();
            _isRevealed = false;
            _dragExtent = 0;
          }
          HapticFeedback.lightImpact();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _controller.value * math.pi;
            final isBackVisible = angle > math.pi / 2;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isBackVisible
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: MovieCardBack(
                        movie: widget.movie,
                        onTap: _toggleReveal,
                      ),
                    )
                  : StandardMovieCard(
                      movie: widget.movie,
                      onFlip: _toggleReveal,
                    ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: currentCard,
    );
  }
}
