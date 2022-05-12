import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:fook/model/sale.dart';
<<<<<<< HEAD:lib/widgets/sale/sale_home_page.dart
import 'package:fook/model/book.dart';
import 'package:fook/model/sale.dart' as fook;
import 'package:fook/handlers/book_handler.dart';
=======
import 'package:fook/screens/sale/widgets/rounded_app_bar.dart';
import 'package:fook/screens/sale/sale_create_new.dart';
>>>>>>> bb9fb2f94a92415fb12f81e29adb8f1ecbaef526:lib/screens/sale/sale_home_page.dart

class SaleHomePage extends StatefulWidget {
  const SaleHomePage({Key? key}) : super(key: key);

  @override
  State<SaleHomePage> createState() => _SaleHomePageState();
}

class _SaleHomePageState extends State<SaleHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      //appBar: RoundedAppBar("dorra", Colors.blue),
      appBar:AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title:  Text("MY SALES", style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SizedBox(
          height: 300,
          width: 300,
          child: LimitedBox(
            maxHeight: 160,
            maxWidth: 160,
            child: Container(
                color: Colors.grey,
                child: Container(
<<<<<<< HEAD:lib/widgets/sale/sale_home_page.dart
                  child: buildA(context),
                )),
=======
                    color: Colors.grey,
                    child: Container(
                      child: myBooksales(),
                    )),
              ),
              //lägga in en lista av alla ens böcker till försälning
              //om listan är tom ska det stå 'no ads to be shown'
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(32),
                child: ElevatedButton.icon(
                  icon: const Text('Create new'),
                  label: const Icon(Icons.add_business),
                  onPressed: () =>  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SaleCreateNew(),
                                  ),
                  ),
                ))
          ])));

  /*Widget myBooksales() => ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Bok 1'),
            subtitle: Text('info1'),
>>>>>>> bb9fb2f94a92415fb12f81e29adb8f1ecbaef526:lib/screens/sale/sale_home_page.dart
          ),
          //lägga in en lista av alla ens böcker till försälning
          //om listan är tom ska det stå 'no ads to be shown'
        ),
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: ElevatedButton.icon(
              icon: const Text('Create new'),
              label: const Icon(Icons.add_business),
              onPressed: () => Fluttertoast.showToast(
                //handler för skapa anons ska in här
                msg: 'lägg in fkn handler bro',
                fontSize: 10,
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
            book.info.imageLinks['smallThumbnail'];
            return ListTile(
              title: Text(sale.getIsbn()),
              subtitle: Text('Price: ' + sale.getPrice().toString() + " SEK"),
              onTap: () => _doSomething(), //lägg till ontap
              //leading fixa en bild med
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

// retunera som en listtile
/*  Widget SaleCard(Sale sale, BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        children: [
          ListTile(
            title: Text(
              sale.userID,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            subtitle: Text(sale.isbn),
            trailing: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              onPressed: () {
                //handler för att hämta bokobjektet
              },
              child: const Text('Show all'),
              textColor: Theme.of(context).colorScheme.onSecondary,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }*/

  /*Widget SaleCard(Sale sale, context) {
    return SizedBox(
      width: 100,
      child: Card(
          child: FutureBuilder(
        future: BookHandler.getBook(sale.isbn),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Book book = snapshot.data as Book;
            return InkWell(
                onTap: () => _doSomething(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 70,
                      child: Ink.image(
                        image: NetworkImage(
                            book.info.imageLinks['smallThumbnail'].toString()),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.centerLeft,
                      child: Text(sale.condition),
                    ),
                  ],
                ));
          } else {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            )));
          }
        },
      )),
    );
  }
*/
  _doSomething() {
    //Placeholder
  }
/*
  Widget myBooksales() => ListView.builder(
        //firebase firestore lalalal , hämta objekten här

        //för saleid, hämta isbn

        // genom isbn hämta info om boken
        itemBuilder: (_, i) {
          return ListTile(
            //hämta bokobjekten
            //välj hur de ska bli displayade här
            title: Text('$i+1'),
            //Gör en ontap för bokobbjekten en ny page
            onTap: () {}, //lägg till ontap
          );
        },
      );

  Future getPosts() async {
    body:
    future:
    SaleHandler.getSalesForUser(
        FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance);
  }*/

  //Widget

  //List<Sale> mySales = await SaleHandler.getSalesForUser(FirebaseAuth.instance.currentUser!.uid,
  //      FirebaseFirestore.instance),

}
