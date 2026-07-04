class NotionPage {
  const NotionPage({
    required this.id,
    required this.title,
    required this.content,
    required this.lastEdited,
    required this.notionUrl,
    required this.wordCount,
    this.domain,
  });

  final String id;
  final String title;
  final String content;
  final String? domain;
  final String lastEdited;
  final String notionUrl;
  final int wordCount;

  factory NotionPage.fromJson(Map<String, dynamic> json) {
    return NotionPage(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      content: json['content'] as String? ?? '',
      domain: json['domain'] as String?,
      lastEdited: json['last_edited'] as String,
      notionUrl: json['notion_url'] as String,
      wordCount: (json['word_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class NotionPagesResponse {
  const NotionPagesResponse({
    required this.pages,
    required this.syncedAt,
  });

  final List<NotionPage> pages;
  final String syncedAt;

  factory NotionPagesResponse.fromJson(Map<String, dynamic> json) {
    final rawPages = json['pages'] as List<dynamic>? ?? const [];
    return NotionPagesResponse(
      pages: rawPages
          .whereType<Map<String, dynamic>>()
          .map(NotionPage.fromJson)
          .toList(),
      syncedAt: json['synced_at'] as String,
    );
  }
}

class NotionHealthStatus {
  const NotionHealthStatus({
    required this.configured,
    required this.pagesAccessible,
    required this.pageCount,
  });

  final bool configured;
  final bool pagesAccessible;
  final int pageCount;

  factory NotionHealthStatus.fromJson(Map<String, dynamic> json) {
    return NotionHealthStatus(
      configured: json['configured'] as bool? ?? false,
      pagesAccessible: json['pages_accessible'] as bool? ?? false,
      pageCount: (json['page_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class NotionSyncResult {
  const NotionSyncResult({
    required this.added,
    required this.updated,
    required this.unchanged,
    required this.syncedAt,
  });

  final int added;
  final int updated;
  final int unchanged;
  final DateTime syncedAt;
}
