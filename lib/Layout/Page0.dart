import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_dash/Naviguation%20menu/PageMenu.dart';
import 'package:my_dash/services/activation_client_api.dart';
import 'package:provider/provider.dart';
import 'package:my_dash/Layout/PageChartDetailedPerf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Import for controlling screen orientation

class Page0 extends StatefulWidget {
  const Page0({Key? key}) : super(key: key);

  @override
  Page0State createState() => Page0State();
}

class Page0State extends State<Page0> {
  int selectedOptionIndex = -1; // Initialize with a default value
  bool loading = true;
  List<Map<String, dynamic>> aggregatedEntities = [];
  List<String> entityTypeNames = [];
  List<String> selectedEntityTypeNames = [];
  List<Map<String, dynamic>> filteredEntities = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDataFromLocalStorage();
    _filterEntities;
    // Set the preferred orientations to portrait only
    // Set the preferred orientations to portrait only
    // Apply search initially.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
    // Set the preferred orientations to portrait only
  }

  Future<void> _loadDataFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('salesData');
    String systemDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? salesDatatime = prefs.getString('salesDatatime');
    print(salesDatatime);

    if (jsonData != null && salesDatatime == systemDate) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      Map<String, Map<String, dynamic>> entityMap = {};
      Set<String> entityTypesSet = {};

      for (var entity in decodedData) {
        String entityName = entity['entity_name'] ?? 'Unknown';
        int nbrTransaction = entity['nbr_transaction'] ?? 0;
        String entityTypeName = entity['entity_type_name'] ?? '';

        if (entityMap.containsKey(entityName)) {
          entityMap[entityName]!['nbr_transaction'] += nbrTransaction;
        } else {
          entityMap[entityName] = {
            'entity_name': entityName,
            'nbr_transaction': nbrTransaction,
            'entity_type_name': entityTypeName,
          };
        }

        entityTypesSet.add(entityTypeName);
      }

      List<Map<String, dynamic>> aggregatedList = entityMap.values.toList();
      aggregatedList
          .sort((a, b) => b['nbr_transaction'].compareTo(a['nbr_transaction']));

      setState(() {
        aggregatedEntities = aggregatedList;
        loading = false;
        entityTypeNames = entityTypesSet.toList();
        selectedEntityTypeNames =
            prefs.getStringList('selectedEntityTypeNames') ?? [];
      });
    } else {
      await fetchEntities();
    }
  }

  Future<void> fetchEntities() async {
    try {
      ApiService apiService = ApiService();
      List<dynamic> fetchedData = await apiService.fetchData();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('salesData', jsonEncode(fetchedData));
      String systemDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      prefs.setString('salesDatatime', systemDate);

      Map<String, Map<String, dynamic>> entityMap = {};
      Set<String> entityTypesSet = {};

      for (var entity in fetchedData) {
        String entityName = entity['entity_name'] ?? 'Unknown';
        int nbrTransaction = entity['nbr_transaction'] ?? 0;
        String entityTypeName = entity['entity_type_name'] ?? '';

        if (entityMap.containsKey(entityName)) {
          entityMap[entityName]!['nbr_transaction'] += nbrTransaction;
        } else {
          entityMap[entityName] = {
            'entity_name': entityName,
            'nbr_transaction': nbrTransaction,
            'entity_type_name': entityTypeName,
          };
        }

        entityTypesSet.add(entityTypeName);
      }

      List<Map<String, dynamic>> aggregatedList = entityMap.values.toList();
      aggregatedList
          .sort((a, b) => b['nbr_transaction'].compareTo(a['nbr_transaction']));

      setState(() {
        aggregatedEntities = aggregatedList;
        loading = false;
        entityTypeNames = entityTypesSet.toList();
        selectedEntityTypeNames =
            prefs.getStringList('selectedEntityTypeNames') ?? [];
      });
    } catch (e) {
      print("Error fetching entities: $e");
      setState(() {
        loading = false;
      });
    }
  }

  void _filterEntities(String query) {
    final filteredList = aggregatedEntities.where((entity) {
      bool matchesSearch =
          entity['entity_name'].toLowerCase().contains(query.toLowerCase()) ||
              entity['nbr_transaction'].toString().contains(query);
      bool matchesFilter = selectedEntityTypeNames.isEmpty ||
          selectedEntityTypeNames.contains(entity['entity_type_name']);
      return matchesSearch && matchesFilter;
    }).toList();

    setState(() {
      filteredEntities = filteredList;
    });
  }

  List<Map<String, dynamic>> getFilteredEntities() {
    return aggregatedEntities.where((entity) {
      bool matchesSearch = _searchController.text.isEmpty ||
          entity['entity_name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          entity['nbr_transaction'].toString().contains(_searchController.text);

      bool entityTypeCondition = selectedEntityTypeNames.isEmpty ||
          selectedEntityTypeNames.contains(entity['entity_type_name']);

      return matchesSearch && entityTypeCondition;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: themeProvider.isDarkMode
          ? Color.fromARGB(255, 15, 19, 21)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterEntities,
                  decoration: InputDecoration(
                    hintText: 'Search by entity name ...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              Content(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: entityTypeNames.map((entityType) {
                      bool isSelected =
                          selectedEntityTypeNames.contains(entityType);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedEntityTypeNames.remove(entityType);
                            } else {
                              selectedEntityTypeNames.add(entityType);
                            }
                          });
                          _saveSelectedFilters(
                              selectedEntityTypeNames); // Save filters
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color.fromARGB(223, 255, 115, 34)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            entityType,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'Entités par opérations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  loading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: filteredEntities.isEmpty
                              ? aggregatedEntities.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  var entity = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: idx == 0
                                              ? Color.fromARGB(
                                                  223, 255, 115, 34)
                                              : Colors.grey[400],
                                          child: Text('${idx + 1}',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entity['entity_name'] ??
                                                    'Unknown',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(height: 5.0),
                                              Text(
                                                  'Nbr Transaction: ${entity['nbr_transaction']}'),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PageChartDetailedPerf(
                                                        entityName: entity[
                                                            'entity_name']),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 30.0,
                                                color: Color.fromARGB(
                                                    223, 255, 115, 34),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : getFilteredEntities()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                  int idx = entry.key;
                                  var entity = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: idx == 0
                                              ? Color.fromARGB(
                                                  223, 255, 115, 34)
                                              : Colors.grey[400],
                                          child: Text('${idx + 1}',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entity['entity_name'] ??
                                                    'Unknown',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(height: 5.0),
                                              Text(
                                                  'Nbr Transaction: ${entity['nbr_transaction']}'),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                8.0), // Adjust the width as needed
                                        GestureDetector(
                                          onTap: () {
                                            // Navigate to PageChartDetailedPerf when the arrow is tapped
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PageChartDetailedPerf(
                                                        entityName: entity[
                                                            'entity_name']),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 30.0,
                                                color: Color.fromARGB(
                                                    223, 255, 115, 34),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _saveSelectedFilters(List<String> selectedEntityTypeNames) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('selectedEntityTypeNames', selectedEntityTypeNames);
}

class Content extends StatelessWidget {
  final Widget child;

  const Content({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    );
  }
}
