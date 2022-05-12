import 'package:flutter/material.dart';

import '../fook_logo_appbar.dart';

class SaleCreateNew extends StatefulWidget {
  const SaleCreateNew({Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

class _SaleCreateNewState extends State<SaleCreateNew> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: FookAppBar(),
      body: Column(children: [  //Övergripande strukturen
        
        Container(    //Översta rektangeln (Gamla "appBaren")
          height: 100.0,
          width: double.infinity,
          child: Center(child: const Text("CREATE SALE", textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orange))),  
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              )
            ],
          ),
        ),

        Container( //Nedersta rektangeln (För att kunna färgfylla, skugga osv)
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
          child: Column(  //Nedersta rektangeln, fyller ut containern den är i men strukturerar så att allt är vertikalt
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          




          children: [
            Row(   //Här ska isbn och skanna streckkod vara. BEhövs förmodligen två columns   
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(  /*ISBN och ruta*/
                    children: [
                      const Text("ISBN:", textAlign: TextAlign.left), 
                      
                      TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'FEL ISBN MANNEN!';
                              } else if (value.length != 10 ) {
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
                  child: 
                  Column(/*Skanna streckkod och ruta*/
                  children: [
                      const Text("Skanna streckkod:", textAlign: TextAlign.center), 
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)
                        ),
                        onPressed: () {},
                        child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20,),
                        textColor: Theme.of(context).colorScheme.onSecondary,
                        color: Theme.of(context).colorScheme.secondary,
                    )
                  ]
                  ),
                ),
              ],
            ), 

            Column(/*Här ska Titel, Författar, väljsskick osv vara*/ 
            children: [
              //Titel
              //Ruta
              //Författare
              //Ruta
              //Välj skick-ruta
              //Begärt pris
              //Ruta
              //Övriga kommentarer
              //Ruta
            ],),
          ],
        ))
])

      
  

      );
}
