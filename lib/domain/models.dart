/// Formats a title can be consumed in.
enum BookFormat { ebook, audiobook, both }

class Chapter {
  const Chapter(this.number, this.title, this.minutes);
  final int number;
  final String title;
  final int minutes;
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.format,
    required this.synopsis,
    required this.chapters,
    this.premium = false,
    this.pages = 0,
    this.audioMinutes = 0,
    this.rating = 4.5,
    this.ratings = 0,
    this.epubAsset,
    this.category = 'Fiction',
  });

  final String id;
  final String title;
  final String author;
  final String cover;
  final BookFormat format;
  final String synopsis;
  final List<Chapter> chapters;
  final bool premium;
  final int pages;
  final int audioMinutes;
  final double rating;
  final int ratings;
  final String? epubAsset;
  final String category;

  bool get hasEbook => format != BookFormat.audiobook;
  bool get hasAudio => format != BookFormat.ebook;
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.authorPhoto,
    required this.image,
    required this.date,
    required this.minutes,
    required this.paragraphs,
    this.pullQuote,
    this.mentionedBookId,
  });

  final String id;
  final String title;
  final String author;
  final String authorPhoto;
  final String image;
  final DateTime date;
  final int minutes;
  final List<String> paragraphs;
  final String? pullQuote;
  final String? mentionedBookId;
}

class RefEntry {
  const RefEntry({
    required this.id,
    required this.term,
    required this.topic,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definition,
    required this.didYouKnow,
    this.related = const [],
    this.appearsIn = const [],
    this.image,
    this.premium = false,
  });

  final String id;
  final String term;
  final String topic;
  final String pronunciation;
  final String partOfSpeech;
  final String definition;
  final String didYouKnow;
  final List<String> related;
  final List<String> appearsIn;
  final String? image;
  final bool premium;
}

enum BookmarkKind { page, audio, reference, article }

class Bookmark {
  const Bookmark({required this.id, required this.kind, required this.targetId, required this.label, required this.createdAt, this.snippet});

  final String id;
  final BookmarkKind kind;
  final String targetId;
  final String label;
  final DateTime createdAt;
  final String? snippet;
}

/// A parsed EPUB: spine order chapters with plain paragraphs.
class EpubBook {
  const EpubBook({required this.title, required this.author, required this.chapters});
  final String title;
  final String author;
  final List<EpubChapter> chapters;

  int get paragraphCount => chapters.fold(0, (n, c) => n + c.paragraphs.length);
}

class EpubChapter {
  const EpubChapter({required this.title, required this.paragraphs});
  final String title;
  final List<String> paragraphs;
}

enum CmsType { dailyRead, newTitle, reference }

enum CmsStatus { draft, scheduled, published }

/// One item in the editor studio schedule (the simulated CMS).
class CmsEntry {
  const CmsEntry({required this.id, required this.title, required this.type, required this.status, required this.date, this.image});

  final String id;
  final String title;
  final CmsType type;
  final CmsStatus status;
  final DateTime date;
  final String? image;

  CmsEntry copyWith({CmsStatus? status, DateTime? date}) => CmsEntry(id: id, title: title, type: type, status: status ?? this.status, date: date ?? this.date, image: image);

  factory CmsEntry.fromJson(Map<String, dynamic> j) => CmsEntry(
    id: j['id'] as String,
    title: j['title'] as String,
    type: CmsType.values.byName(j['type'] as String),
    status: CmsStatus.values.byName(j['status'] as String),
    date: DateTime.parse(j['date'] as String),
    image: j['image'] as String?,
  );
}
