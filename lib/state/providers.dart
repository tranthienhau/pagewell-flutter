import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_engine.dart';
import '../data/catalog.dart';
import '../data/cms_feed.dart';
import '../data/epub_parser.dart';
import '../data/search_index.dart';
import '../domain/models.dart';

/// "Today" for the demo, fixed so screenshots are stable.
final clockProvider = Provider<DateTime>((ref) => DateTime(2026, 11, 9, 8, 30));

// ---------------------------------------------------------------- account
class Session {
  const Session({required this.name, required this.email, this.guest = false});
  final String name;
  final String email;
  final bool guest;
}

class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  /// Mock auth: any email + a password of 6+ characters signs in. Real builds call the
  /// auth API (Firebase Auth / Cognito / Supabase) here.
  String? signIn(String email, String password) {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return 'Enter a valid email';
    if (password.length < 6) return 'Password needs 6+ characters';
    state = Session(name: 'Ava Morgan', email: email);
    ref.read(libraryProvider.notifier).restoreFor(email);
    return null;
  }

  void continueAsGuest() {
    state = const Session(name: 'Guest reader', email: '', guest: true);
    ref.read(libraryProvider.notifier).clear();
  }

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

// ---------------------------------------------------------------- membership
class Membership {
  const Membership({this.premium = false, this.plan, this.booksUsed = 2, this.freeLimit = 3});
  final bool premium;
  final String? plan;
  final int booksUsed;
  final int freeLimit;
}

class MembershipNotifier extends Notifier<Membership> {
  @override
  Membership build() => const Membership();

  /// Simulated store purchase (StoreKit / Play Billing via RevenueCat in production).
  void startTrial(String plan) => state = Membership(premium: true, plan: plan, booksUsed: state.booksUsed);
  void cancel() => state = const Membership();
}

final membershipProvider = NotifierProvider<MembershipNotifier, Membership>(MembershipNotifier.new);

/// Free readers can open free titles; premium titles and premium reference entries need Premium.
final canOpenProvider = Provider.family<bool, bool>((ref, premiumContent) => !premiumContent || ref.watch(membershipProvider).premium);

// ---------------------------------------------------------------- library
class LibraryState {
  const LibraryState({required this.owned, required this.progress});
  final List<String> owned;
  final Map<String, double> progress;
  bool get isEmpty => owned.isEmpty;
}

class LibraryNotifier extends Notifier<LibraryState> {
  static const _seed = LibraryState(
    owned: ['salt-road', 'quiet-hours', 'tide-keeper', 'lanterns', 'small-rivers', 'north-of-quiet'],
    progress: {'salt-road': .42, 'quiet-hours': .64},
  );

  @override
  LibraryState build() => _seed;

  void restoreFor(String email) => state = _seed; // synced library from the account
  void clear() => state = const LibraryState(owned: [], progress: {});
  void addFreeTitles() => state = LibraryState(owned: [for (final b in books) if (!b.premium) b.id], progress: state.progress);
  void setProgress(String id, double p) => state = LibraryState(owned: state.owned.contains(id) ? state.owned : [...state.owned, id], progress: {...state.progress, id: p.clamp(0, 1)});
}

final libraryProvider = NotifierProvider<LibraryNotifier, LibraryState>(LibraryNotifier.new);

// ---------------------------------------------------------------- EPUB + reader
final epubProvider = FutureProvider.family<EpubBook, String>((ref, asset) async {
  final data = await rootBundle.load(asset);
  return EpubParser.parse(data.buffer.asUint8List());
});

enum ReaderTheme { light, sepia, dark }

class ReaderPrefs {
  const ReaderPrefs({this.fontSize = 18, this.theme = ReaderTheme.light});
  final double fontSize;
  final ReaderTheme theme;
  ReaderPrefs copyWith({double? fontSize, ReaderTheme? theme}) => ReaderPrefs(fontSize: fontSize ?? this.fontSize, theme: theme ?? this.theme);
}

class ReaderPrefsNotifier extends Notifier<ReaderPrefs> {
  @override
  ReaderPrefs build() => const ReaderPrefs();
  void setSize(double v) => state = state.copyWith(fontSize: v);
  void setTheme(ReaderTheme t) => state = state.copyWith(theme: t);
}

final readerPrefsProvider = NotifierProvider<ReaderPrefsNotifier, ReaderPrefs>(ReaderPrefsNotifier.new);

/// Current chapter per book (reading position).
class ReadingPosNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {'salt-road': 1};
  void set(String bookId, int chapter) => state = {...state, bookId: chapter};
}

final readingPosProvider = NotifierProvider<ReadingPosNotifier, Map<String, int>>(ReadingPosNotifier.new);

// ---------------------------------------------------------------- bookmarks + favourites
class BookmarksNotifier extends Notifier<List<Bookmark>> {
  @override
  List<Bookmark> build() {
    final now = ref.read(clockProvider);
    return [
      Bookmark(id: 'b1', kind: BookmarkKind.page, targetId: 'salt-road', label: 'Page 131 - Chapter 2', snippet: 'The caravan left before dawn, when the salt still held the cold of the night.', createdAt: now.subtract(const Duration(hours: 2))),
      Bookmark(id: 'b2', kind: BookmarkKind.audio, targetId: 'quiet-hours', label: '18:24 - Chapter 7 The Long Field', createdAt: now.subtract(const Duration(days: 1))),
      Bookmark(id: 'b3', kind: BookmarkKind.reference, targetId: 'tide', label: 'Reference - Nature', snippet: "The regular rise and fall of the sea's surface.", createdAt: now.subtract(const Duration(days: 3))),
      Bookmark(id: 'b4', kind: BookmarkKind.article, targetId: 'read-by-the-sea', label: 'Daily read - 9 Nov', createdAt: now.subtract(const Duration(minutes: 40))),
    ];
  }

