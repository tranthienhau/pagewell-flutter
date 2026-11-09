import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    if (s == null) return const Scaffold(body: Center(child: Text('Nothing playing')));
    final p = ref.read(playerProvider.notifier);
    final book = bookById(s.bookId);
    final ch = book.chapters[s.chapterIndex];
    final label = '${mmss(s.position)} - Chapter ${ch.number} ${ch.title}';
    final marked = ref.watch(bookmarksProvider).any((b) => b.kind == BookmarkKind.audio && b.targetId == book.id && b.label.contains('Chapter ${ch.number}'));
    final total = s.duration.inMilliseconds == 0 ? 1 : s.duration.inMilliseconds;

    Widget action(String key, IconData icon, String text, VoidCallback onTap, {bool on = false}) => Expanded(
          child: GestureDetector(
            key: Key(key),
            onTap: onTap,
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: on ? C.accentTint : C.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? C.accentTint : C.border)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 18, color: on ? C.accentFill : C.ink),
                const SizedBox(width: 4),
                Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: T.caption.copyWith(color: on ? C.accentFill : C.ink, fontWeight: FontWeight.w600))),
              ]),
            ),
          ),
        );

    return Scaffold(
      key: const Key('player'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            TopBar(
              leading: RoundIcon(Icons.keyboard_arrow_down_rounded, key: const Key('player-close'), onTap: () => Navigator.pop(context), semantic: 'Close player'),
              title: 'NOW PLAYING',
              actions: [RoundIcon(Icons.more_horiz_rounded, onTap: () {}, semantic: 'More')],
            ),
            const Spacer(),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: shadowCard),
              child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(book.cover, fit: BoxFit.cover, alignment: const Alignment(0, .2))),
            ),
            const SizedBox(height: 24),
            Text(book.title, style: T.display, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(book.author, style: T.body.copyWith(color: C.text2)),
            const SizedBox(height: 8),
            Pill('Chapter ${ch.number} - ${ch.title}'),
            const SizedBox(height: 24),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                secondaryActiveTrackColor: C.accentTint,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                key: const Key('scrubber'),
                value: s.position.inMilliseconds / total,
                secondaryTrackValue: s.buffered.inMilliseconds / total,
                onChanged: (v) => p.seekBy(((v * total - s.position.inMilliseconds) / 1000).round()),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Text(mmss(s.position), style: T.caption),
              const Spacer(),
              Text('-${mmss(s.duration - s.position)}', style: T.caption),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              RoundIcon(Icons.replay_10_rounded, key: const Key('rewind'), onTap: () => p.seekBy(-15), semantic: 'Back 15 seconds'),
              const SizedBox(width: 28),
              Semantics(
                button: true,
                label: s.playing ? 'Pause' : 'Play',
                child: GestureDetector(
                  key: const Key('play-pause'),
                  onTap: p.toggle,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: C.accentFill, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x40A337BA), blurRadius: 20, offset: Offset(0, 8))]),
                    child: Icon(s.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 28),
              RoundIcon(Icons.forward_10_rounded, key: const Key('forward'), onTap: () => p.seekBy(15), semantic: 'Forward 15 seconds'),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              action('speed', Icons.speed_rounded, '${s.speed}x', p.cycleSpeed, on: s.speed != 1.0),
              action('sleep', Icons.bedtime_outlined, s.sleepLeft == null ? 'Sleep' : '${(s.sleepLeft!.inSeconds / 60).ceil()} min', p.cycleSleep, on: s.sleepLeft != null),
              action('audio-bookmark', marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 'Mark', () => ref.read(bookmarksProvider.notifier).toggle(BookmarkKind.audio, book.id, label), on: marked),
              action('chapters', Icons.format_list_bulleted_rounded, 'List', () => _chapters(context, ref, book.chapters, s.chapterIndex)),
            ]),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(s.buffering ? Icons.downloading_rounded : Icons.wifi_rounded, size: 16, color: C.text3),
              const SizedBox(width: 6),
              Text(s.buffering ? 'Buffering...' : 'Streaming - ${s.bitrateKbps} kbps', key: const Key('stream-status'), style: T.caption.copyWith(color: C.text3)),
            ]),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  void _chapters(BuildContext context, WidgetRef ref, List<Chapter> chapters, int current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Text('Chapters', style: T.title),
          for (var i = 0; i < chapters.length; i++)
            ListTile(
              leading: Text('${chapters[i].number}', style: T.title.copyWith(color: i == current ? C.accentFill : C.text3)),
              title: Text(chapters[i].title, style: T.body.copyWith(fontWeight: i == current ? FontWeight.w600 : FontWeight.w400)),
              trailing: Text('${chapters[i].minutes} min', style: T.caption),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

/// Mini player pinned above the tab bar.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playerProvider);
    if (s == null) return const SizedBox.shrink();
    final book = bookById(s.bookId);
    final ch = book.chapters[s.chapterIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: CardBox(
        key: const Key('mini-player'),
        radius: 18,
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PlayerScreen())),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(book.cover, width: 40, height: 40, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${book.title} - Chapter ${ch.number}', maxLines: 1, overflow: TextOverflow.ellipsis, style: T.label.copyWith(fontWeight: FontWeight.w600)),
                Text(book.author, style: T.caption),
              ]),
            ),
            GestureDetector(
              key: const Key('mini-play'),
              onTap: ref.read(playerProvider.notifier).toggle,
              child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: C.accentFill, shape: BoxShape.circle), child: Icon(s.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 6),
          Bar(s.position.inMilliseconds / (s.duration.inMilliseconds == 0 ? 1 : s.duration.inMilliseconds), height: 3),
        ]),
      ),
    );
  }
}
