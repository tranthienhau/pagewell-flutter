import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pagewell/data/audio_engine.dart';
import 'package:pagewell/data/catalog.dart';
import 'package:pagewell/data/cms_feed.dart';
import 'package:pagewell/data/epub_parser.dart';
import 'package:pagewell/data/search_index.dart';
import 'package:pagewell/domain/models.dart';

void main() {
  final epub = EpubParser.parse(File('assets/books/the-salt-road.epub').readAsBytesSync());

  test('EPUB parser reads metadata and spine-ordered chapters', () {
    expect(epub.title, 'The Salt Road');
    expect(epub.author, 'Imogen Hale');
    expect(epub.chapters.map((c) => c.title), ['Chapter 1 - The Well', 'Chapter 2 - Salt and Dust', 'Chapter 3 - Night Market', 'Chapter 4 - The River Gate']);
    expect(epub.chapters[1].paragraphs.first, startsWith('The caravan left before dawn'));
    expect(epub.paragraphCount, greaterThan(20));
  });

  test('search covers reference, books, articles and EPUB body text', () {
    final idx = SearchIndex(books: books, articles: articles, reference: refEntries, bookText: {'salt-road': epub.chapters.expand((c) => c.paragraphs).join(' ')});
    final tide = idx.query('tide', SearchScope.all);
    expect(tide.reference.first.id, 'tide'); // exact term ranks first
    expect(tide.books.map((b) => b.id), contains('tide-keeper'));
    expect(tide.articles.map((a) => a.id), contains('tide-tables'));
    expect(idx.query('tide', SearchScope.reference).books, isEmpty);
    // "camel" only appears inside the EPUB text.
    expect(idx.query('camel', SearchScope.books).books.single.id, 'salt-road');
    expect(idx.query('t', SearchScope.all).total, 0);
  });

  test('stream engine plays at speed, buffers ahead and honours the sleep timer', () {
    var s = const StreamState(bookId: 'quiet-hours', chapterIndex: 0, position: Duration.zero, duration: Duration(minutes: 40), buffered: Duration.zero, playing: true, speed: 2);
    s = s.tick(const Duration(seconds: 1));
    expect(s.position, const Duration(seconds: 2)); // 2x speed
    expect(s.buffered, const Duration(seconds: 6)); // the stream fills ahead of playback
    s = s.copyWith(buffered: s.position).tick(const Duration(seconds: 1));
    expect(s.position, const Duration(seconds: 4));
    expect(s.buffered, const Duration(seconds: 8));
    expect(s.copyWith(buffered: s.position).tick(const Duration(seconds: 5)).position, const Duration(seconds: 14)); // capped by what is buffered (4 + 3 x 10 > 4 + 10)
    s = s.copyWith(sleepLeft: const Duration(seconds: 1)).tick(const Duration(seconds: 2));
    expect(s.playing, isFalse);
    expect(s.seekBy(const Duration(seconds: -99)).position, Duration.zero);
    expect(const StreamState(bookId: 'x', chapterIndex: 0, position: Duration.zero, duration: Duration.zero, buffered: Duration.zero, speed: 2).nextSpeed, 0.75);
  });

  test('CMS feed finds the next scheduled item and publishes it', () {
    final feed = CmsFeed.fromJson(File('assets/cms/feed.json').readAsStringSync());
    expect(feed.upNext!.id, 'narration');
    expect(feed.count(CmsStatus.scheduled), 2);
    final after = feed.publish('narration', DateTime(2026, 11, 9, 9));
    expect(after.upNext!.id, 'north-of-quiet');
    expect(after.publishedTotal, feed.publishedTotal + 1);
    expect(after.entries.firstWhere((e) => e.id == 'narration').status, CmsStatus.published);
  });
}
