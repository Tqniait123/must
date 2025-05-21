class PaginatedResponse<T> {
  List<T> items;
  Pagination pagination;

  PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  // Factory method to create an instance from JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List).map((item) => fromJsonT(item)).toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  int total;
  int count;
  int perPage;
  String? nextPageUrl;
  String? prevPageUrl;
  int currentPage;
  int lastPage;
  bool hasMorePages;

  Pagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.nextPageUrl,
    required this.prevPageUrl,
    required this.currentPage,
    required this.lastPage,
    required this.hasMorePages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      count: json['count'],
      perPage: json['per_page'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      hasMorePages: json['has_more_pages'],
    );
  }
}
