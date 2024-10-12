
# GitHub Issues Fetcher

## Overview

This Flutter application allows users to search for GitHub issues by entering the owner/repository name (e.g., `flutter/flutter`). The app validates the input format and fetches relevant issues from the GitHub API. Users can also filter issues based on their state (open/closed) and view detailed information.

## Features

- Search for GitHub issues by owner/repository name
- Validate input format to ensure it matches the owner/repository structure
- Filter issues by open/closed status
- Display issue details including title, creation date, and labels
- Infinite scrolling to load more issues as the user scrolls

## Approach

1. **State Management**: Used Riverpod for state management to handle issues and loading/error states efficiently.
2. **API Integration**: Integrated the GitHub API to fetch issues based on user input.
3. **UI Design**: Developed a user-friendly interface with search functionality and dropdown filters for issue categorization.
4. **Error Handling**: Implemented error handling to provide user feedback in case of network issues or invalid inputs.

## Challenges

- **State Management**: Ensuring smooth state transitions while fetching data and displaying loading indicators required careful handling of the application state.

## Conclusion

This project has enhanced my skills in Flutter development, state management, and API integration. I have gained valuable experience in building responsive and user-friendly applications.
