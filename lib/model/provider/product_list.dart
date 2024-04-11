// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/model/provider/product.dart';

import '../../utils/constants.dart';

class ProductList with ChangeNotifier {
  final String _token;
  List<Product> _items = [];

  ProductList(this._token, this._items);

  List<Product> get items => [..._items];

  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();

  Future<void> saveProduct(Map<String, Object> data) {
    final hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            "${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token"),
        body: jsonEncode(
          {
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    _items.clear();
    final response = await http
        .get(Uri.parse("${Constants.PRODUCT_BASE_URL}.json?auth=$_token"));

    if (response.body == 'null') return; //caso BD vazio

    final Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach(
      //chave        valor
      (productId, prodcutData) {
        _items.add(
          Product(
            id: productId,
            name: prodcutData['name'],
            description: prodcutData['description'],
            price: prodcutData['price'],
            imageUrl: prodcutData['imageUrl'],
            isFavorite: prodcutData['isFavorite'],
          ),
        );
      },
    );
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse("${Constants.PRODUCT_BASE_URL}.json?auth=$_token"),
      body: jsonEncode(
        {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            "${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token"),
      );
      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
          msg: "Não foi possivel excluir o produto",
          statusCode: response.statusCode,
        );
      }
    }
  }

  int get itemsCount {
    return _items.length;
  }
}
