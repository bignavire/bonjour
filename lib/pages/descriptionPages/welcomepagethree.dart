import 'package:flutter/material.dart';

class Welcomepagethree extends StatelessWidget {
  const Welcomepagethree({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          
        
     
        Container(
         child: Column(
          children: [
            Image.asset("assets/images/vector.png",),
           
            
            SizedBox(height:18 ,),
            Text("C’est parti !",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor, 
               fontSize: 28,
               fontWeight: FontWeight.bold,
               fontFamily: "Poppins-Bold"
               
            ),),
     
            Text("Ton temps, tes choix, ton rythme",
            textAlign: TextAlign.center,
            style:TextStyle(
              fontFamily: "Poppins-Bold"
            ) ,)
              
            
          ],
         ), 
        )
        ],
      ),
     
      );

  }
}