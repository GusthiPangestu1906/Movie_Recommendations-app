import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../providers/history_provider.dart';
import 'api_service.dart';

class SeederService {
  final ApiService _apiService = ApiService();
  
  final Map<String, int> _monthMap = {
    'jan': 1, 'januari': 1,
    'feb': 2, 'februari': 2,
    'mar': 3, 'maret': 3,
    'apr': 4, 'april': 4,
    'mei': 5,
    'jun': 6, 'juni': 6,
    'jul': 7, 'juli': 7,
    'agu': 8, 'agustus': 8, 'agt': 8,
    'sep': 9, 'september': 9,
    'okt': 10, 'oktober': 10,
    'nov': 11, 'november': 11,
    'des': 12, 'desember': 12,
  };

  DateTime? _parseDate(String dateStr) {
    try {
      final cleanStr = dateStr.toLowerCase().replaceAll(',', '').trim();
      final parts = cleanStr.split(' ');
      
      // Expected formats: 
      // "sabtu 26 juli 25" -> parts[1], parts[2], parts[3]
      // "jum 22 desember 2023" -> parts[1], parts[2], parts[3]
      
      if (parts.length < 3) return null;
      
      int day = int.parse(parts[1]);
      int? month = _monthMap[parts[2]];
      if (month == null) return null;
      
      int year = int.parse(parts[3]);
      if (year < 100) year += 2000; // Handle "25" as 2025
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  Future<void> seedData(HistoryProvider provider, String rawText, Function(int, int) onProgress) async {
    final lines = rawText.split('\n');
    DateTime? currentDate;
    List<Map<String, dynamic>> itemsToProcess = [];

    // First pass: Extract all titles and dates
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.contains(':')) {
        final split = line.split(':');
        final datePart = split[0];
        final moviePart = split.sublist(1).join(':').trim();

        final parsedDate = _parseDate(datePart);
        if (parsedDate != null) {
          currentDate = parsedDate;
        }

        if (moviePart.isNotEmpty) {
          itemsToProcess.add({'title': moviePart, 'date': currentDate});
        }
      } else if (RegExp(r'^\d+\.').hasMatch(line)) {
        final title = line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
        itemsToProcess.add({'title': title, 'date': currentDate});
      } else if (line.startsWith('•')) {
        final title = line.replaceFirst('•', '').trim();
        itemsToProcess.add({'title': title, 'date': currentDate});
      } else {
        final maybeDate = _parseDate(line);
        if (maybeDate != null) {
          currentDate = maybeDate;
        } else {
          // Ignore lines that look like headers/notes (e.g., "(Grace = Keanggunan)")
          if (!line.startsWith('(') && line.length > 2) {
            itemsToProcess.add({'title': line, 'date': currentDate});
          }
        }
      }
    }

    // Second pass: Process movies with de-duplication
    int processed = 0;
    Set<String> processedTitles = {}; // Simple title-based de-duplication within the same import

    for (var item in itemsToProcess) {
      final String title = item['title'];
      final DateTime? date = item['date'];
      
      // Basic normalization for de-duplication
      final normalizedTitle = title.toLowerCase().trim();
      if (processedTitles.contains(normalizedTitle)) {
        processed++;
        onProgress(processed, itemsToProcess.length);
        continue;
      }

      await _processMoviePart(provider, title, date);
      processedTitles.add(normalizedTitle);
      
      processed++;
      onProgress(processed, itemsToProcess.length);
      
      // Add a small delay to avoid hitting API rate limits
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _processMoviePart(HistoryProvider provider, String text, DateTime? date) async {
    // If text contains multiple titles separated by numbers or bullets, handle them? 
    // For now, assume it's one title per call
    final movieTitle = text.trim();
    if (movieTitle.isEmpty) return;

    try {
      final results = await _apiService.searchMovies(movieTitle);
      if (results.isNotEmpty) {
        final movie = results.first;
        await provider.addToHistory(movie, date ?? DateTime.now());
      }
    } catch (e) {
      print('Error seeding $movieTitle: $e');
    }
  }
}
