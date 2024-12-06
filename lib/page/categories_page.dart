import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/main.dart';
import 'mealdetail_page.dart';


class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchcategories() async {
    final response =
        await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['categories'];
    } else {
      throw Exception('Failed to load Meal Categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Categories"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: fetchcategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No data available"));
            } else {
              final List<dynamic> restaurants = snapshot.data!;
              return ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return ListCard(
                    idCategory: restaurant['idCategory'],
                    strCategory: restaurant['strCategory'],
                    strCategoryDescription: restaurant['strCategoryDescription'],
                    strCategoryThumb: restaurant['strCategoryThumb'],
                    
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ListCard extends StatelessWidget {
  final String idCategory;
  final String strCategory;
  final String strCategoryDescription;
  final String strCategoryThumb;
  

  const ListCard({
    Key? key,
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryDescription,
    required this.strCategoryThumb
  }) : super(key: key);
  
  get pictureId => null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetail(
              idMeal: idCategory,
              strMeal: strCategory,
              strMealThumb:
                  'https://www.themealdb.com/api/json/v1/1/categories.php$strCategoryThumb', strCategory: '', strCategoryDescription: '',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar makanan
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://www.themealdb.com/api/json/v1/1/categories.php$strCategoryThumb',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Detail Makanan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strCategory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strCategoryDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
