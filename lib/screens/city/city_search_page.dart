import 'package:flutter/material.dart';

class CitySearchPage extends StatefulWidget {
  const CitySearchPage({super.key});

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final _searchController = TextEditingController();
  final List<String> _cities = [
    'Нью-Йорк',
    'Лос-Анджелес',
    'Чикаго',
    'Хьюстон',
    'Феникс',
    'Филадельфия',
    'Сан-Антонио',
    'Сан-Диего',
  ];
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = _cities;
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _cities;
      } else {
        _filteredCities = _cities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбрать город')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Введите город',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: _filterCities,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(_filteredCities[index]),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.pop(context, _filteredCities[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