  bool has(BookmarkKind kind, String targetId, [String? label]) => state.any((b) => b.kind == kind && b.targetId == targetId && (label == null || b.label == label));

  void toggle(BookmarkKind kind, String targetId, String label, {String? snippet}) {
    if (has(kind, targetId, label)) {
      state = state.where((b) => !(b.kind == kind && b.targetId == targetId && b.label == label)).toList();
    } else {
      state = [Bookmark(id: 'b${DateTime.now().microsecondsSinceEpoch}', kind: kind, targetId: targetId, label: label, snippet: snippet, createdAt: ref.read(clockProvider)), ...state];
    }
  }
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, List<Bookmark>>(BookmarksNotifier.new);

class FavouritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'salt-road', 'tide-keeper'};
  void toggle(String id) => state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

final favouritesProvider = NotifierProvider<FavouritesNotifier, Set<String>>(FavouritesNotifier.new);

// ---------------------------------------------------------------- audio
class PlayerNotifier extends Notifier<StreamState?> {
  Timer? _timer;
  static const _tick = Duration(milliseconds: 250);

  @override
  StreamState? build() {
    ref.onDispose(() => _timer?.cancel());
    final b = bookById('quiet-hours');
    // Resume point synced from the account: Chapter 7, 18:24 of 42:10.
    return StreamState(bookId: b.id, chapterIndex: 2, position: const Duration(minutes: 18, seconds: 24), duration: const Duration(minutes: 42, seconds: 10), buffered: const Duration(minutes: 21));
  }

  void open(String bookId, {int chapterIndex = 0}) {
    if (state?.bookId == bookId) return;
    final b = bookById(bookId);
    final ch = b.chapters[chapterIndex];
    _setPlaying(false);
    state = StreamState(bookId: bookId, chapterIndex: chapterIndex, position: Duration.zero, duration: Duration(minutes: ch.minutes), buffered: Duration.zero);
  }

  void toggle() => _setPlaying(!(state?.playing ?? false));

  void _setPlaying(bool on) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(playing: on);
    _timer?.cancel();
    if (on) {
      _timer = Timer.periodic(_tick, (_) {
        final next = state?.tick(_tick);
        state = next;
        if (next != null && !next.playing) _timer?.cancel();
      });
    }
  }

  void seekBy(int seconds) => state = state?.seekBy(Duration(seconds: seconds));
  void cycleSpeed() => state = state?.copyWith(speed: state!.nextSpeed);
  void cycleSleep() {
    final s = state;
    if (s == null) return;
    const opts = [Duration(minutes: 15), Duration(minutes: 30), null];
    final i = s.sleepLeft == null ? 0 : (s.sleepLeft! > const Duration(minutes: 15) ? 2 : 1);
    state = opts[i] == null ? s.copyWith(clearSleep: true) : s.copyWith(sleepLeft: opts[i]);
  }

  void pause() => _setPlaying(false);
}

final playerProvider = NotifierProvider<PlayerNotifier, StreamState?>(PlayerNotifier.new);

// ---------------------------------------------------------------- CMS
class CmsNotifier extends AsyncNotifier<CmsFeed> {
  @override
  Future<CmsFeed> build() async => CmsFeed.fromJson(await rootBundle.loadString('assets/cms/feed.json'));

  void publish(String id) {
    final feed = state.value;
    if (feed == null) return;
    state = AsyncData(feed.publish(id, ref.read(clockProvider)));
  }
}

final cmsProvider = AsyncNotifierProvider<CmsNotifier, CmsFeed>(CmsNotifier.new);

/// Today's daily read: the newest published daily-read entry from the CMS.
final todayArticleProvider = Provider<Article>((ref) {
  final feed = ref.watch(cmsProvider).value;
  if (feed == null) return articleById('read-by-the-sea');
  final live = feed.entries.where((e) => e.type == CmsType.dailyRead && e.status == CmsStatus.published).toList()..sort((a, b) => b.date.compareTo(a.date));
  return live.isEmpty ? articleById('read-by-the-sea') : articleById(live.first.id);
});

// ---------------------------------------------------------------- search
class SearchQuery {
  const SearchQuery(this.text, this.scope);
  final String text;
  final SearchScope scope;
}

class SearchQueryNotifier extends Notifier<SearchQuery> {
  @override
  SearchQuery build() => const SearchQuery('', SearchScope.all);
  void setText(String t) => state = SearchQuery(t, state.scope);
  void setScope(SearchScope s) => state = SearchQuery(state.text, s);
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, SearchQuery>(SearchQueryNotifier.new);

final searchIndexProvider = Provider<SearchIndex>((ref) {
  final salt = ref.watch(epubProvider('assets/books/the-salt-road.epub')).value;
  return SearchIndex(
    books: books,
    articles: articles,
    reference: refEntries,
    bookText: {if (salt != null) 'salt-road': salt.chapters.expand((c) => c.paragraphs).join(' ')},
  );
});

final searchResultsProvider = Provider<SearchResults>((ref) {
  final q = ref.watch(searchQueryProvider);
  return ref.watch(searchIndexProvider).query(q.text, q.scope);
});

// ---------------------------------------------------------------- navigation
class TabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void go(int i) => state = i;
}

final tabProvider = NotifierProvider<TabNotifier, int>(TabNotifier.new);
