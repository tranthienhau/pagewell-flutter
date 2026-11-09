import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key, required this.id, required this.openBook});
  final String id;
  final void Function(BuildContext, String bookId) openBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = articleById(id);
    final marked = ref.watch(bookmarksProvider).any((b) => b.kind == BookmarkKind.article && b.targetId == a.id);
    final mentioned = a.mentionedBookId == null ? null : bookById(a.mentionedBookId!);
    return Scaffold(
      key: Key('article-${a.id}'),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Image.asset(a.image, height: 300, width: double.infinity, fit: BoxFit.cover),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      RoundIcon(Icons.arrow_back_rounded, filled: true, onTap: () => Navigator.pop(context), semantic: 'Back'),
                      const Spacer(),
                      RoundIcon(
                        marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        key: const Key('article-bookmark'),
                        filled: true,
                        color: marked ? C.accentFill : C.ink,
                        semantic: 'Bookmark article',
                        onTap: () => ref.read(bookmarksProvider.notifier).toggle(BookmarkKind.article, a.id, 'Daily read - ${shortDate(a.date)}'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill('Daily read - ${shortDate(a.date)}'),
                const SizedBox(height: 12),
                Text(a.title, style: T.display),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Avatar(a.authorPhoto, size: 40),
                    const SizedBox(width: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: a.author,
                            style: T.label.copyWith(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: '  -  ${a.minutes} min read', style: T.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  'Listen to this article',
                  icon: Icons.headphones_rounded,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Narrated version is queued in the player.'))),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < a.paragraphs.length; i++) ...[
                  Text(a.paragraphs[i], style: T.body.copyWith(height: 1.65)),
                  const SizedBox(height: 16),
                  if (i == 1 && a.pullQuote != null) ...[
                    Container(
                      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: C.accent, width: 3)),
                      ),
                      child: Text(
                        a.pullQuote!,
                        style: T.title.copyWith(fontFamily: 'Fraunces', fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                if (mentioned != null)
                  CardBox(
                    onTap: () => openBook(context, mentioned.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MENTIONED IN THIS PIECE', style: T.caption.copyWith(letterSpacing: .8, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CoverImage(mentioned.cover, width: 48, radius: 8),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mentioned.title, style: T.body.copyWith(fontWeight: FontWeight.w600)),
                                  Text(mentioned.author, style: T.caption),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: C.text3),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
