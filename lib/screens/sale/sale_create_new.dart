import 'package:flutter/material.dart';

import '../fook_logo_appbar.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class SaleCreateNew extends StatefulWidget {
  const SaleCreateNew({Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

class _SaleCreateNewState extends State<SaleCreateNew> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: FookAppBar(),
      body: Column(children: [
        Container(
            child: Text("SKAPA ANNONS", style: TextStyle(color: Colors.orange)),
            decoration:
                BoxDecoration(shape: BoxShape.rectangle, color: Colors.blue)),
        Container()
      ])

      /*AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title:  Text("SKAPA ANNONS", style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          bottom: PreferredSize(
                  child: Container(padding: const EdgeInsets.fromLTRB(18, 0, 0, 5),
                    alignment: Alignment.centerLeft,
                    child: const Text("Titel och författare hämtas automatiskt via ISBN-numret",
                    style: TextStyle(color: Colors.black),),
                  ),
                  preferredSize: const Size.fromHeight(1),
                ),
          backgroundColor: Colors.white)*/

      );
}
