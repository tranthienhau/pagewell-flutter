import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../domain/models.dart';

/// Minimal EPUB 2/3 reader: container.xml -> OPF -> spine -> XHTML paragraphs.
/// Enough to render reflowable text; images, CSS and footnotes are ignored.
class EpubParser {
  static EpubBook parse(List<int> bytes) {
    final zip = ZipDecoder().decodeBytes(bytes);
    String read(String path) {
      final f = zip.findFile(path);
      if (f == null) throw FormatException('EPUB is missing $path');
      return utf8.decode(f.content as List<int>);
    }

    final container = XmlDocument.parse(read('META-INF/container.xml'));
    final opfPath = container.findAllElements('rootfile').first.getAttribute('full-path')!;
    final base = opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1) : '';
    final opf = XmlDocument.parse(read(opfPath));

    String meta(String local) => opf.descendants.whereType<XmlElement>().where((e) => e.name.local == local).map((e) => e.innerText.trim()).firstWhere((_) => true, orElse: () => '');

    final manifest = <String, String>{for (final item in opf.findAllElements('item')) item.getAttribute('id')!: item.getAttribute('href')!};
    final spine = opf.findAllElements('itemref').map((e) => e.getAttribute('idref')!).toList();

    final chapters = <EpubChapter>[];
    for (final id in spine) {
      final href = manifest[id];
      if (href == null) continue;
      final doc = XmlDocument.parse(read('$base$href'));
      final heading = doc.descendants.whereType<XmlElement>().where((e) => const {'h1', 'h2', 'h3'}.contains(e.name.local)).map((e) => e.innerText.trim()).firstWhere((_) => true, orElse: () => '');
      final title = heading.isNotEmpty ? heading : doc.findAllElements('title').map((e) => e.innerText.trim()).firstWhere((_) => true, orElse: () => 'Chapter ${chapters.length + 1}');
      final paras = doc.descendants.whereType<XmlElement>().where((e) => e.name.local == 'p').map((e) => e.innerText.replaceAll(RegExp(r'\s+'), ' ').trim()).where((t) => t.isNotEmpty).toList();
      if (paras.isEmpty) continue;
      chapters.add(EpubChapter(title: title, paragraphs: paras));
    }
    return EpubBook(title: meta('title'), author: meta('creator'), chapters: chapters);
  }
}
