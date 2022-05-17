import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../handlers/sale_handler.dart';
import '../../model/book.dart';
import '../../model/sale.dart';
import '../widgets/fook_logo_appbar.dart';
import 'package:fook/handlers/book_handler.dart';

class SaleCurrentSale extends StatefulWidget {
  const SaleCurrentSale({Key? key}) : super(key: key);

  @override
  State<SaleCurrentSale> createState() => _SaleCurrentSale();
}

class _SaleCurrentSale extends State<SaleCurrentSale> {
  late String thisIsbn;
  late String thisAuthor;
  late String thisTitle;
  late String thisPrice;
  late String thisCondition;
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();

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
                  "CURRENT SALE",
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

                              /*TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty!';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              labelText: 'Password',
                            ),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                            controller: passwordCtrl) */

                              //ISBN textformfield handler
                              TextFormField(
                                onChanged: (String newValue) async {
                                  //kolla att numret är 10 eller 13 siffror långt och endast består av nummer

                                  Book book =
                                      await BookHandler.getBook(newValue);
                                  titleController.text =
                                      book.info.title + book.info.subtitle;
                                  authorController.text = book
                                      .info.authors[0]; //behöver alla authors
                                },
                                decoration: const InputDecoration(
                                  labelText: "hello",
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

                        //Gråa ut knappen så den försvinner och ej går o klicka på
                        //kanaske popupmeddelanden
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

                    //Titel handler
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
                              decoration: InputDecoration(
                                  filled: true, fillColor: Colors.grey),
                              enabled: false,
                            )),

                        //Författare:

                        //författare handler
                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Author',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        Container(
                          height: 55,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Color.fromARGB(255, 226, 229, 231),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                                offset: Offset(0.0, 5.0),
                              )
                            ],
                          ),
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
                            child: Container(
                              height: 40,
                              width: 130,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Color.fromARGB(255, 226, 229, 231),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 121, 121, 121),
                                    blurRadius: 5.0,
                                    offset: Offset(0.0, 5.0),
                                  )
                                ],
                              ),
                            )),

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
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            height: 37,
                            width: 90,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Color.fromARGB(255, 226, 229, 231),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(255, 121, 121, 121),
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 5.0),
                                )
                              ],
                            ),
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
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            height: 200,
                            width: 140,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Color.fromARGB(255, 226, 229, 231),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(255, 121, 121, 121),
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 5.0),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ]),
        ))),
      );

  Widget buildA(BuildContext context) {
    return FutureBuilder(
        future: SaleHandler.getSalesForUser(
            FirebaseAuth.instance.currentUser!.uid, FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Sale> sales = snapshot.data as List<Sale>;
            return Scaffold(
              body: Center(),
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
}
