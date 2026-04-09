import 'package:flutter/material.dart';



    class Welcomepagetwo extends StatelessWidget {
  const Welcomepagetwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
         
        
     
        Container(
         child: Column(
          children: [
            Image.asset("assets/images/temps.png",),
            
            
            SizedBox(height:18 ,),
            Text("Découvre quoi faire",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor, 
               fontSize: 28,
               fontWeight: FontWeight.bold,
               fontFamily: "Poppins-Bold"
               
            ),),
     
            Text("Trouve des activités autour de toi en quelques secondes",
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