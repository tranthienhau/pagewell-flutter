import 'dart:convert';

import '../domain/models.dart';

/// Simulated headless-CMS feed. The app reads the schedule from a JSON document
/// (bundled here, served by the CMS API in production) and editors publish from the studio.
class CmsFeed {
  const CmsFeed({required this.entries, required this.publishedTotal});
  final List<CmsEntry> entries;
  final int publishedTotal;

  factory CmsFeed.fromJson(String source) {
    final j = jsonDecode(source) as Map<String, dynamic>;
    final list = (j['entries'] as List).cast<Map<String, dynamic>>().map(CmsEntry.fromJson).toList();
    return CmsFeed(entries: list, publishedTotal: (j['totals'] as Map)['published'] as int);
  }

  int count(CmsStatus s) => entries.where((e) => e.status == s).length;

  /// The next scheduled item (what goes live soonest).
  CmsEntry? get upNext {
    final s = entries.where((e) => e.status == CmsStatus.scheduled).toList()..sort((a, b) => a.date.compareTo(b.date));
    return s.isEmpty ? null : s.first;
  }

  CmsFeed publish(String id, DateTime now) => CmsFeed(
    entries: [for (final e in entries) e.id == id ? e.copyWith(status: CmsStatus.published, date: now) : e],
    publishedTotal: publishedTotal + 1,
  );
}
