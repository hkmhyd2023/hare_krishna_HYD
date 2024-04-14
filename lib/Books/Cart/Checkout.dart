// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart' as gf;
import 'package:harekrishnagoldentemple/Books/Orders.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:harekrishnagoldentemple/Books/Cart/backend.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CheckoutPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController line1Controller = TextEditingController();
  final TextEditingController line2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<void> handlePaymentSuccessResponse(
        PaymentSuccessResponse response, List<CartItem> cartItems) async {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Combine a prefix (optional) and the timestamp
      String invoiceNumber =
          'INV-$timestamp'; // Example format: INV-1618851163864
      double subtotal = cartItems.fold(0,
          (total, item) => total + (double.parse(item.price) * item.quantity));
      DateTime today = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(today);

      // Generate and upload invoice PDF
      String pdfUrl = await generateInvoice(
          cartItems,
          subtotal,
          invoiceNumber,
          formattedDate,
          '${line1Controller.text.toString()} ${line2Controller.text.toString()}, ${cityController.text.toString()}, ${stateController.text.toString()} ${pincodeController.text.toString()}');

      await _firestore
          .collection('Orders')
          .doc(
              "${FirebaseAuth.instance.currentUser!.displayName}-${DateTime.now()}")
          .set({
        'payid': response.paymentId,
        'uid': '${FirebaseAuth.instance.currentUser!.uid}',
        'Status': 'Yet to be Dispatched',
        'Phone': '${phoneNumberController.text.toString()}',
        'invoice_number': invoiceNumber,
        'DateOfOrder': "${formattedDate}",
        'Email': '${emailController.text.toString()}',
        'Address':
            '${line1Controller.text.toString()} ${line2Controller.text.toString()}, ${cityController.text.toString()}, ${stateController.text.toString()} ${pincodeController.text.toString()}',
        'Name': nameController.text.toString(),
        'Items': cartItems
            .map((item) => {
                  'title': item.title,
                  'price': item.price,
                  'quantity': item.quantity,
                  'image': item.image,
                })
            .toList(),
        'Subtotal': subtotal.toStringAsFixed(2),
        'DeliveryCharge': '70',
        'Total': (subtotal + 70).toStringAsFixed(2),
        'InvoiceUrl': pdfUrl, // Store the URL of the uploaded invoice PDF
      });
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => YourOrdersList(),
      ));
      await _firestore
          .collection('Cart')
          .doc('${FirebaseAuth.instance.currentUser!.uid}')
          .delete();

      print("Order id: ${response.orderId}");
    }

    void handleExternalWalletSelected(ExternalWalletResponse response) {
      print("External Wallet Selected ${response.walletName}");
    }

    void handlePaymentErrorResponse(PaymentFailureResponse response) {
      print(
          'Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return FutureBuilder<List<CartItem>>(
            future: cartProvider.getCartItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<CartItem> cartItems = snapshot.data!;
                double subtotal = cartItems.fold(
                    0,
                    (total, item) =>
                        total + (double.parse(item.price) * item.quantity));

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Billing Information',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      _buildTextField('Name', nameController, Icons.person),
                      SizedBox(height: 8),
                      _buildTextField(
                          'Phone Number', phoneNumberController, Icons.phone),
                      SizedBox(height: 8),
                      _buildTextField('Email', emailController, Icons.email),
                      SizedBox(height: 8),
                      _buildTextField(
                          'Line 1 Address', line1Controller, Icons.location_on),
                      SizedBox(height: 8),
                      _buildTextField(
                          'Line 2 Address', line2Controller, Icons.location_on),
                      SizedBox(height: 8),
                      _buildTextField(
                          'City', cityController, Icons.location_city),
                      SizedBox(height: 8),
                      _buildTextField(
                          'State', stateController, Icons.location_city),
                      SizedBox(height: 8),
                      _buildTextField(
                          'Pincode', pincodeController, Icons.location_on),
                      SizedBox(height: 24),
                      Divider(thickness: 2),
                      SizedBox(height: 24),
                      Text('Order Summary',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          CartItem cartItem = cartItems[index];
                          return ListTile(
                            leading: SizedBox(
                              width: 40,
                              height: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(cartItem.image,
                                    fit: BoxFit.fill),
                              ),
                            ),
                            title: Text(cartItem.title),
                            subtitle: Text(
                                '\₹${cartItem.price} x ${cartItem.quantity} = ₹${cartItem.price.toInt() * cartItem.quantity.toInt()}'),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('\₹${subtotal.toStringAsFixed(2)}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Charge',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('\₹70',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.black),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('\₹${subtotal.toInt() + 70}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          DocumentSnapshot userSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('External-Minor-Data')
                                  .doc('Razorpay-ID')
                                  .get();
                          Razorpay razorpay = Razorpay();
                          var options = {
                            'key': '${userSnapshot['Books-ID']}',
                            'amount': '${(subtotal.toInt() + 70) * 100}',
                            'name': 'Hare Krishna Golden Temple',
                            'description':
                                'Buying Books From Hare Krishna Movement',
                            'retry': {'enabled': true, 'max_count': 10},
                            'send_sms_hash': true,
                            'prefill': {
                              'name': '${nameController.text.toString()}',
                              'contact':
                                  '${FirebaseAuth.instance.currentUser!.phoneNumber}',
                              'email':
                                  '${FirebaseAuth.instance.currentUser!.email}'
                            },
                            'external': {
                              'wallets': ['paytm']
                            },
                            'config': {
                              'display': {
                                'hide': [
                                  {'method': 'paylater'}
                                ]
                              }
                            }
                          };
                          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                              handlePaymentErrorResponse);
                          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                              (PaymentSuccessResponse response) async {
                            await handlePaymentSuccessResponse(
                                response, cartItems);
                          });
                          razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                              handleExternalWalletSelected);
                          razorpay.open(options);
                        },
                        child: Text("Pay Now",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade300),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
    );
  }

  Future<Uint8List> _fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw HttpException('Failed to load image: ${response.statusCode}');
    }
  }

  Future<String> generateInvoice(List<CartItem> cartItems, double subtotal,
      String invn, String date, String address) async {
    try {
      final imageBytes = await _fetchImageBytes(
          'https://hkmhyderabad.org/assets/logos/hare-krishna-movement.jpg');

      final font_bold =
          await rootBundle.load('assets/fonts/RobotoCondensed-Bold.ttf');

      final font =
          await rootBundle.load('assets/fonts/RobotoCondensed-Regular.ttf');
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Image(pw.MemoryImage(imageBytes),
                          width: 100, height: 50),
                      pw.Text("INVOICE",
                          style: pw.TextStyle(
                              fontSize: 45, font: pw.Font.ttf(font_bold))),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,                    crossAxisAlignment: pw.CrossAxisAlignment.end,

                        children: [pw.Text('Date: ${date}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(
                        height: 5,
                      ),
                      pw.Text('Invoice NO: ${invn}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),])
                    ]),
                pw.SizedBox(
                  height: 15,
                ),
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text('Sold By: ',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: pw.Font.ttf(font_bold),
                                )),
                            pw.SizedBox(
                                width: 200,
                                child: pw.Text(
                                    "Swayambhu Sri Lakshmi Narasimha Swamy Kshetram, 12, Road, near Anti Corruption Bureau office, NBT Nagar, Banjara Hills, Hyderabad, Telangana 500034",
                                    style:
                                        pw.TextStyle(font: pw.Font.ttf(font)))),
                          ]),
                      pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Billing Address: ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: pw.Font.ttf(font_bold))),
                            pw.SizedBox(
                                width: 200,
                                child: pw.Text(address,
                                    style:
                                        pw.TextStyle(font: pw.Font.ttf(font)))),
                          ]),
                    ]),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                    cellAlignment: pw.Alignment.center,
                    headerDecoration:
                        pw.BoxDecoration(color: PdfColors.grey200),
                    headerHeight: 40,
                    cellHeight: 30,
                    headers: [
                      'Title',
                      'Price',
                      'Quantity',
                      'Price',
                      'Sub Total'
                    ],
                    data: cartItems
                        .map((item) => [
                              item.title,
                              'Rs. ${item.price}',
                              item.quantity.toString(),
                              "Rs. ${item.price.toString()}",
                              "Rs. ${item.price.toInt() * item.quantity.toInt()}"
                            ])
                        .toList(),
                    border: null),
                pw.SizedBox(height: 60),
                pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("Sub Total - ",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 15,
                                    font: pw.Font.ttf(font_bold))),
                            pw.Text("Rs. ${subtotal}")
                          ]),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("Delivery - ",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 15,
                                    font: pw.Font.ttf(font_bold))),
                            pw.Text("Rs. 70")
                          ]),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("Total - ",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 15,
                                    font: pw.Font.ttf(font_bold))),
                            pw.Text("Rs. ${subtotal + 70}")
                          ])
                    ]),
                pw.SizedBox(height: 30),
                pw.Text("Terms and Conditions - \n",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        font: pw.Font.ttf(font_bold), fontSize: 15)),
                        pw.Text("Payment Terms: ", style: pw.TextStyle(font: pw.Font.ttf(font), fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    "\n       - Payment is due upon receipt of the invoice.\n        - Late payments may incur additional charges.\n\n   ",
                    style: pw.TextStyle(font: pw.Font.ttf(font))),                        pw.Text("Product Availablity: ", style: pw.TextStyle(font: pw.Font.ttf(font), fontWeight: pw.FontWeight.bold)),
pw.Text("\n        - All products listed on the invoice are subject to availability.\n        - The bookshop will notify the customer of any product unavailability and provide\n      alternatives if possible.", style: pw.TextStyle(font: pw.Font.ttf(font))),

              ],
            ),
          );
        },
      ));

      final pdfData = await pdf.save();
      final storageRef = FirebaseStorage.instance.ref().child('invoices');
      final filename = '${DateTime.now().millisecondsSinceEpoch}.pdf';
      await storageRef.child(filename).putData(pdfData);
      final pdfUrl = await storageRef.child(filename).getDownloadURL();
      return pdfUrl;
    } catch (e) {
      print('Error generating invoice: $e');
      return '';
    }
  }
}
