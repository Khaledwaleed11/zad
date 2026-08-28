class AzkarModel {
  final int id;
  final String category;
  final String title;
  final String text;
  final int count;

  const AzkarModel({
    required this.id,
    required this.category,
    required this.title,
    required this.text,
    required this.count,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      count: json['count'] ?? 1,
    );
  }
}
