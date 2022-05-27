import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:string_validator/string_validator.dart';
import '../../handlers/course_handler.dart';
import '../../handlers/sale_handler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../../model/book.dart';
import '../../model/sale.dart';
import '../widgets/fook_logo_appbar.dart';
import 'package:fook/handlers/book_handler.dart';

class SaleCreateNew extends StatefulWidget {
  SaleCreateNew({Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

class _SaleCreateNewState extends State<SaleCreateNew> {
  TextEditingController isbnController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController conditionController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  final items = [
    "1. Poor",
    "2. Fair",
    "3. Good",
    "4. Very good",
    "5. Fine",
    "6. As new"
  ];
  bool _isButtonEnabled = false;
  bool _fieldsEnabled = false;
  String? value;

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: FookAppBar(
          implyLeading: true,
        ),
        body: (SingleChildScrollView(
            child: ConstrainedBox(
          constraints: const BoxConstraints(),
          child: Column(children: [
            AppBar(
                automaticallyImplyLeading: false,
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
                  borderRadius: BorderRadius.circular(5),
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
                            children: [
                              SizedBox(height: 10),
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
                                        "ISBN should contain 10 or 13 characters",
                                        1);
                                    _disableFields();
                                  } else if ((newValue.length != 10 &&
                                          newValue.length != 13) &&
                                      !isNumeric(newValue)) {
                                    //ex. hjkhk
                                    toastMessage(
                                        "ISBN should contain 10 or 13 characters",
                                        1);
                                    _disableFields();
                                  } else if ((newValue.length == 10 ||
                                          newValue.length == 13) &&
                                      !isNumeric(newValue)) {
                                    toastMessage(
                                        "ISBN should only contain numbers", 1);
                                    _disableFields();
                                  } else {
                                    _fetchBook(newValue);
                                    setState(() {
                                      _fieldsEnabled = true;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  label: Text(
                                    "ISBN",
                                    style: (TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                                  ),
                                  fillColor: Color.fromARGB(255, 255, 255, 255),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).highlightColor,
                                        width: 2),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(/*Skanna streckkod och ruta*/
                              children: [
                            const Text("Scan barcode:",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            MaterialButton(
                              height: 50,
                              textColor:
                                  Theme.of(context).colorScheme.onSecondary,
                              color: Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () async {
                                String barcode =
                                    await FlutterBarcodeScanner.scanBarcode(
                                        "#ff6666",
                                        "Cancel",
                                        false,
                                        ScanMode.DEFAULT);
                                if (barcode != "-1") {
                                  setState(() {
                                    isbnController.text = barcode;
                                  });
                                  _fetchBook(barcode);
                                }
                              },
                              child: const Icon(
                                Elusive.barcode,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          ]),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            height: 55,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                  label: Text(
                                    "Title",
                                    style: TextStyle(
                                        color: _fieldsEnabled
                                            ? Colors.black
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  filled: true,
                                  fillColor:
                                      Color.fromARGB(255, 228, 227, 227)),
                              enabled: false,
                            )),
                        Container(
                          child: TextField(
                            controller: authorController,
                            decoration: InputDecoration(
                                label: Text(
                                  "Authors",
                                  style: TextStyle(
                                      color: _fieldsEnabled
                                          ? Colors.black
                                          : Colors.grey,
                                      fontWeight: FontWeight.w600),
                                ),
                                filled: true,
                                fillColor: Color.fromARGB(255, 228, 227, 227)),
                            enabled: false,
                          ),
                          height: 55,
                          margin: const EdgeInsets.only(bottom: 10),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                              height: 55,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: _fieldsEnabled
                                      ? null
                                      : Color.fromARGB(255, 228, 227, 227),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: _fieldsEnabled
                                          ? Theme.of(context).highlightColor
                                          : Color.fromARGB(
                                              255, 228, 227, 227))),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    hint: Text(
                                      "Condition",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    value: value,
                                    iconSize: 36,
                                    icon: _fieldsEnabled
                                        ? const Icon(Icons.arrow_drop_down,
                                            color: Colors.black)
                                        : null,
                                    isExpanded: true,
                                    items: _fieldsEnabled
                                        ? items.map(buildMenuItem).toList()
                                        : [],
                                    onChanged: (value) =>
                                        setState(() => this.value = value)),
                              )),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextField(
                            //pricecontroller ska kunna ändra
                            keyboardType: TextInputType.number,
                            controller: priceController,
                            decoration: InputDecoration(
                                label: Text(
                                  "Your price",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600),
                                ),
                                filled: !_fieldsEnabled,
                                fillColor: Color.fromARGB(255, 228, 227, 227)),
                            enabled: _fieldsEnabled,

                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextFormField(
                            controller: commentController,
                            decoration: InputDecoration(
                                label: Text(
                                  "Comments",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600),
                                ),
                                filled: !_fieldsEnabled,
                                fillColor: Color.fromARGB(255, 228, 227, 227)),
                            enabled: _fieldsEnabled,
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton.icon(
                              label: const Text('Publish'),
                              icon: const Icon(Icons.publish_rounded),
                              style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              onPressed: (() {
                                if (_isButtonEnabled) {
                                  createSale(
                                    isbnController.text,
                                    commentController.text,
                                    conditionController.text,
                                    int.parse(priceController.text),
                                    context,
                                  );
                                } else {
                                  toastMessage(
                                    "Enter valid ISBN number",
                                    2,
                                  );
                                }
                              }),
                            )),
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
        fontSize: 26.0);
  }

  _fetchBook(String newValue) async {
    //Kolla att ISBN finns
    var isIsbnInCourses = await CourseHandler.isIsbnInCourses(
        newValue, FirebaseFirestore.instance);
    if (isIsbnInCourses) {
      _isButtonEnabled = true;
      Book book = await BookHandler.getBook(newValue);
      setState(() {
        titleController.text = book.info.title;
        authorController.text = book.info.authors.toString();
      });
    } else {
      _disableFields();
      toastMessage(
          "ISBN don't match with any book in DSV's courses, therefore it can't be put up for sale in Fook.",
          2);
    }
  }

  _disableFields() {
    _isButtonEnabled = false;
    titleController.clear();
    authorController.clear();
    setState(() {
      _fieldsEnabled = false;
    });
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
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
        condition: value.toString(),
        saleID: (await SaleHandler.getSaleId(FirebaseFirestore.instance))
            .toString(),
        courses: await SaleHandler.getCoursesForIsbn(
            isbn, FirebaseFirestore.instance),
      ),
    );
    toastMessage(
      'Published',
      1,
    );
    Navigator.pop(context);
    return true;
  }
}
