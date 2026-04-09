import 'package:flutter/material.dart';





class Welcomepageone extends StatelessWidget {
  const Welcomepageone({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
         
        
     
        Container(
         child: Column(
          children: [
            Image.asset("assets/images/Planning.png"),
           
            
            SizedBox(height:18 ,),
            Text("Organise tes journées",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor, 
               fontSize: 28,
               fontWeight: FontWeight.bold,
               fontFamily: "Poppins-Bold"
               
            ),),
     
            Text("Planifie, découvre et profite de ton temps facilement",
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
