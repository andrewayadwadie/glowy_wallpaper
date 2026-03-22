class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int perPage;
  final bool hasMore;
  final int? totalCount;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.perPage,
    required this.hasMore,
    this.totalCount,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      hasMore: json['has_more'] as bool,
      totalCount: json['total_count'] as int?,
    );
  }
}
