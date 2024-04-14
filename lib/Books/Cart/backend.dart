// CartItem model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final String price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'Title': title,
      'Price': price,
      'Image': image,
      'Quantity': quantity,
    };
  }
}

// Cart Provider
class CartProvider extends ChangeNotifier {
  final String userId;

  CartProvider(this.userId);


  // Add item to cart
  Future<void> addToCart(CartItem item) async {
    try {
      await FirebaseFirestore.instance
          .collection('Cart')
          .doc(userId)
          .collection('Cart')
          .add(item.toMap());
      notifyListeners();
    } catch (error) {
      print("Failed to add item to cart: $error");
    }
  }

  // Get cart items
  Future<List<CartItem>> getCartItems() async {
    List<CartItem> cartItems = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Cart')
          .doc(userId)
          .collection('Cart')
          .get();

      cartItems = querySnapshot.docs.map((doc) {
        return CartItem(
          id: doc.id,
          title: doc['Title'],
          price: doc['Price'],
          image: doc['Image'],
          quantity: doc['Quantity'],
        );
      }).toList();
    } catch (error) {
      print("Failed to fetch cart items: $error");
    }

    return cartItems;
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Cart')
          .doc(userId)
          .collection('Cart')
          .doc(itemId)
          .delete();
      notifyListeners();
    } catch (error) {
      print("Failed to remove item from cart: $error");
    }
  }

  // Increment quantity
  Future<void> incrementQuantity(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Cart')
          .doc(userId)
          .collection('Cart')
          .doc(itemId)
          .update({'Quantity': FieldValue.increment(1)});
      notifyListeners();
    } catch (error) {
      print("Failed to increment quantity: $error");
    }
  }

  // Decrement quantity
  Future<void> decrementQuantity(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Cart')
          .doc(userId)
          .collection('Cart')
          .doc(itemId)
          .update({'Quantity': FieldValue.increment(-1)});
      notifyListeners();
    } catch (error) {
      print("Failed to decrement quantity: $error");
    }
  }
}
