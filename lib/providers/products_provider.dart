import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './auth.dart';
import './product.dart';

import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  String token;
  String userId;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProducts(Product product) async {
    final url = Uri.parse(
      'https://cypherstore-2fdba-default-rtdb.firebaseio.com/products.json?auth=$token',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'comments': product.comments,
          'featured': product.featured,
          'quantity': product.quantity,
          'rating': product.rating,
        }),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        comments: product.comments,
        featured: product.featured,
        quantity: product.quantity,
        rating: product.rating,
      );
      _items.insert(0, newProduct);

      notifyListeners();
    } catch (error) {
      // print(error);
      // throw error;
    }
  }

  Future<void> getProducts() async {
    // final filterString =
    //     filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    //var url = Uri.parse("https://cypherstore.onrender.com/products");
    final url = Uri.parse(
      'https://cypherstore-2fdba-default-rtdb.firebaseio.com/products.json?auth=$token',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      final List<Product> loadedProducts = [];

      // extractedData.forEach((prodData) {
      //   loadedProducts.insert(
      //       0,
      //       Product(
      //         id: prodData['_id'],
      //         name: prodData['name'],
      //         description: prodData['description'],
      //         price: prodData['price'],
      //         imageUrl: prodData['image'],
      //         category: prodData['category'],
      //         comments: prodData['comments'],
      //         featured: prodData['featured'],
      //         quantity: prodData['quantity'],
      //         rating: prodData['rating'],
      //       ));
      // });
      extractedData.forEach((prodId, prodData) {
        loadedProducts.insert(
            0,
            Product(
              id: prodId,
              name: prodData['name'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              category: prodData['category'],
              comments: prodData['comments'],
              featured: prodData['featured'],
              quantity: prodData['quantity'],
              rating: prodData['rating'],
            ));
      });
      _items = loadedProducts;
      // loadedProducts.forEach(
      //   (element) => addProducts(element),
      // );
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
        'https://cypherstore-2fdba-default-rtdb.firebaseio.com/products/$id.json?auth=$token',
      );
      await http.patch(url,
          body: json.encode({
            'title': newProduct.name,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('......');
    }
  }

  void deleteProduct(String id) {
    final url = Uri.parse(
      'https://cypherstore-2fdba-default-rtdb.firebaseio.com/products.json?auth=$token',
    );

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
  }

  void update(Auth auth) {
    token = auth.token;
    userId = auth.userId;
    // getProducts();
    notifyListeners();
  }
}
