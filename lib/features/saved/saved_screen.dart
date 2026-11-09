import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import '../shell/tab_header.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});
  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  int _tab = 0;

  void _open(Bookmark b) {
    switch (b.kind) {
      case BookmarkKind.page:
        Nav.read(context, ref, b.targetId);
      case BookmarkKind.audio:
        Nav.listen(context, ref, b.targetId, chapter: ref.read(playerProvider)?.bookId == b.targetId ? ref.read(playerProvider)!.chapterIndex : 0);
      case BookmarkKind.reference:
        Nav.reference(context, ref, b.targetId);
      case BookmarkKind.article:
        Nav.article(context, b.targetId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marks = ref.watch(bookmarksProvider);
    final favs = ref.watch(favouritesProvider);
    final now = ref.watch(clockProvider);

    Widget thumb(Bookmark b) => switch (b.kind) {
      BookmarkKind.page => CoverImage(bookById(b.targetId).cover, width: 48, radius: 8),
      BookmarkKind.audio => Stack(
        clipBehavior: Clip.none,
        children: [
          CoverImage(bookById(b.targetId).cover, width: 48, radius: 8),
          Positioned(
            right: -6,
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: C.accentFill, shape: BoxShape.circle),
              child: const Icon(Icons.headphones_rounded, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      BookmarkKind.reference => Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(12)),
        child: Text('Aa', style: T.title.copyWith(color: C.accentFill)),
      ),
      BookmarkKind.article => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(articleById(b.targetId).image, width: 48, height: 48, fit: BoxFit.cover),
      ),
    };

    String title(Bookmark b) => switch (b.kind) {
      BookmarkKind.page || BookmarkKind.audio => bookById(b.targetId).title,
      BookmarkKind.reference => refById(b.targetId).term,
      BookmarkKind.article => articleById(b.targetId).title,
    };

    return Column(
      key: const Key('saved'),
      children: [
        const TabHeader('Saved'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Segmented(items: const ['Bookmarks', 'Favourites'], index: _tab, keyPrefix: 'saved', onChanged: (i) => setState(() => _tab = i)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(_tab == 0 ? '${marks.length} bookmarks' : '${favs.length} favourites', style: T.caption),
              const SizedBox(height: 12),
              if (_tab == 0)
                for (final b in marks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CardBox(
                      key: Key('mark-${b.id}'),
                      onTap: () => _open(b),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              thumb(b),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title(b),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: T.body.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(b.label, style: T.caption),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(Icons.bookmark_rounded, color: C.accent, size: 22),
                                  Text(ago(b.createdAt, now), style: T.caption.copyWith(color: C.text3)),
                                ],
                              ),
                            ],
                          ),
                          if (b.snippet != null && b.kind == BookmarkKind.page) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                              decoration: const BoxDecoration(
                                color: Color(0x66F6E4FA),
                                border: Border(left: BorderSide(color: C.accent, width: 2)),
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                              ),
                              child: Text(
                                '"${b.snippet}"',
                                style: T.label.copyWith(fontFamily: 'Fraunces', fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
              else
                for (final id in favs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CardBox(
                      key: Key('fav-$id'),
                      padding: const EdgeInsets.all(12),
                      onTap: () => Nav.book(context, id),
                      child: Row(
                        children: [
                          CoverImage(bookById(id).cover, width: 56, radius: 8),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bookById(id).title, style: T.body.copyWith(fontWeight: FontWeight.w600)),
                                Text(bookById(id).author, style: T.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.favorite_rounded, color: C.accent),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
