import '../domain/models.dart';

enum SearchScope { all, books, articles, reference }

class SearchResults {
  const SearchResults(this.books, this.articles, this.reference);
  final List<Book> books;
  final List<Article> articles;
  final List<RefEntry> reference;
  int get total => books.length + articles.length + reference.length;
  static const empty = SearchResults([], [], []);
}

/// In-memory full-text index over the catalog, the articles and the reference
/// library. Book text from parsed EPUBs is indexed too, so a phrase inside a chapter finds its book.
class SearchIndex {
  SearchIndex({required this.books, required this.articles, required this.reference, Map<String, String> bookText = const {}}) : _bookText = bookText;

  final List<Book> books;
  final List<Article> articles;
  final List<RefEntry> reference;
  final Map<String, String> _bookText;

  static bool _hit(String hay, String q) => hay.toLowerCase().contains(q);

  SearchResults query(String raw, SearchScope scope) {
    final q = raw.trim().toLowerCase();
    if (q.length < 2) return SearchResults.empty;
    bool want(SearchScope s) => scope == SearchScope.all || scope == s;
    return SearchResults(
      want(SearchScope.books) ? books.where((b) => _hit('${b.title} ${b.author} ${b.synopsis} ${b.category} ${_bookText[b.id] ?? ''}', q)).toList() : const [],
      want(SearchScope.articles) ? articles.where((a) => _hit('${a.title} ${a.author} ${a.paragraphs.join(' ')}', q)).toList() : const [],
      want(SearchScope.reference) ? (reference.where((r) => _hit('${r.term} ${r.definition}', q)).toList()..sort((a, b) => _rank(a, q).compareTo(_rank(b, q)))) : const [],
    );
  }

  // Term matches first, then definition matches.
  int _rank(RefEntry r, String q) => r.term.toLowerCase().startsWith(q) ? 0 : (_hit(r.term, q) ? 1 : 2);
}
