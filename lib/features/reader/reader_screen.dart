import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

/// EPUB reader: chapters come from the parsed .epub (container -> OPF -> spine -> XHTML).
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.bookId, this.showSettings = false});
  final String bookId;
  final bool showSettings;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _scroll = ScrollController();
  double _frac = 0;
  late bool _settings = widget.showSettings;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final max = _scroll.position.maxScrollExtent;
      final f = max <= 0 ? 0.0 : (_scroll.offset / max).clamp(0.0, 1.0);
      if ((f - _frac).abs() > .01) setState(() => _frac = f);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goChapter(int i, int total) {
    ref.read(readingPosProvider.notifier).set(widget.bookId, i);
    ref.read(libraryProvider.notifier).setProgress(widget.bookId, (i + .05) / total);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    setState(() => _frac = 0);
  }

  @override
  Widget build(BuildContext context) {
    final book = bookById(widget.bookId);
    final prefs = ref.watch(readerPrefsProvider);
    final (bg, fg) = switch (prefs.theme) {
      ReaderTheme.light => (C.paper, C.ink),
      ReaderTheme.sepia => (C.sepia, const Color(0xFF3B2A1A)),
      ReaderTheme.dark => (const Color(0xFF1C0C1F), const Color(0xFFEDE3EF)),
    };
    final epub = ref.watch(epubProvider(book.epubAsset!));
    return Scaffold(
      key: const Key('reader'),
      backgroundColor: bg,
      body: SafeArea(
        child: epub.when(
          loading: () => const Center(child: CircularProgressIndicator(color: C.accent)),
          error: (e, _) => Center(child: Text('Could not open this EPUB\n$e', textAlign: TextAlign.center, style: T.body)),
          data: (doc) {
            final idx = (ref.watch(readingPosProvider)[book.id] ?? 0).clamp(0, doc.chapters.length - 1);
            final ch = doc.chapters[idx];
            final overall = (idx + _frac) / doc.chapters.length;
            final page = (overall * (book.pages - 1)).round() + 1;
            final minsLeft = ((1 - _frac) * book.chapters[idx].minutes / 3.5).ceil();
            final label = 'Page $page - Chapter ${idx + 1}';
            final marked = ref.watch(bookmarksProvider).any((b) => b.kind == BookmarkKind.page && b.targetId == book.id && b.label.endsWith('Chapter ${idx + 1}'));
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TopBar(
                  leading: RoundIcon(Icons.arrow_back_rounded, color: fg, onTap: () => Navigator.pop(context), semantic: 'Back'),
                  title: ch.title,
                  actions: [
                    RoundIcon(marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, key: const Key('reader-bookmark'), color: marked ? C.accent : fg, semantic: 'Bookmark page', onTap: () {
                      final existing = ref.read(bookmarksProvider).where((b) => b.kind == BookmarkKind.page && b.targetId == book.id && b.label.endsWith('Chapter ${idx + 1}'));
                      ref.read(bookmarksProvider.notifier).toggle(BookmarkKind.page, book.id, existing.isNotEmpty ? existing.first.label : label, snippet: ch.paragraphs.first);
                    }),
                    GestureDetector(
                      key: const Key('reader-aa'),
                      onTap: () => setState(() => _settings = !_settings),
                      child: SizedBox(width: 44, height: 44, child: Center(child: Text('Aa', style: T.title.copyWith(color: _settings ? C.accentFill : fg, fontFamily: 'Fraunces')))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  key: const Key('reader-scroll'),
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    Text(ch.title, style: T.headline.copyWith(color: fg)),
                    const SizedBox(height: 16),
                    for (final p in ch.paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(p, style: TextStyle(fontFamily: 'Fraunces', fontSize: prefs.fontSize, height: 1.6, color: fg)),
                      ),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (idx > 0) Expanded(child: SecondaryButton('Previous', compact: true, icon: Icons.chevron_left_rounded, onTap: () => _goChapter(idx - 1, doc.chapters.length))),
                      if (idx > 0 && idx < doc.chapters.length - 1) const SizedBox(width: 12),
                      if (idx < doc.chapters.length - 1) Expanded(child: PrimaryButton('Next chapter', key: const Key('reader-next'), compact: true, onTap: () => _goChapter(idx + 1, doc.chapters.length))),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(children: [
                  Bar(overall),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('Page $page of ${book.pages}', style: T.caption.copyWith(color: prefs.theme == ReaderTheme.dark ? const Color(0xFFCBBECF) : C.text2)),
                    const Spacer(),
                    Text('$minsLeft min left in chapter', style: T.caption.copyWith(color: prefs.theme == ReaderTheme.dark ? const Color(0xFFCBBECF) : C.text2)),
                  ]),
                ]),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _settings ? const _SettingsSheet() : const SizedBox(width: double.infinity),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readerPrefsProvider);
    Widget swatch(ReaderTheme t, Color c, String name) {
      final sel = prefs.theme == t;
      return GestureDetector(
        key: Key('theme-${t.name}'),
        onTap: () => ref.read(readerPrefsProvider.notifier).setTheme(t),
        child: Column(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: sel ? C.accentFill : C.border, width: sel ? 3 : 1)),
            child: sel ? Icon(Icons.check_rounded, size: 20, color: t == ReaderTheme.dark ? Colors.white : C.accentFill) : null,
          ),
          const SizedBox(height: 6),
          Text(name, style: T.caption.copyWith(color: sel ? C.ink : C.text2)),
        ]),
      );
    }

    return Container(
      key: const Key('reader-settings'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Color(0x141C0C1F), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        Row(children: [
          Text('A', style: T.caption.copyWith(color: C.ink)),
          Expanded(child: Slider(key: const Key('font-slider'), min: 14, max: 26, divisions: 6, value: prefs.fontSize, onChanged: (v) => ref.read(readerPrefsProvider.notifier).setSize(v))),
          Text('A', style: T.title.copyWith(fontSize: 20)),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          swatch(ReaderTheme.light, C.paper, 'Light'),
          swatch(ReaderTheme.sepia, C.sepia, 'Sepia'),
          swatch(ReaderTheme.dark, const Color(0xFF1C0C1F), 'Dark'),
        ]),
      ]),
    );
  }
}
