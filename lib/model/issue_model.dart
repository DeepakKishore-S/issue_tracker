// issue_model.dart
class Issue {
  final int number;
  final String title;
  final String createdAt;
  final String author;
  final String htmlUrl;
  final List<String> labels;

  Issue({
    required this.number,
    required this.title,
    required this.createdAt,
    required this.author,
    required this.htmlUrl,
    required this.labels,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      number: json['number'],
      title: json['title'],
      createdAt: json['created_at'],
      author: json['user']['login'],
      htmlUrl: json['html_url'],
      labels: (json['labels'] as List).map((label) => label['name'] as String).toList(),
    );
  }
}
