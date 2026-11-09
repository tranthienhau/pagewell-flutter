import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/search_index.dart';
import '../../state/providers.dart';
import '../shell/tab_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _ctl = TextEditingController(text: ref.read(searchQueryProvider).text);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  /// Highlights every occurrence of [q] in [text].
  Widget _hl(String text, String q, TextStyle base, {int? maxLines}) {
    final spans = <TextSpan>[];
    final lower = text.toLowerCase(), ql = q.trim().toLowerCase();
    var i = 0;
    while (ql.length >= 2) {
      final j = lower.indexOf(ql, i);
      if (j < 0) break;
      spans.add(TextSpan(text: text.substring(i, j)));
      spans.add(TextSpan(text: text.substring(j, j + ql.length), style: const TextStyle(color: C.accentFill, fontWeight: FontWeight.w700)));
      i = j + ql.length;
    }
    spans.add(TextSpan(text: text.substring(i)));
    return Text.rich(TextSpan(style: base, children: spans), maxLines: maxLines, overflow: maxLines == null ? null : TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
    final q = ref.watch(searchQueryProvider);
    final r = ref.watch(searchResultsProvider);
    const scopes = {SearchScope.all: 'All', SearchScope.books: 'Books', SearchScope.articles: 'Articles', SearchScope.reference: 'Reference'};
    return ListView(key: const Key('search'), padding: const EdgeInsets.only(bottom: 24), children: [
      const TabHeader('Search'),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: TextField(
          key: const Key('search-field'),
          controller: _ctl,
          onChanged: ref.read(searchQueryProvider.notifier).setText,
          style: T.body,
          cursorColor: C.accentFill,
          decoration: InputDecoration(
            hintText: 'Books, articles, reference',
            hintStyle: T.body.copyWith(color: C.text3),
            filled: true,
            fillColor: C.surface,
            prefixIcon: const Icon(Icons.search_rounded, color: C.accentFill),
            suffixIcon: q.text.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.close_rounded, color: C.text3), onPressed: () {
                    _ctl.clear();
                    ref.read(searchQueryProvider.notifier).setText('');
                  }),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.borderStrong)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.accentFill, width: 2)),
          ),
        ),
      ),
      SizedBox(
        height: 36,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
          for (final e in scopes.entries) ...[
            FilterChipPill(e.value, key: Key('scope-${e.key.name}'), selected: q.scope == e.key, onTap: () => ref.read(searchQueryProvider.notifier).setScope(e.key)),
            const SizedBox(width: 8),
          ],
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          if (q.text.trim().length < 2)
            Text('Try "tide", "salt" or "narration". Search covers book text inside EPUBs too.', style: T.caption)
          else
            Text('${r.total} result${r.total == 1 ? '' : 's'}', key: const Key('result-count'), style: T.caption),
          if (r.reference.isNotEmpty) ...[
            const SectionTitle('Reference'),
            for (final e in r.reference)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CardBox(
                  key: Key('res-ref-${e.id}'),
                  onTap: () => Nav.reference(context, ref, e.id),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(10)), child: Text('Aa', style: T.label.copyWith(color: C.accentFill, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: _hl(e.term, q.text, T.body.copyWith(fontWeight: FontWeight.w600))),
                          if (e.premium) const PremiumBadge(),
                        ]),
                        const SizedBox(height: 2),
                        _hl(e.definition, q.text, T.label.copyWith(color: C.text2, fontWeight: FontWeight.w400), maxLines: 2),
                      ]),
                    ),
                  ]),
                ),
              ),
          ],
          if (r.books.isNotEmpty) ...[
            const SectionTitle('Books'),
            for (final b in r.books)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CardBox(
                  key: Key('res-book-${b.id}'),
                  padding: const EdgeInsets.all(12),
                  onTap: () => Nav.book(context, b.id),
                  child: Row(children: [
                    CoverImage(b.cover, width: 48, radius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _hl(b.title, q.text, T.body.copyWith(fontWeight: FontWeight.w600)),
                        Text(b.author, style: T.caption),
                      ]),
                    ),
                    if (b.premium) const PremiumBadge(),
                  ]),
                ),
              ),
          ],
          if (r.articles.isNotEmpty) ...[
            const SectionTitle('Articles'),
            for (final a in r.articles)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CardBox(
                  key: Key('res-article-${a.id}'),
                  padding: const EdgeInsets.all(12),
                  onTap: () => Nav.article(context, a.id),
                  child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(a.image, width: 56, height: 56, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _hl(a.title, q.text, T.body.copyWith(fontWeight: FontWeight.w600)),
                        Text('Daily read - ${a.minutes} min', style: T.caption),
                      ]),
                    ),
                  ]),
                ),
              ),
          ],
        ]),
      ),
    ]);
  }
}
