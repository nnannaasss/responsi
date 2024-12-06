import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String? imageUrl;

  DetailScreen({
    required this.id,
    required this.title,
    this.imageUrl,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Map<String, dynamic>> _restaurantDetail;
  bool isFavorited = false;

  Future<Map<String, dynamic>> fetchRestaurantDetail() async {
    final response = await http.get(
      Uri.parse('https://restaurant-api.dicoding.dev/detail/${widget.id}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['restaurant'];
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }

  Future<void> checkIfFavorited() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoriteData = prefs.getString('favorite_restaurants');
    if (favoriteData != null) {
      List<Map<String, dynamic>> favoriteRestaurants =
          List<Map<String, dynamic>>.from(json.decode(favoriteData));
      setState(() {
        isFavorited = favoriteRestaurants
            .any((restaurant) => restaurant['id'] == widget.id);
      });
    }
  }

  Future<void> toggleFavorite() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> favoriteRestaurants = [];

    // Ambil data favorit dari SharedPreferences
    String? favoriteData = prefs.getString('favorite_restaurants');
    if (favoriteData != null) {
      favoriteRestaurants =
          List<Map<String, dynamic>>.from(json.decode(favoriteData));
    }

    // Cek apakah restoran sudah difavoritkan
    final currentRestaurant = {
      'id': widget.id,
      'title': widget.title,
      'imageUrl': widget.imageUrl,
    };

    String message; // Untuk menyimpan pesan snackbar

    if (isFavorited) {
      // Hapus dari daftar favorit
      favoriteRestaurants.removeWhere((restaurant) => restaurant['id'] == widget.id);
      message = 'Removed from favorites!';
    } else {
      // Tambahkan ke daftar favorit
      favoriteRestaurants.add(currentRestaurant);
      message = 'Added to favorites!';
    }

    // Simpan kembali data favorit
    await prefs.setString('favorite_restaurants', json.encode(favoriteRestaurants));

    // Update status favorit
    setState(() {
      isFavorited = !isFavorited;
    });

    // Tampilkan snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _restaurantDetail = fetchRestaurantDetail();
    checkIfFavorited();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _restaurantDetail,
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
                    if (widget.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.imageUrl!,
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
                            data['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorited ? Colors.red : Colors.grey,
                          ),
                          onPressed: toggleFavorite,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "City: ${data['city']}, Rating: ${data['rating']}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    if (data['menus'] != null) ...[
                      const Text(
                        "Menu :",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Foods: ${data['menus']['foods'].map((food) => food['name']).join(', ')}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Drinks: ${data['menus']['drinks'].map((drink) => drink['name']).join(', ')}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
