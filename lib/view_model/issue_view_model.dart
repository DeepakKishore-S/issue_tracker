import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/issue_model.dart';
import '../service/github_api_service.dart';

class IssuesViewModel extends StateNotifier<List<Issue>> {
  final GitHubApiService _apiService;

  IssuesViewModel(this._apiService) : super([]);

  int _currentPage = 1;
  bool _hasMoreIssues = true;
  bool loading = false;
  String? _error;

  Future<void> searchRepository(
      {required String input, required bool isOpen, bool isNew = false}) async {
    print(input);
    print(isOpen);
    if (loading || !_hasMoreIssues) return;

    loading = true;
    _error = null;
    final states = isOpen ? 'open' : 'closed';

    try {
      List<Issue> issues =
          await _apiService.fetchIssues(input, states, _currentPage);
      if (issues.isEmpty) {
        _hasMoreIssues = false;
      } else {
        if (isNew) {
          _currentPage = 0;
          state = [...issues];
        } else {
          state = [...state, ...issues];
          _currentPage++;
        }
      }
    } catch (e) {
      loading = false;
      _error = e.toString();
      state = [
        ...state,
      ];
    } finally {
      loading = false;
    }
  }

  void reset() {
    _currentPage = 1;
    _hasMoreIssues = true;
    state = [];
    _error = null;
  }

  String? get error => _error;
}

final issuesProvider =
    StateNotifierProvider<IssuesViewModel, List<Issue>>((ref) {
  return IssuesViewModel(GitHubApiService());
});
