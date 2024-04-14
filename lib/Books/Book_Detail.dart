import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harekrishnagoldentemple/Books/Cart/Cart.dart';
import 'package:harekrishnagoldentemple/Books/Cart/backend.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

sSAppButton({
  Function? onPressed,
  String? title,
  required BuildContext context,
  Color? color,
  Color? textColor,
}) {
  return AppButton(
    shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.deepOrange, width: 1)),
    text: title,
    color: Colors.orange,
    textColor: textColor ?? Color(0xfffffbfb),
    onTap: () {
      onPressed!();
    },
    width: context.width(),
  );
}

class SPDetail extends StatefulWidget {
  final String img2;
  final String img;

final String category;
final String title;
final String description;
final String price;

  SPDetail({required this.img2, required this.category, required this.title, required this.description, required this.price,  required this.img});

  @override
  SPDetailState createState() => SPDetailState();
}

class SPDetailState extends State<SPDetail> {
  int index = 0;
  late List<String> img;
  late bool isInCart;

  void checkIfItemInCart() async {
    List<CartItem> cartItems =
        await Provider.of<CartProvider>(context, listen: false)
            .getCartItems();
    setState(() {
      isInCart = cartItems.any((item) => item.title == widget.title);
    });
  }
  @override
  void initState() {
    super.initState();
    img = [  widget.img2
];

    init();
        isInCart = false;
    // Check if item is already in cart and set isInCart accordingly
    checkIfItemInCart();
  }

  void init() async {
    img.insert(0, widget.img.validate());
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(widget.title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Color(0x00000000), width: 1)),
        
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
              child: Column(
                children: [
                  Image(
                    image: NetworkImage(img[index]),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: img.map((e) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        radius: 8,
                        onTap: () {
                          setState(() {
                            index = img.indexOf(e);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: index == img.indexOf(e) ? Colors.red : Colors.transparent,
                            ),
                          ),
                          child: Image(image: NetworkImage(e.validate()), height: 40, width: 40, fit: BoxFit.cover),
                        ),
                      ).paddingRight(8);
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category: ${widget.category}", textAlign: TextAlign.start, overflow: TextOverflow.clip, style: secondaryTextStyle()),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(widget.title, textAlign: TextAlign.start, overflow: TextOverflow.clip, style: boldTextStyle()),
                      Text("₹${widget.price}", textAlign: TextAlign.start, overflow: TextOverflow.clip, style: boldTextStyle()),
                    ],
                  ),
                  SizedBox(height: 16),
                        SizedBox(height: 16, width: 16),
                  Text("Description", textAlign: TextAlign.start, overflow: TextOverflow.clip, style: boldTextStyle()),
                  SizedBox(height: 8),
                  Text(
                      widget.description,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: secondaryTextStyle()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.amber.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.shopping_cart_outlined, color: Colors.orange,),
            ),
            SizedBox(width: 8),
            Expanded(
              child: sSAppButton(
                context: context,
                title: isInCart ? 'Go To Cart' : 'Add To Cart',
                onPressed: () {
                  if (!isInCart) {
                    CartItem newItem = CartItem(
                      id: "1",
                      title: widget.title,
                      price: widget.price,
                      image: widget.img,
                      quantity: 1,
                    );
                    Provider.of<CartProvider>(context, listen: false)
                        .addToCart(newItem);
                    setState(() {
                      isInCart = true;
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(FirebaseAuth.instance.currentUser!.uid),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
