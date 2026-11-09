import 'package:flutter/material.dart';

import 'theme.dart';

String mmss(Duration d) {
  final m = d.inMinutes, s = d.inSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String hm(int minutes) => minutes >= 60 ? '${minutes ~/ 60}h ${minutes % 60}m' : '${minutes}m';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';
String dayDate(DateTime d) => '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

String ago(DateTime then, DateTime now) {
  final d = now.difference(then);
  if (d.inMinutes < 60) return 'Today';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays == 1) return 'Yesterday';
  return '${d.inDays} days ago';
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onTap, this.icon, this.height = 56, this.compact = false});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: compact ? 44 : height,
        width: compact ? null : double.infinity,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: C.accentFill,
            foregroundColor: Colors.white,
            disabledBackgroundColor: C.accentFill.withValues(alpha: .4),
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 24),
            textStyle: T.label.copyWith(fontWeight: FontWeight.w600),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(label, style: T.label.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, this.onTap, this.icon, this.compact = false});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: compact ? 44 : 56,
        width: compact ? null : double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: C.ink,
            backgroundColor: C.surface,
            side: const BorderSide(color: C.borderStrong, width: 1.5),
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 20, color: C.ink), const SizedBox(width: 8)],
            Text(label, style: T.label.copyWith(fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.fg = C.accentFill, this.bg = C.accentTint, this.icon});
  final String label;
  final Color fg, bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(label, style: T.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
        ]),
      );
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.workspace_premium_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 3),
          Text('Premium', style: T.caption.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );
}

class Bar extends StatelessWidget {
  const Bar(this.value, {super.key, this.height = 6, this.buffered});
  final double value;
  final double? buffered;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: height,
          child: LayoutBuilder(builder: (_, c) {
            return Stack(children: [
              Container(color: C.surfaceAlt),
              if (buffered != null) Container(width: c.maxWidth * buffered!.clamp(0, 1), color: C.accentTint),
              Container(width: c.maxWidth * value.clamp(0, 1), color: C.accent),
            ]);
          }),
        ),
      );
}

class CoverImage extends StatelessWidget {
  const CoverImage(this.asset, {super.key, this.width = 120, this.radius = 12, this.premium = false});
  final String asset;
  final double width;
  final double radius;
  final bool premium;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: width * 1.5,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: shadowCard),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(asset, fit: BoxFit.cover),
            if (premium) const Positioned(left: 8, top: 8, child: PremiumBadge()),
          ]),
        ),
      );
}

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.radius = 20});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(radius), boxShadow: shadowCard),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

/// Pill segmented control (#F3E8F6 track, white selected segment).
class Segmented extends StatelessWidget {
  const Segmented({super.key, required this.items, required this.index, required this.onChanged, this.keyPrefix = 'seg'});
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: C.surfaceAlt, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                key: Key('$keyPrefix-${items[i].toLowerCase()}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: i == index ? C.surface : Colors.transparent, borderRadius: BorderRadius.circular(999), boxShadow: i == index ? shadowCard : null),
                  child: Text(items[i], style: T.label.copyWith(color: i == index ? C.ink : C.text2, fontWeight: i == index ? FontWeight.w600 : FontWeight.w500)),
                ),
              ),
            ),
        ]),
      );
}

/// Filter chip: selected = accent tint + accent text; unselected = white with hairline.
class FilterChipPill extends StatelessWidget {
  const FilterChipPill(this.label, {super.key, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? C.accentTint : C.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? C.accentTint : C.border),
          ),
          child: Text(label, style: T.caption.copyWith(color: selected ? C.accentFill : C.text2, fontWeight: FontWeight.w600)),
        ),
      );
}

class Avatar extends StatelessWidget {
  const Avatar(this.asset, {super.key, this.size = 40});
  final String asset;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.surface, width: 2), boxShadow: shadowCard, image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover)),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Row(children: [
          Expanded(child: Text(text, style: T.title)),
          if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: T.label.copyWith(color: C.accentFill, fontWeight: FontWeight.w600))),
        ]),
      );
}

/// Round icon button with a 44pt hit area.
class RoundIcon extends StatelessWidget {
  const RoundIcon(this.icon, {super.key, this.onTap, this.color = C.ink, this.filled = false, this.semantic});
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool filled;
  final String? semantic;
  @override
  Widget build(BuildContext context) => Semantics(
        label: semantic,
        button: true,
        child: Material(
          color: filled ? C.surface : Colors.transparent,
          shape: const CircleBorder(),
          elevation: filled ? 2 : 0,
          shadowColor: const Color(0x331C0C1F),
          child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: SizedBox(width: 44, height: 44, child: Icon(icon, color: color, size: 24))),
        ),
      );
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.leading, this.title, this.actions = const []});
  final Widget? leading;
  final String? title;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: Row(children: [
          leading ?? const SizedBox(width: 44),
          Expanded(child: title == null ? const SizedBox() : Text(title!, textAlign: TextAlign.center, style: T.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: .6))),
          ...actions,
          if (actions.isEmpty) const SizedBox(width: 44),
        ]),
      );
}
