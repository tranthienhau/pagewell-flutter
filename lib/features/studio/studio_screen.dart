import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

/// Editor studio: the in-app face of the CMS. Editors see the schedule and publish;
/// readers get the change on their next sync (here: instantly, Today updates).
class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  static String typeLabel(CmsType t) => switch (t) {
    CmsType.dailyRead => 'Daily read',
    CmsType.newTitle => 'New title',
    CmsType.reference => 'Reference',
  };

  static Widget status(CmsStatus s) => switch (s) {
    CmsStatus.scheduled => const Pill('Scheduled', fg: C.warningFg, bg: C.warningTint, icon: Icons.schedule_rounded),
    CmsStatus.draft => const Pill('Draft', fg: C.text2, bg: C.surfaceAlt, icon: Icons.edit_outlined),
    CmsStatus.published => const Pill('Published', fg: C.successFg, bg: C.successTint, icon: Icons.check_rounded),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(cmsProvider);
    return Scaffold(
      key: const Key('studio'),
      body: SafeArea(
        child: feed.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (f) {
            final next = f.upNext;
            final list = [...f.entries]..sort((a, b) => a.status == b.status ? a.date.compareTo(b.date) : a.status.index.compareTo(b.status.index));
            Widget stat(String n, String l) => Expanded(
              child: CardBox(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Text(n, style: T.display.copyWith(color: C.accentFill)),
                    Text(l, style: T.caption),
                  ],
                ),
              ),
            );
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Row(
                  children: [
                    RoundIcon(Icons.arrow_back_rounded, key: const Key('studio-back'), onTap: () => Navigator.pop(context), semantic: 'Back'),
                    const SizedBox(width: 4),
                    Expanded(child: Text('Editor studio', style: T.headline)),
                    SecondaryButton('New entry', compact: true, icon: Icons.add_rounded, onTap: () {}),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    stat('${f.publishedTotal}', 'Published'),
                    const SizedBox(width: 12),
                    stat('${f.count(CmsStatus.scheduled)}', 'Scheduled'),
                    const SizedBox(width: 12),
                    stat('${f.count(CmsStatus.draft)}', 'Drafts'),
                  ],
                ),
                const SizedBox(height: 16),
                if (next != null)
                  CardBox(
                    key: const Key('up-next'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Up next - ${dayDate(next.date)}, ${next.date.hour}:00 am', style: T.caption),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (next.image != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(next.image!, width: 72, height: 72, fit: BoxFit.cover),
                              ),
                            if (next.image != null) const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(next.title, style: T.title.copyWith(fontFamily: 'Fraunces')),
                                  const SizedBox(height: 8),
                                  Wrap(spacing: 6, runSpacing: 6, children: [Pill(typeLabel(next.type)), status(next.status)]),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          'Publish now',
                          key: const Key('publish-now'),
                          icon: Icons.send_rounded,
                          onTap: () {
                            ref.read(cmsProvider.notifier).publish(next.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${next.title}" is live on Today.')));
                          },
                        ),
                      ],
                    ),
                  ),
                const SectionTitle('Schedule'),
                CardBox(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0) const Divider(height: 1, color: C.border),
                        Padding(
                          key: Key('cms-${list[i].id}'),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 72,
                                child: Text(dayDate(list[i].date), style: T.caption.copyWith(color: C.ink)),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      list[i].title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: T.label.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(spacing: 6, runSpacing: 6, children: [Pill(typeLabel(list[i].type)), status(list[i].status)]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text('Changes reach readers on their next sync', style: T.caption.copyWith(color: C.text3)),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
