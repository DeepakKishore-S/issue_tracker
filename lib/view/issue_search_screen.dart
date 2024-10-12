import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_issue_tracker/provider/theme_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/snack_bar.dart';
import '../model/issue_model.dart';
import '../provider/open_issue_provider.dart';
import '../view_model/issue_view_model.dart';
import 'dart:math' as math;

class IssueSearchScreen extends ConsumerStatefulWidget {
  const IssueSearchScreen({super.key});

  @override
  _RepoSearchScreenState createState() => _RepoSearchScreenState();
}

class _RepoSearchScreenState extends ConsumerState<IssueSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  bool filter = false;

  String? selectedOpenClosed;
  String? selectedLabel;
  String? selectedAuthor;
  String? selectedAssignee;
  String? selectedMilestone;

  @override
  Widget build(BuildContext context) {
    final issuesState = ref.watch(issuesProvider);
    final isOpen = ref.watch(openIssuesProvider);
    final error = ref.watch(issuesProvider.notifier).error;
    final isLoading = ref.watch(issuesProvider.notifier).loading;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _isSearching
            ? _buildSearchField()
            : Text(
                'Repo Issues',
                style: TextStyle(
                  color: themeMode == ThemeMode.dark
                      ? Colors.white70
                      : Colors.grey[800],
                ),
              ),
        backgroundColor:
            themeMode == ThemeMode.dark ? Colors.black : Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: ref.watch(themeProvider) == ThemeMode.dark
                  ? Colors.white70
                  : Colors.grey[800],
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _controller.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterDropdown('Open', ['Open', 'Closed'], (value) {
                    final regex = RegExp(r'^[a-zA-Z0-9-_]+\/[a-zA-Z0-9-_]+$');
                    if (!regex.hasMatch(_controller.text)) {
                      AppSnackBars.errorSnackBar(
                          context: context,
                          content: 'Invalid format. Use owner/repository.');
                    } else {
                      ref.read(openIssuesProvider.notifier).state =
                          value == "Open";
                      ref.read(issuesProvider.notifier).searchRepository(
                          input: _controller.text,
                          isOpen: value == "Open",
                          isNew: true);
                      setState(() {
                        selectedOpenClosed = value;
                      });
                    }
                  }, selectedOpenClosed),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Center(
                child: Text(error.split(":")[1],
                    style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!ref.watch(issuesProvider.notifier).loading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    String input = _controller.text;
                    bool isOpen = selectedOpenClosed == 'Open';
                    ref.read(issuesProvider.notifier).searchRepository(
                          input: input,
                          isOpen: isOpen,
                        );
                  }
                  return false;
                },
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: issuesState.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == issuesState.length - 1) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final Issue issue = issuesState[index];
                          return _buildIssueCard(
                              issue, context, getRandomDarkColor);
                        },
                      ),
              ),
            ),
            if (issuesState.isEmpty &&
                !ref.watch(issuesProvider.notifier).loading &&
                error == null)
              Expanded(
                  child: Center(
                      child: Text(
                'No issues found.',
                style: TextStyle(
                    color: themeMode == ThemeMode.dark
                        ? Colors.white70
                        : Colors.grey[800]),
              ))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Enter owner/repository',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: ref.watch(themeProvider) == ThemeMode.dark
              ? Colors.white70
              : Colors.grey[800],
        ),
      ),
      onSubmitted: (value) {
        final regex = RegExp(r'^[a-zA-Z0-9-_]+\/[a-zA-Z0-9-_]+$');
        if (!regex.hasMatch(value)) {
          AppSnackBars.errorSnackBar(
              context: context,
              content: 'Invalid format. Use owner/repository.');
        } else {
          ref.read(issuesProvider.notifier).reset();
          ref.read(issuesProvider.notifier).searchRepository(
              input: value,
              isOpen: ref.read(openIssuesProvider.notifier).state);
        }
      },
    );
  }

  Widget _buildFilterDropdown(String label, List<String> items,
      ValueChanged<String?> onChanged, String? selectedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ref.watch(themeProvider) == ThemeMode.dark
              ? Colors.grey[800]
              : Colors.white70,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: DropdownButton<String>(
          elevation: 5,
          hint: Text(label),
          value: selectedValue,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          underline: Container(),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(value, style: const TextStyle(color: Colors.black)),
              ),
            );
          }).toList(),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildIssueCard(Issue issue, BuildContext context, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          issue.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${issue.number} - Created on: ${issue.createdAt} by ${issue.author}',
              style: const TextStyle(color: Colors.grey),
            ),
            Wrap(
              spacing: 8.0,
              children: issue.labels.map((label) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(15)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        onTap: () async {
          print(issue.htmlUrl);

          await launchUrl(Uri.parse(issue.htmlUrl));
        },
      ),
    );
  }

  Color get getRandomDarkColor {
    final Random random = Random();

    final int r = random.nextInt(128);
    final int g = random.nextInt(128);
    final int b = random.nextInt(128);
    return Color.fromARGB(255, r, g, b);
  }
}
