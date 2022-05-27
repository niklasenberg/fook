import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/book.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/screens/sale/sale_create_new.dart';
import 'package:fook/screens/sale/sale_current_sale.dart';
import 'package:fook/model/user.dart' as fook;

import '../widgets/sale_card.dart';

class SaleHomePage extends StatefulWidget {
  const SaleHomePage({Key? key}) : super(key: key);

  @override
  State<SaleHomePage> createState() => _SaleHomePageState();
}

class _SaleHomePageState extends State<SaleHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: const Text("MY SALES", style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            const SizedBox(
              height: 32,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.52,
              width: MediaQuery.of(context).size.width * 0.93,
              decoration: const BoxDecoration(image: DecorationImage(opacity: 0.1, scale: 4, image: AssetImage("lib/assets/s_logo_o.png",)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.5, 0.5),
                    blurRadius: 1,
                  ),
                ], borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xffeae6e6),
                    Color(0xfffafafa),
                    Color(0xfffaf4f4),
                    Color(0xffe5e3e3)
                  ],
                ),),
              child: buildA(context),
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.add_circle_outline_outlined,
                    ),
                    label: const Text('Create new'),
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaleCreateNew(),
                        ),
                      );
                    }))
          ])));

  Widget buildA(BuildContext context) {
    return StreamBuilder(
        stream: SaleHandler.getSaleStream(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Sale> sales = snapshot.data as List<Sale>;
            return Scaffold(
              body: Center(
                child: ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (BuildContext context, int index) {
                      //Sale sale, fook.User seller, Book book, context
                      //return SaleCard(sales[index], context);
                      return FutureBuilder(
                          future: _getSaleInfo(sales[index]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> saleInfo =
                                  snapshot.data as Map<String, dynamic>;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SaleCurrentSale(
                                              thisbook:
                                                  saleInfo['book'] as Book,
                                              thissale: sales[index],
                                            )),
                                  );
                                },
                                child: SaleCard(
                                  FirebaseAuth.instance.currentUser!.uid,
                                    FirebaseAuth.instance.currentUser!.uid,
                                    sales[index],
                                    saleInfo['user'] as fook.User,
                                    saleInfo['book'] as Book,
                                    context),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              );
                            }
                          });
                    }),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
        });
  }

  _getSaleInfo(Sale sale) async {
    Map<String, dynamic> result = {};
    result['user'] = await UserHandler.getUser(
        FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
    result['book'] = await BookHandler.getBook(sale.getIsbn());
    return result;
  }
}
