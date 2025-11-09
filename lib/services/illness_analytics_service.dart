import 'package:cloud_firestore/cloud_firestore.dart';

class IllnessAnalyticsService {
  IllnessAnalyticsService._internal();
  static final IllnessAnalyticsService _instance = IllnessAnalyticsService._internal();
  factory IllnessAnalyticsService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reads the same source as the website dashboard: `checkIns` collection
  // Aggregates diagnosis counts in the last [days] days.
  Future<List<MapEntry<String, int>>> getRecentIllnessCounts({int days = 30}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(days: days));

      print('IllnessAnalyticsService: Fetching checkIns from ${start.toString()} to ${now.toString()}');

      final snap = await _db
          .collection('check_ins')
          .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('checkInDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('checkInDate', descending: true)
          .get();

      print('IllnessAnalyticsService: Found ${snap.docs.length} check-in documents');

      final Map<String, int> counts = {};
      for (final doc in snap.docs) {
        final data = doc.data();
        final raw = (data['diagnosis'] ?? '').toString().trim();
        if (raw.isEmpty) {
          print('IllnessAnalyticsService: Skipping document ${doc.id} - empty diagnosis');
          continue;
        }
        final diag = raw.replaceAll(RegExp(r'\s+'), ' ').split(' ').map((w) {
          if (w.isEmpty) return w;
          final first = w.substring(0, 1).toUpperCase();
          final rest = w.length > 1 ? w.substring(1).toLowerCase() : '';
          return '$first$rest';
        }).join(' ');
        counts[diag] = (counts[diag] ?? 0) + 1;
      }

      print('IllnessAnalyticsService: Aggregated ${counts.length} unique diagnoses');
      counts.forEach((key, value) => print('  - $key: $value cases'));

      final list = counts.entries.toList();
      list.sort((a, b) => b.value.compareTo(a.value));
      return list;
    } catch (e, stackTrace) {
      print('IllnessAnalyticsService ERROR: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
