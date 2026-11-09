import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import '../shell/tab_header.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _format = 0; // all, ebooks, audiobooks
  String? _filter; // in-progress, finished

  @override
  Widget build(BuildContext context) {
    final lib = ref.watch(libraryProvider);
    var items = lib.owned.map(bookById).where((b) => _format == 0 || (_format == 1 ? b.hasEbook : b.hasAudio)).toList();
    if (_filter == 'progress') items = items.where((b) => (lib.progress[b.id] ?? 0) > 0 && (lib.progress[b.id] ?? 0) < 1).toList();
    if (_filter == 'finished') items = items.where((b) => (lib.progress[b.id] ?? 0) >= 1).toList();

    return Column(
      key: const Key('library'),
      children: [
        const TabHeader('Library'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Segmented(items: const ['All', 'Ebooks', 'Audiobooks'], index: _format, keyPrefix: 'fmt', onChanged: (i) => setState(() => _format = i)),
        ),
        if (lib.isEmpty)
          Expanded(child: _Empty(onBrowse: () => ref.read(libraryProvider.notifier).addFreeTitles()))
        else ...[
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                FilterChipPill('Downloaded', selected: _filter == 'downloaded', onTap: () => setState(() => _filter = _filter == 'downloaded' ? null : 'downloaded')),
                const SizedBox(width: 8),
                FilterChipPill('In progress', key: const Key('filter-progress'), selected: _filter == 'progress', onTap: () => setState(() => _filter = _filter == 'progress' ? null : 'progress')),
                const SizedBox(width: 8),
                FilterChipPill('Finished', selected: _filter == 'finished', onTap: () => setState(() => _filter = _filter == 'finished' ? null : 'finished')),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 16, childAspectRatio: .5),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final b = items[i];
                final p = lib.progress[b.id] ?? 0;
                return GestureDetector(
                  key: Key('lib-${b.id}'),
                  onTap: () => Nav.book(context, b.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (_, c) => CoverImage(b.cover, width: c.maxWidth, premium: b.premium),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: T.label.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(b.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.caption),
                          ),
                          Icon(b.format == BookFormat.audiobook ? Icons.headphones_rounded : Icons.menu_book_rounded, size: 16, color: C.text2),
                        ],
                      ),
                      if (p > 0) ...[const SizedBox(height: 6), Bar(p, height: 4)],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onBrowse});
  final VoidCallback onBrowse;
  @override
  Widget build(BuildContext context) => ListView(
    key: const Key('library-empty'),
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset('assets/images/empty-shelf.jpg', height: 260, fit: BoxFit.cover),
      ),
      const SizedBox(height: 24),
      Text('Your shelf is empty', textAlign: TextAlign.center, style: T.headline),
      const SizedBox(height: 8),
      Text(
        'Add a free ebook or audiobook to start reading and listening.',
        textAlign: TextAlign.center,
        style: T.body.copyWith(color: C.text2),
      ),
      const SizedBox(height: 24),
      PrimaryButton('Browse free titles', key: const Key('browse-free'), onTap: onBrowse),
      const SizedBox(height: 8),
      Center(
        child: TextButton(
          onPressed: () {},
          child: Text(
            'Restore purchases',
            style: T.label.copyWith(color: C.accentFill, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  );
}
