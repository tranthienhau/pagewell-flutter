import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../state/providers.dart';

class BookScreen extends ConsumerWidget {
  const BookScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = bookById(id);
    final fav = ref.watch(favouritesProvider).contains(b.id);
    final locked = !ref.watch(canOpenProvider(b.premium));
    final player = ref.watch(playerProvider);
    final chips = [b.hasEbook && b.hasAudio ? 'Ebook + Audio' : (b.hasAudio ? 'Audiobook' : 'Ebook'), if (b.pages > 0) '${b.pages} pages', if (b.audioMinutes > 0) hm(b.audioMinutes)];
    return Scaffold(
      key: Key('book-${b.id}'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            TopBar(
              leading: RoundIcon(Icons.arrow_back_rounded, key: const Key('book-back'), onTap: () => Navigator.pop(context), semantic: 'Back'),
              actions: [
                RoundIcon(
                  fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  key: const Key('favourite'),
                  color: fav ? C.accent : C.ink,
                  semantic: 'Favourite',
                  onTap: () => ref.read(favouritesProvider.notifier).toggle(b.id),
                ),
                RoundIcon(Icons.ios_share_rounded, onTap: () {}, semantic: 'Share'),
              ],
            ),
            const SizedBox(height: 8),
            Center(child: CoverImage(b.cover, width: 180, premium: b.premium)),
            const SizedBox(height: 20),
            Text(b.title, textAlign: TextAlign.center, style: T.display),
            const SizedBox(height: 4),
            Text(
              b.author,
              textAlign: TextAlign.center,
              style: T.body.copyWith(color: C.accentFill, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 18, color: C.warningFg),
                const SizedBox(width: 4),
                Text('${b.rating} (${b.ratings.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')})', style: T.caption),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [for (final c in chips) Pill(c)]),
            const SizedBox(height: 20),
            Row(
              children: [
                if (b.hasEbook)
                  Expanded(
                    child: PrimaryButton(
                      locked ? 'Unlock' : 'Read',
                      key: const Key('read'),
                      icon: locked ? Icons.lock_outline_rounded : Icons.menu_book_rounded,
                      onTap: () => Nav.read(context, ref, b.id),
                    ),
                  ),
                if (b.hasEbook && b.hasAudio) const SizedBox(width: 12),
                if (b.hasAudio)
                  Expanded(
                    child: b.hasEbook
                        ? SecondaryButton('Listen', key: const Key('listen'), icon: Icons.headphones_rounded, onTap: () => Nav.listen(context, ref, b.id))
                        : PrimaryButton(
                            player?.bookId == b.id ? 'Resume' : (locked ? 'Unlock' : 'Listen'),
                            key: const Key('listen'),
                            icon: Icons.headphones_rounded,
                            onTap: () => player?.bookId == b.id ? Nav.player(context) : Nav.listen(context, ref, b.id),
                          ),
                  ),
              ],
            ),
            if (locked) ...[const SizedBox(height: 10), Text('Included with Premium', textAlign: TextAlign.center, style: T.caption)],
            const Divider(height: 40, color: C.border),
            Text('About this book', style: T.title),
            const SizedBox(height: 8),
            Text(b.synopsis, style: T.body.copyWith(color: C.text2, height: 1.6)),
            const SectionTitle('Chapters'),
            for (var i = 0; i < b.chapters.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CardBox(
                  key: Key('chapter-$i'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onTap: () => b.hasAudio ? Nav.listen(context, ref, b.id, chapter: i) : Nav.read(context, ref, b.id),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${b.chapters[i].number}',
                          style: T.title.copyWith(color: C.accentFill, fontFamily: 'Fraunces'),
                        ),
                      ),
                      Expanded(
                        child: Text(b.chapters[i].title, style: T.body.copyWith(fontWeight: FontWeight.w500)),
                      ),
                      if (b.chapters[i].minutes > 0) Text('${b.chapters[i].minutes} min', style: T.caption),
                      const SizedBox(width: 8),
                      Icon(b.hasAudio ? Icons.play_circle_outline_rounded : Icons.chevron_right_rounded, color: C.accentFill),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
