import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:string_validator/string_validator.dart';
import 'package:test/expect.dart';
import '../../handlers/sale_handler.dart';

import '../../model/book.dart';
import '../../model/sale.dart';
import '../widgets/fook_logo_appbar.dart';
import 'package:fook/handlers/book_handler.dart';

class SaleCreateNew extends StatefulWidget {
  const SaleCreateNew({Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

class _SaleCreateNewState extends State<SaleCreateNew> {
  TextEditingController isbnController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();

  final items = ["Bad", "OK", "Good", "Like new"];
  String? value;

  TextEditingController priceController = TextEditingController();
  TextEditingController conditionController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: FookAppBar(
          implyLeading: true,
        ),
        body: (SingleChildScrollView(
            child: ConstrainedBox(
          constraints: const BoxConstraints(),
          child: Column(children: [
            //Övergripande strukturen

            AppBar(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                title: const Text(
                  "CREATE SALE",
                  style: TextStyle(color: Colors.orange),
                ),
                backgroundColor: Color.fromARGB(255, 255, 255, 255)),

            Container(
                //Nedersta rektangeln (För att kunna färgfylla, skugga osv)
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 30, bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(
                      width: 1, color: Color.fromARGB(255, 223, 219, 219)),
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
                              const Text("ISBN:", textAlign: TextAlign.left),
                              TextFormField(
                                controller: isbnController,
                                //Sätter max inmatning av karaktärer till 13
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                onFieldSubmitted: (String newValue) async {
                                  isbnController.text = newValue;
                                  if ((newValue.length != 10 &&
                                          newValue.length != 13) &&
                                      isNumeric(newValue)) {
                                    // ex. 5677
                                    toastMessage(
                                        "ISBN should contain 10 or 13 characters");
                                  } else if ((newValue.length != 10 &&
                                          newValue.length != 13) &&
                                      !isNumeric(newValue)) {
                                    //ex. hjkhk
                                    toastMessage(
                                        "ISBN should contain 10 or 13 characters");
                                    toastMessage(
                                        "ISBN should only contain numbers");
                                  } else if ((newValue.length == 10 ||
                                          newValue.length == 13) &&
                                      !isNumeric(newValue)) {
                                    toastMessage(
                                        "ISBN should only contain numbers");
                                  } else {
                                    //Kolla att ISBN finns
                                    setState(() async {
                                      Book book =
                                          await BookHandler.getBook(newValue);
                                      titleController.text = book.info.title;
                                      authorController.text = book.info
                                          .authors[0]; //behöver alla authors
                                    });
                                  }

                                  /* setState(() async{


                                    setState(() async {
                                      /* Sale sale = await SaleHandler.getSaleId(
                                          FirebaseFirestore.instance);*/

                                      List<Sale> sale =
                                          await SaleHandler.getSalesForUser(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              FirebaseFirestore.instance);

                                      for (Sale s in sale) {
                                        if (s.getPrice() != 0) {
                                          priceController.text =
                                              s.getPrice().toString();
                                        }
                                      }

                                      /*  priceController.text =
                                          sale.getPrice().toString();*/
                                    });
                                  

                                HÄMTA OCH SETTA pris, condition, kommentar                                      
                                
                                  Sale sale = await SaleHandler.getSaleId(firestore)
                                });*/
                                },
                                decoration: const InputDecoration(
                                  labelText: 'xxxxxxxxxx',
                                  fillColor: Color.fromARGB(255, 255, 255, 255),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 10, 10, 10),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(255, 10, 10, 10),
                                          width: 2),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
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
                              height: 50,
                              textColor:
                                  Theme.of(context).colorScheme.onSecondary,
                              color: Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () {},
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          ]),
                        ),
                      ],
                    ),
                    Column(
                      /*Här ska Titel, Författar, väljsskick osv vara*/

                      children: [
                        //Titel:

                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Title',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        Container(
                            height: 55,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Color.fromARGB(255, 228, 227, 227)),
                              enabled: false,
                            )),

                        //Författare:
                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Author',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        Container(
                          child: TextField(
                            controller: authorController,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 228, 227, 227)),
                            enabled: false,
                          ),
                          height: 55,
                          margin: const EdgeInsets.only(bottom: 10),
                        ),

                        //Välj skick-ruta:
                        //const Text("Author:", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Condition',
                            style: TextStyle(
                                color: Color.fromARGB(255, 12, 12, 12)),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                              width: 200,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.black, width: 1)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    value: value,
                                    iconSize: 36,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.black),
                                    isExpanded: true,
                                    items: items.map(buildMenuItem).toList(),
                                    onChanged: (value) => setState(() =>
                                        conditionController.text = value!)),
                              )),
                        ),

                        //Begärt pris:
                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Your price',
                            style: TextStyle(
                                color: Color.fromARGB(255, 10, 10, 10)),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextField(
                            //pricecontroller ska kunna ändra
                            controller: priceController,
                            decoration: const InputDecoration(
                                filled: false, fillColor: Colors.white),
                            enabled: true,
                          ),
                        ),

                        //Övriga kommentarer:
                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Comments',
                            style:
                                TextStyle(color: Color.fromARGB(255, 8, 8, 8)),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextFormField(
                            controller: commentController,
                            decoration: const InputDecoration(
                                filled: false, fillColor: Colors.white),
                            enabled: true,
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton.icon(
                            label: const Text('Publish'),
                            icon: const Icon(Icons.publish),
                            onPressed: (() => createSale(
                                  isbnController.text,
                                  commentController.text,
                                  conditionController.text,
                                  int.parse(priceController.text),
                                  context,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ]),
        ))),
      );

  toastMessage(
    String toastMessage,
  ) {
    Fluttertoast.showToast(
        msg: toastMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));

  Future<bool> createSale(String isbn, String description, String condition,
      int price, BuildContext context) async {
    SaleHandler.addSale(
      FirebaseFirestore.instance,
      Sale(
        isbn: isbn,
        userID: FirebaseAuth.instance.currentUser!.uid,
        price: price,
        description: description,
        condition: condition,
        saleID: (await SaleHandler.getSaleId(FirebaseFirestore.instance))
            .toString(),
        courses: await SaleHandler.getCoursesForIsbn(
            isbn, FirebaseFirestore.instance),
      ),
    );
    toastMessage('Published');
    Navigator.pop(context);

    return true;
  }

  /*

 
  */

}
