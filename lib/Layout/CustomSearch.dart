import 'package:flutter/material.dart';
import 'package:my_dash/Layout/Page0.dart';
import 'package:my_dash/Layout/PageChartJson.dart';

class CustomSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          // Clear the search query
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        // Close the search bar
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Handle the navigation directly when the search is submitted
    navigateToPage(context, query);
    return Container(); // Return an empty container, as we're handling the navigation directly
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement your search suggestions UI here
    return FutureBuilder<List<String>>(
      // Assume you have a method that returns a list of all available pages/words
      future: getAllPages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final List<String> allPages = snapshot.data ?? [];

        // Filter pages based on the search query
        final List<String> filteredPages = allPages
            .where((page) => page.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: filteredPages.length,
          itemBuilder: (context, index) {
            final page = filteredPages[index];
            return ListTile(
              title: Text(page),
              onTap: () {
                // Close the search bar and navigate to the selected page
                close(context, page);
                // Implement logic to navigate to the selected page
                navigateToPage(context, page);
              },
            );
          },
        );
      },
    );
  }

  Future<List<String>> getAllPages() async {
    // Replace this with logic to fetch all available pages/words in your app
    return ['Page0', 'Page2', 'Profile'];
  }

  void navigateToPage(BuildContext context, String page) {
    Widget pageWidget;

    // Assign the appropriate widget based on the page name
    switch (page) {
      case 'DETAILS':
        pageWidget = Page0();
        break;
      case 'DASHOBRD':
        pageWidget = Page2();
        break;
      // Add cases for other pages...
      default:
        // Handle unknown pages or navigate to a default page
        pageWidget = Page2();
        return;
    }

    // Navigate to the selected page with a custom page route
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => pageWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuad;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}

class SearchResultPage extends StatelessWidget {
  final Widget pageWidget;

  SearchResultPage({required this.pageWidget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Result'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pageWidget, // Display the page without hero animation
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
