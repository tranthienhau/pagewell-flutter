import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import '../membership/membership_screen.dart';

class ReferenceScreen extends ConsumerWidget {
  const ReferenceScreen({super.key, required this.id, required this.openBook});
  final String id;
  final void Function(BuildContext, String bookId) openBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = refById(id);
    final marked = ref.watch(bookmarksProvider).any((b) => b.kind == BookmarkKind.reference && b.targetId == r.id);
    return Scaffold(
      key: Key('reference-${r.id}'),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
          TopBar(
            leading: RoundIcon(Icons.arrow_back_rounded, onTap: () => Navigator.pop(context), semantic: 'Back'),
            actions: [
              RoundIcon(marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, key: const Key('ref-bookmark'), color: marked ? C.accent : C.ink, semantic: 'Bookmark entry', onTap: () => ref.read(bookmarksProvider.notifier).toggle(BookmarkKind.reference, r.id, 'Reference - ${r.topic}', snippet: r.definition)),
            ],
          ),
          Align(alignment: Alignment.centerLeft, child: Pill('Reference - ${r.topic}', icon: Icons.menu_book_rounded)),
          const SizedBox(height: 12),
          Text(r.term, style: T.display.copyWith(fontSize: 40)),
          Text('${r.pronunciation} - ${r.partOfSpeech}', style: T.caption),
          if (r.image != null) ...[
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(r.image!, height: 150, width: double.infinity, fit: BoxFit.cover)),
          ],
          const SizedBox(height: 16),
          Text(r.definition, style: T.body.copyWith(height: 1.6)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(16)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_outline_rounded, color: C.accentFill),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Did you know', style: T.label.copyWith(fontWeight: FontWeight.w700, color: C.accentFill)),
                  const SizedBox(height: 4),
                  Text(r.didYouKnow, style: T.label.copyWith(fontWeight: FontWeight.w400)),
                ]),
              ),
            ]),
          ),
          if (r.related.isNotEmpty) ...[
            const SectionTitle('Related entries'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final rel in r.related)
                GestureDetector(
                  key: Key('related-$rel'),
                  onTap: () => openGated(context, ref, premium: refById(rel).premium, page: (_) => ReferenceScreen(id: rel, openBook: openBook)),
                  child: Pill(refById(rel).term, icon: refById(rel).premium ? Icons.lock_outline_rounded : null),
                ),
            ]),
          ],
          if (r.appearsIn.isNotEmpty) ...[
            const SectionTitle('Appears in'),
            SizedBox(
              height: 190,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final id in r.appearsIn)
                  GestureDetector(
                    onTap: () => openBook(context, id),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 96,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          CoverImage(bookById(id).cover, width: 96),
                          const SizedBox(height: 6),
                          Text(bookById(id).title, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption.copyWith(color: C.ink, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
