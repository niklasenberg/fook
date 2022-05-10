//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: const Text('MY SALES', style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            SizedBox(
              height: 300,
              width: 300,
              child: LimitedBox(
                maxHeight: 160,
                maxWidth: 160,
                child: Container(
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
                  onPressed: () => Fluttertoast.showToast(
                    //handler för skapa anons ska in här
                    msg: 'lägg in fkn handler bro',
                    fontSize: 10,
                  ),
                ))
          ])));

  Widget myBooksales() => ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Bok 1'),
            subtitle: Text('info1'),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Bok 2'),
            subtitle: Text('info2'),
          ),
        ],
      );
}
