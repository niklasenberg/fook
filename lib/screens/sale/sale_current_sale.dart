import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:string_validator/string_validator.dart';
import 'package:test/expect.dart';
import '../../handlers/course_handler.dart';
import '../../handlers/sale_handler.dart';

import '../../model/book.dart';
import '../../model/sale.dart';
import '../widgets/fook_logo_appbar.dart';
import 'package:fook/handlers/book_handler.dart';

class SaleCurrentSale extends StatefulWidget {
  //const SaleCurrentSale({Key? key}) : super(key: key);
  String thisisbn;
  late String title;
  late String authors;
  late int price;
  late String condition;
  late String comment;
  SaleCurrentSale({
    Key? key,
    required this.thisisbn,
    required this.title,
    required this.authors,
    required this.price,
    required this.condition,
    required this.comment,
  }) : super(key: key);

  @override
  State<SaleCurrentSale> createState() => _SaleCurrentSale();
}

class _SaleCurrentSale extends State<SaleCurrentSale> {
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
            AppBar(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                title: const Text(
                  "EDIT SALE",
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            /*ISBN och ruta*/
                            children: [
                              const Text("ISBN:", textAlign: TextAlign.left),
                              TextFormField(
                                initialValue: widget.thisisbn,
                                //controller: isbnController,
                                enableInteractiveSelection: false,
                                focusNode: new AlwaysDisabledFocusNode(),
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 228, 227, 227),
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
                              color: const Color.fromARGB(255, 228, 227, 227),
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
                            child: TextFormField(
                              initialValue: widget.title,
                              //controller: titleController,
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
                          child: TextFormField(
                            initialValue: widget.authors,
                            //controller: authorController,
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
                                    //Kolla vald condition och se till att den fortfarande kan ändras
                                    value: value,
                                    iconSize: 36,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.black),
                                    isExpanded: true,
                                    items: items.map(buildMenuItem).toList(),
                                    onChanged: (value) =>
                                        setState(() => this.value = value)),
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
                          child: TextFormField(
                            //pricecontroller ska kunna ändra
                            keyboardType: TextInputType.number,
                            initialValue: widget.price.toString(),
                            //controller: priceController,
                            //kan ej ha controller och initialvalue
                            decoration: const InputDecoration(
                                filled: false, fillColor: Colors.white),
                            enabled: true,

                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                            ],
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
                            //controller: commentController,
                            initialValue: widget.comment,
                            decoration: const InputDecoration(
                                filled: false, fillColor: Colors.white),
                            enabled: true,
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton.icon(
                            label: const Text('Delete'),
                            icon: const Icon(Icons.delete),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            onPressed: (() => _doSomething()),
                            //deletehandler
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton.icon(
                            label: const Text('Update'),
                            icon: const Icon(Icons.update),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.yellow,
                            ),
                            onPressed: (() => _doSomething()),
                            //updatehandler
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
    int sec,
  ) {
    Fluttertoast.showToast(
        msg: toastMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: sec,
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

  //update Sale handler

  //remove sale handler
  Future<bool> createSale(String isbn, String description, String condition,
      int price, BuildContext context) async {
    SaleHandler.addSale(
      FirebaseFirestore.instance,
      Sale(
        isbn: isbn,
        userID: FirebaseAuth.instance.currentUser!.uid,
        price: price,
        description: description,
        condition: value.toString(),
        saleID: (await SaleHandler.getSaleId(FirebaseFirestore.instance))
            .toString(),
        courses: await SaleHandler.getCoursesForIsbn(
            isbn, FirebaseFirestore.instance),
      ),
    );
    toastMessage('Published', 1);
    Navigator.pop(context);
    return true;
  }

  _doSomething() {
    //Placeholder
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
