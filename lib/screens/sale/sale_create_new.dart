import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fook/screens/widgets/rounded_app_bar.dart';
import 'package:string_validator/string_validator.dart';
import '../../handlers/course_handler.dart';
import '../../handlers/sale_handler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../../model/book.dart';
import '../../model/sale.dart';
import '../../utils.dart';
import '../widgets/fook_logo_appbar.dart';
import 'package:fook/handlers/book_handler.dart';

class SaleCreateNew extends StatefulWidget {
  const SaleCreateNew({Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

///Page for creating new Sale objects
class _SaleCreateNewState extends State<SaleCreateNew> {
  //Controllers
  TextEditingController isbnController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController conditionController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  //Input validation
  bool _isButtonEnabled = false;
  bool _fieldsEnabled = false;
  String? value;

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const FookAppBar(
        implyLeading: true,
      ),
      body: _createSaleForm());

  ///Sale form containing input validation
  ///logic and fetching of book information
  Widget _createSaleForm() {
    return SingleChildScrollView(
      child: Column(children: [
        RoundedAppBar("CREATE SALE", Theme.of(context).highlightColor, ""),
        Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.74,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2,
                  spreadRadius: 0.5,
                ),
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
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: isbnController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            onFieldSubmitted: (String newValue) async {
                              isbnController.text = newValue;
                              if ((newValue.length != 10 &&
                                      newValue.length != 13) &&
                                  isNumeric(newValue)) {
                                Utility.toastMessage(
                                    "ISBN should contain 10 or 13 characters",
                                    1,
                                    Colors.red);
                                _disableFields();
                              } else if ((newValue.length != 10 &&
                                      newValue.length != 13) &&
                                  !isNumeric(newValue)) {
                                Utility.toastMessage(
                                    "ISBN should contain 10 or 13 characters",
                                    1,
                                    Colors.red);
                                _disableFields();
                              } else if ((newValue.length == 10 ||
                                      newValue.length == 13) &&
                                  !isNumeric(newValue)) {
                                Utility.toastMessage(
                                    "ISBN should only contain numbers",
                                    1,
                                    Colors.red);
                                _disableFields();
                              } else {
                                _fetchBook(newValue);
                                setState(() {
                                  _fieldsEnabled = true;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              label: const Text(
                                "ISBN",
                                style: (TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                              ),
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
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
                          textColor: Theme.of(context).colorScheme.onSecondary,
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
                    const SizedBox(
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
                                  const Color.fromARGB(255, 228, 227, 227)),
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
                            fillColor:
                                const Color.fromARGB(255, 228, 227, 227)),
                        enabled: false,
                      ),
                      height: 55,
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: _fieldsEnabled
                                  ? null
                                  : const Color.fromARGB(255, 228, 227, 227),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: _fieldsEnabled
                                      ? Theme.of(context).highlightColor
                                      : const Color.fromARGB(
                                          255, 228, 227, 227))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                hint: const Text(
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
                                    ? Utility.items
                                        .map((item) => DropdownMenuItem(
                                            value: item, child: Text(item)))
                                        .toList()
                                    : [],
                                onChanged: (value) =>
                                    setState(() => this.value = value)),
                          )),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextField(
                        //pricecontroller ska kunna ändra
                        keyboardType: TextInputType.number,
                        controller: priceController,
                        decoration: InputDecoration(
                            label: const Text(
                              "Your price",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600),
                            ),
                            filled: !_fieldsEnabled,
                            fillColor:
                                const Color.fromARGB(255, 228, 227, 227)),
                        enabled: _fieldsEnabled,

                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextFormField(
                        controller: commentController,
                        decoration: InputDecoration(
                            label: const Text(
                              "Comments",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600),
                            ),
                            filled: !_fieldsEnabled,
                            fillColor:
                                const Color.fromARGB(255, 228, 227, 227)),
                        enabled: _fieldsEnabled,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _publishButton()
                  ],
                ),
              ],
            )),
      ]),
    );
  }

  ///Button for publishing Sale object
  ///Governed by input validation
  Widget _publishButton() {
    return Align(
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
              _createSale(
                isbnController.text,
                commentController.text,
                conditionController.text,
                int.parse(priceController.text),
                context,
              );
            } else {
              Utility.toastMessage("Enter valid ISBN number", 1, Colors.red);
            }
          }),
        ));
  }

  ///Helper method to fetch book information (Title and Authors)
  _fetchBook(String newValue) async {
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
      Utility.toastMessage(
          "ISBN don't match with any book in DSV's courses, therefore it can't be put up for sale in Fook.",
          2,
          Colors.red);
    }
  }

  ///Helper method for input validation
  _disableFields() {
    _isButtonEnabled = false;
    titleController.clear();
    authorController.clear();
    setState(() {
      _fieldsEnabled = false;
    });
  }

  ///Helper method for creating the sale and popping to sale_home_page
  _createSale(String isbn, String description, String condition, int price,
      BuildContext context) async {
    SaleHandler.addSale(
      Sale(
        isbn: isbn,
        userID: FirebaseAuth.instance.currentUser!.uid,
        price: price,
        description: description,
        condition: value.toString(),
        saleID: (await SaleHandler.getSaleId(FirebaseFirestore.instance))
            .toString(),
        courses: await CourseHandler.getCoursesForIsbn(
            isbn, FirebaseFirestore.instance),
      ),
      FirebaseFirestore.instance,
    );

    Utility.toastMessage('Published', 1, Colors.green);

    Navigator.pop(context);
  }
}
