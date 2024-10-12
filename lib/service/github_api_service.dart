import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../model/issue_model.dart';

class GitHubApiService {
  Future<List<Issue>> fetchIssues(String input, String state, int page) async {
    final url =
        'https://api.github.com/repos/$input/issues?state=$state&page=$page';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        return jsonResponse.map((json) => Issue.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('No Repository found');
      } else {
        throw Exception('Failed to load issues: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your connection.');
    }
  }
}
