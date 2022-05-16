import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/model/sale.dart';
import 'package:fook/model/book.dart';
import 'package:fook/handlers/book_handler.dart';
import 'package:fook/screens/sale/sale_create_new.dart';

class SaleHomePage extends StatefulWidget {
  const SaleHomePage({Key? key}) : super(key: key);

  @override
  State<SaleHomePage> createState() => _SaleHomePageState();
}

class _SaleHomePageState extends State<SaleHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: const Text("MY SALES", style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SizedBox(
            height: 300,
            width: 300,
            child: LimitedBox(
              maxHeight: 160,
              maxWidth: 300,
              child: Container(
                  color: Colors.grey,
                  child: Container(
                    child: buildA(context),
                  )),
            )),
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: ElevatedButton.icon(
              icon: const Text('Create new'),
              label: const Icon(Icons.add_business),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SaleCreateNew(),
                ),
              ),
            ))
      ]));

  Widget buildA(BuildContext context) {
    return FutureBuilder(
        future: SaleHandler.getSalesForUser(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Sale> sales = snapshot.data as List<Sale>;
            return Scaffold(
              body: Center(
                child: ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SaleCard(sales[index], context);
                    }),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        });
  }

  Widget SaleCard(Sale sale, BuildContext context) {
    return FutureBuilder(
        future: BookHandler.getBook(sale.getIsbn()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Book book = snapshot.data as Book;
            String a = book.info.imageLinks['smallThumbnail'].toString();
            return ListTile(
              leading: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 60,
                  maxWidth: 60,
                ),
                child: Image.network(a),
              ),

              title: Text('Title: ' + book.info.title),
              subtitle: Text('ISBN: ' +
                  sale.getIsbn() +
                  '\n' +
                  'Price: ' +
                  sale.getPrice().toString() +
                  ':- SEK'),
              dense: true,

              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SaleCreateNew(),
                ),
              ), //lägg till ontap
            );
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        });
  }

  _doSomething() {
    //Placeholder
  }
}
