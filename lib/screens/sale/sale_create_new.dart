import 'package:flutter/material.dart';

import '../widgets/fook_logo_appbar.dart';

class SaleCreateNew extends StatefulWidget {
  const SaleCreateNew( {Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

class _SaleCreateNewState extends State<SaleCreateNew> {
  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset : false,
    
        appBar: FookAppBar(),
        body: (SingleChildScrollView(
           child: ConstrainedBox(constraints: BoxConstraints(),
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
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30, bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(width: 1, color: Color.fromARGB(255, 223, 219, 219)),

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


                              TextFormField(   
                                decoration: const InputDecoration(
                                  labelText: 'xxxxxxxxxx',
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 206, 204, 204), width: 2),
                                    borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
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

                        const Align(alignment: Alignment.bottomLeft,
                          child: Text(
                          'Title',
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
                              ],),
                        ),

                        //Författare:
                         const Align(alignment: Alignment.bottomLeft,
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
                         const Align(alignment: Alignment.bottomLeft,
                          child: Text(
                          'Condition',
                          style: TextStyle(color: Colors.grey),
                        ),
                        ),
                        
                        Align(alignment: Alignment.bottomLeft, child:  
                        Container(
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
                              ),)),
                          
                         

                        //Begärt pris:
                        const Align(alignment: Alignment.bottomLeft,
                          child: Text(
                          'Your price',
                          style: TextStyle(color: Colors.grey),
                        ),
                        ),
                            
                          Align(alignment: Alignment.bottomLeft, child:  
                          Container(
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
                        ),),


                        //Övriga kommentarer:
                        const Align(alignment: Alignment.bottomLeft,
                          child: Text(
                          'Comments',
                          style: TextStyle(color: Colors.grey),
                        ),
                        ),
                        
                        
                        Align(alignment: Alignment.bottomLeft, child:
                        Container(
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
                        ),),
                      ],
                    ),
                  ],
                )),
          ]),
        ))),
      );

      
}
