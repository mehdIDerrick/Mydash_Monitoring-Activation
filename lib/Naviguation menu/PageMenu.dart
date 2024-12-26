import 'package:flutter/material.dart';
import 'package:my_dash/Layout/CustomSearch.dart';
import 'package:my_dash/Layout/Page0.dart';
import 'package:my_dash/Layout/PageChartJson.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Import for controlling screen orientation

class PageA extends StatefulWidget {
  const PageA({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<PageA> createState() => _PageAState();
}

class _PageAState extends State<PageA> with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  bool isNotificationVisible = true;

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 4, vsync: this);
    tabController.animation!.addListener(
      () {
        final value = tabController.animation!.value.round();
        if (value != currentPage && mounted) {
          changePage(value);
        }
      },
    );
    // Set the preferred orientations to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    // Reset the preferred orientations to allow all orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'My Dash',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/Orange_small_logo.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny : Icons.brightness_2,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            onPressed: () async {
              // Show the search bar and wait for the user to input a query
              String? result = await showSearch<String?>(
                context: context,
                delegate: CustomSearchDelegate(),
              );

              // Handle the search result (you can do something with the result if needed)
              if (result != null && result.isNotEmpty) {
                print('Search result: $result');
              }
            },
            icon: Icon(
              Icons.search,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: tabController,
            physics: isNotificationVisible
                ? NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            children: [
              Page2(),
              Page0(),
//              Page3(),
            ],
          ),
          // if (isNotificationVisible)
          //   InAppNotification(
          //     onClose: () {
          //       setState(() {
          //         isNotificationVisible = false;
          //       });
          //     },
          //   ),
        ],
      ),
      bottomNavigationBar: Container(
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        child: TabBar(
          indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
          controller: tabController,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.blueGrey, width: 4),
            insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
          onTap: (index) {
            if (isNotificationVisible) {
              setState(() {
                isNotificationVisible = false;
              });
            }
          },
          tabs: [
            TabsIcon(
              icon: Icons.home,
              iconColor: currentPage == 0
                  ? const Color.fromARGB(223, 255, 115, 34)
                  : (themeProvider.isDarkMode ? Colors.white : Colors.black),
            ),
            TabsIcon(
              icon: Icons.dashboard,
              iconColor: currentPage == 1
                  ? const Color.fromARGB(223, 255, 115, 34)
                  : (themeProvider.isDarkMode ? Colors.white : Colors.black),
            ),
            // TabsIcon(
            //   icon: Icons.pie_chart,
            //   iconColor: currentPage == 2
            //       ? const Color.fromARGB(223, 255, 115, 34)
            //       : (themeProvider.isDarkMode ? Colors.white : Colors.black),
            // ),
            // TabsIcon(
            //   icon: Icons.chat,
            //   iconColor: currentPage == 3
            //       ? const Color.fromARGB(223, 255, 115, 34)
            //       : (themeProvider.isDarkMode ? Colors.white : Colors.black),
            // ),
          ],
        ),
      ),
    );
  }
}

class TabsIcon extends StatelessWidget {
  final Color iconColor;
  final double height;
  final double width;
  final IconData icon;

  const TabsIcon({
    Key? key,
    this.iconColor = Colors.black,
    this.height = 60,
    this.width = 50,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
