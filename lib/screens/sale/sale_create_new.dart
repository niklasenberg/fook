import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:string_validator/string_validator.dart';
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
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController conditionController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: FookAppBar(
          implyLeading: true,
        ),
        body: (SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(),
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
                backgroundColor: Colors.white),

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
                              const Text(
                                "ISBN:", /*textAlign: TextAlign.left*/
                              ),
                              TextFormField(
                                //kollar nu enbart att den inte får vara längre än 13
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                onFieldSubmitted: (String newValue) async {
                                  //If not 10 or 13 do this
                                  //kolla att numret är 10 eller 13 siffror långt och endast består av nummer

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

                                    setState(() async {
                                      int inputPrice =
                                          priceController.text as int;
                                    });

                                    setState(() {
                                      var condition = conditionController;
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
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(
                                              255, 206, 204, 204),
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
                                  filled: false, fillColor: Colors.white),
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
                                filled: true, fillColor: Colors.white),
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
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextField(
                            //conditioncontroller, ska kunna ändra
                            controller: titleController,
                            decoration: const InputDecoration(
                                filled: false, fillColor: Colors.white),
                            enabled: true,
                          ),
                        ),

                        //Begärt pris:
                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Your price',
                            style: TextStyle(color: Colors.grey),
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
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextFormField(
                              //fixa textformfield här
                              ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton.icon(
                            label: const Text('Publish'),
                            icon: const Icon(Icons.publish),
                            onPressed: (() => _doSomething(

                                //create Sale object from the texteditingcontrollers
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

  _doSomething() {
    //Placeholder
  }
}
