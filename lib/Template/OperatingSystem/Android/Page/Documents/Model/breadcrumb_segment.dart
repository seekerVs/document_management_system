class BreadcrumbSegment {
  final String name;
  final String? folderId; // null for root ('My Documents')

  BreadcrumbSegment({required this.name, this.folderId});

  Map<String, dynamic> toJson() => {'name': name, 'folderId': folderId};

  factory BreadcrumbSegment.fromJson(Map<String, dynamic> json) =>
      BreadcrumbSegment(
        name: json['name'] as String,
        folderId: json['folderId'] as String?,
      );
}
