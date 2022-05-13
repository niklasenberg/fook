import 'dart:html';

import 'package:flutter/material.dart';
import 'package:fook/handlers/sale_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fook/model/sale.dart';
import '../widgets/fook_logo_appbar.dart';
import 'package:fook/model/book.dart';

class SaleCreateNew extends StatefulWidget {
  const SaleCreateNew({Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

/*AppBar(shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: const Text("MY SALES", style: TextStyle(color: Colors.orange)),
          centerTitle: true,
          backgroundColor: Colors.white
            ) */
class _SaleCreateNewState extends State<SaleCreateNew> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: FookAppBar(),
        body: Column(children: [
          //Övergripande strukturen
          AppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              title: const Text(
                "MY SALES",
                style: TextStyle(color: Colors.orange),
              ),
              centerTitle: true,
              backgroundColor: Colors.white),

          const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),

          Container(
              //Nedersta rektangeln (För att kunna färgfylla, skugga osv)
              height: 400.0,
              width: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                    offset: Offset(0.0, 10.0),
                  )
                ],
              ),
              child: Column(
                //Nedersta rektangeln, fyller ut containern den är i men strukturerar så att allt är vertikalt
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  Row(
                    //Här ska isbn och skanna streckkod vara. BEhövs förmodligen två columns

                    children: [
                      Expanded(
                        child: Column(
                          /*ISBN och ruta*/
                          children: [
                            const Text(
                              "ISBN:", /*textAlign: TextAlign.left*/
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'FEL ISBN MANNEN!';
                                } else if (value.length != 10) {
                                  return 'Wrong number of characters, should be 10 numbers.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Inget här va?',
                              ),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              //controller: emailCtrl
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(/*Skanna streckkod och ruta*/
                            children: [
                          const Text("Scan QR-code:",
                              textAlign: TextAlign.center),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            onPressed: () {},
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            color: Theme.of(context).colorScheme.secondary,
                          )
                        ]),
                      ),
                    ],
                  ),
                  Column(
                    /*Här ska Titel, Författar, väljsskick osv vara*/
                    children: const [
                      //Titel:
                      Text("Title: ", textAlign: TextAlign.center),

                      //Författare:
                      Text("Author:", textAlign: TextAlign.center),

                      //Välj skick-ruta:
                      Text("Condition:", textAlign: TextAlign.center),

                      //Begärt pris:
                      Text("Your price:", textAlign: TextAlign.center),

                      //Övriga kommentarer:
                      Text("Comments:", textAlign: TextAlign.center),
                    ],
                  ),
                ],
              ))
        ]),
      );

  //om det är en sale ska den fylla i rutorna automatiskt, och vissa rutor går ej att ändra, andra rutor går att ändra

  //om det inte är en sale ska den fylla i rutorna och skapa nytt sale objekt

  //metod som kollar om det är en sale

  //Skriv ISBN metod som hämtar titel och författare

  //metod som visar hur alltig in lustreras

  //handler för uppdatera knappen

  //handler för tabort knappen

  //QR-handler

}
