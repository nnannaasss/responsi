import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:shared_preferences/shared_preferences.dart';

class MealDetail extends StatefulWidget {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strCategoryDescription;
  final String? strMealThumb;

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strCategoryDescription,
    this.strMealThumb,
  });

  @override
  _MealDetailState createState() => _MealDetailState();
}

class _MealDetailState extends State<MealDetail> {
  late Future<Map<String, dynamic>> _mealDetail;
  //bool isFavorited = false;

  Future<Map<String, dynamic>> fetchmeals() async {
    final response = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.idMeal}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'];
    } else {
      throw Exception('Failed to load meal details');
    }
  }

  @override
  void initState() {
    super.initState();
    _mealDetail = fetchmeals();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strMeal),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _mealDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.strMealThumb != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.strMealThumb!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['idMeal'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['strMeal'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]
              
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
