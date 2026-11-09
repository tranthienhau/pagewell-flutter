import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog.dart';
import '../features/article/article_screen.dart';
import '../features/book/book_screen.dart';
import '../features/membership/membership_screen.dart';
import '../features/player/player_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/reference/reference_screen.dart';
import '../features/studio/studio_screen.dart';
import '../state/providers.dart';

/// One place for every route, so screens never import each other in a cycle.
abstract final class Nav {
  static Future<void> _push(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute<void>(builder: (_) => w));

  static void book(BuildContext c, String id) => _push(c, BookScreen(id: id));
  static void article(BuildContext c, String id) => _push(c, ArticleScreen(id: id, openBook: book));
  static void membership(BuildContext c) => _push(c, const MembershipScreen());
  static void studio(BuildContext c) => _push(c, const StudioScreen());
  static void player(BuildContext c) => _push(c, const PlayerScreen());

  static void reference(BuildContext c, WidgetRef ref, String id) => openGated(
    c,
    ref,
    premium: refById(id).premium,
    page: (_) => ReferenceScreen(id: id, openBook: book),
  );

  static void read(BuildContext c, WidgetRef ref, String bookId) => openGated(
    c,
    ref,
    premium: bookById(bookId).premium,
    page: (_) => ReaderScreen(bookId: bookId),
  );

  static void listen(BuildContext c, WidgetRef ref, String bookId, {int chapter = 0}) {
    if (!ref.read(canOpenProvider(bookById(bookId).premium))) return membership(c);
    ref.read(playerProvider.notifier).open(bookId, chapterIndex: chapter);
    player(c);
  }
}
