import 'package:flutter/material.dart';

import '../widgets/fook_logo_appbar.dart';









class SaleCreateNew extends StatefulWidget {
  const SaleCreateNew({Key? key}) : super(key: key);

  @override
  State<SaleCreateNew> createState() => _SaleCreateNewState();
}

class _SaleCreateNewState extends State<SaleCreateNew> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: FookAppBar(),
      body: Column(children: [ //Övergripande strukturen
        AppBar(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))), title: const Text ("MY SALES", style: TextStyle(color: Colors.orange),),centerTitle: true,
          backgroundColor: Colors.white), 
        
        const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),
        
        Container( //Nedersta rektangeln (För att kunna färgfylla, skugga osv)
        padding: const EdgeInsets.all(15),
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
              
              children: [                
                Expanded(
                  child: Column(  /*ISBN och ruta*/
                    children: [
                      const Text("ISBN:", /*textAlign: TextAlign.left*/), 
                      
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
                      const Text("Scan QR-code:", textAlign: TextAlign.center), 
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
            
            
            
            
            const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),




            Column(/*Här ska Titel, Författar, väljsskick osv vara*/ 
            children: [
              //Titel:
              const Text("Title:", style: TextStyle(color: Colors.grey)), 
              
              Container(
                height:40,
                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 226, 229, 231),
                  boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                   offset: Offset(0.0, 5.0),
                  )
                ],
                  borderRadius: BorderRadius.circular(7)
                  ),),
              


              const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),



              //Författare:
              const Text("Author:", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), 
              Container(
                height:40,
                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 226, 229, 231),
                  boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                   offset: Offset(0.0, 5.0),
                  )
                ],
                  borderRadius: BorderRadius.circular(7)
                  ),),



                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),




              //Välj skick-ruta:
              //const Text("Author:", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), 
              Container(
                height:40,
                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 226, 229, 231),
                  boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 121, 121, 121),
                    blurRadius: 5.0,
                   offset: Offset(0.0, 5.0),
                  )
                ],
                  borderRadius: BorderRadius.circular(7)
                  ),
                  ),



                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),





              //Begärt pris:
              const Text("Your price:", textAlign: TextAlign.center), 



              const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),




              //Övriga kommentarer:
              const Text("Comments:", textAlign: TextAlign.center), 

            ],),
          ],
        ))
]),
      );
}
