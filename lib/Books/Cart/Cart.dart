import 'package:flutter/material.dart';
import 'package:harekrishnagoldentemple/Books/Cart/Checkout.dart';
import 'package:harekrishnagoldentemple/Books/Cart/backend.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  final String userId;

  CartPage(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return FutureBuilder<List<CartItem>>(
            future: cartProvider.getCartItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<CartItem> cartItems = snapshot.data!;
                return cartItems.isEmpty
                    ? Center(
                        child: Text('Your cart is empty'),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                return _buildCartItem(context, cartProvider, cartItems[index]);
                              },
                            ),
                          ),
                                                    _buildSubtotal(context, cartItems),

                        ],
                      );
              }
            },
          );
        },
      ),
    );
  }
Widget _buildCartItem(BuildContext context, CartProvider cartProvider, CartItem cartItem) {
  double subtotal = double.parse(cartItem.price) * cartItem.quantity;

  return Card(
    color: Colors.orange.shade100,
    elevation: 10,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ListTile(
      leading: SizedBox(
        width: 40,
        height: 90, // Desired height for portrait rectangle
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            cartItem.image,
            fit: BoxFit.fill, // Fill the entire space without maintaining aspect ratio
          ),
        ),
      ),
      title: Text(
        cartItem.title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(
            'Price: \₹${cartItem.price}',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 2),
          Text(
            'Sub Total: \₹${subtotal}',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 4,),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  cartProvider.decrementQuantity(cartItem.id);
                },
              ),
              Text(cartItem.quantity.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  cartProvider.incrementQuantity(cartItem.id);
                },
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          cartProvider.removeFromCart(cartItem.id);
        },
      ),
    ),
  );
}




  Widget _buildSubtotal(BuildContext context, List<CartItem> cartItems) {
    return Container(
      padding: EdgeInsets.all(16),
      color: const Color.fromRGBO(238, 238, 238, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          ElevatedButton(onPressed: () {
Navigator.of(context).push(MaterialPageRoute(
                         builder: (context) => CheckoutPage()));
          }, child: Text("Checkout", style: TextStyle(color: Colors.white),), style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade300,
  ),)
        ],
      ),
    );
  }
}
