import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/handlers/user_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/book.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/screens/sale/sale_create_new.dart';
import 'package:fook/screens/sale/sale_edit_sale.dart';
import 'package:fook/model/user.dart' as fook;
import '../../theme/colors.dart';
import '../widgets/rounded_app_bar.dart';
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
        appBar: RoundedAppBar("MY SALES", Theme.of(context).highlightColor, ""),
        body: _saleList(),
      );

  ///List of a user's sale objects
  Widget _saleList() {
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            margin: const EdgeInsets.all(4),
            height: MediaQuery.of(context).size.height - 285,
            decoration: BoxDecoration(
              image: const DecorationImage(
                  opacity: 0.1,
                  scale: 2,
                  image: AssetImage(
                    "lib/assets/books_vector.png",
                  )),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.5, 0.5),
                  blurRadius: 1,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: CustomColors.fookGradient,
              ),
            ),
            child: StreamBuilder(
                stream: SaleHandler.getSaleStream(
                    FirebaseAuth.instance.currentUser!.uid,
                    FirebaseFirestore.instance),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Sale> sales = snapshot.data as List<Sale>;
                    return ListView.builder(
                        itemCount: sales.length,
                        itemBuilder: (BuildContext context, int index) {
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
                                            builder: (context) => EditSale(
                                                  thisbook:
                                                      saleInfo['book'] as Book,
                                                  thissale: sales[index],
                                                )),
                                      );
                                    },
                                    child: saleCard(
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
                        });
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }
                }),
          ),
          _createSaleButton(),
        ]));
  }

  ///Button for creating new sale objects
  Widget _createSaleButton() {
    return Container(
        alignment: Alignment.center,
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
                  builder: (context) => const SaleCreateNew(),
                ),
              );
            }));
  }

  ///Helper method to retrieve information for SaleCard
  _getSaleInfo(Sale sale) async {
    Map<String, dynamic> result = {};
    result['user'] = await UserHandler.getUser(
        FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
    result['book'] = await BookHandler.getBook(sale.isbn);
    return result;
  }
}
