import 'package:flutter/material.dart';
import 'package:gotime/pages/descriptionPages/welcomePageone.dart';
import 'package:gotime/pages/descriptionPages/welcomepagethree.dart';
import 'package:gotime/pages/descriptionPages/welcomepagetwo.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:gotime/pages/login/loginpage.dart';



class Homepage extends StatelessWidget {
  
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal:12 ),
          child: Column(
            children: [
              Row(
                   
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _controller.previousPage(duration: Duration(microseconds:400 ),
                           curve: Curves.easeInOut);
                        },
                        child: Icon(Icons.chevron_left,size: 40,)),
                       GestureDetector(
                        onTap: () {
                          _controller.nextPage(duration: Duration(microseconds:400 ),
                           curve: Curves.easeInOut);
                        },
                        child: Text("Suivant",
                        style: TextStyle(
                          fontSize: 38 
                        
                        ),
                        
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 60,),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              
              children: [
                
                SizedBox(
                  height: 500,
                  child: PageView(
                    controller: _controller ,
                     children: [
                    Welcomepageone(),
                    Welcomepagetwo(),
                    Welcomepagethree()
                  ],
                  ),
                ),
              
                SmoothPageIndicator(controller: _controller, count: 3, ),
                SizedBox(height: 160,),


                Row(
                  
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    
                    GestureDetector(
  onTap: () async {
    if (_controller.page?.round() == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Loginpage(),
        ),
      );
    } else {
      _controller.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  },
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).primaryColor,
    ),
    child: Icon(Icons.chevron_right, color: Colors.white, size: 40),
  ),
),
                  ],
                )
              ],
              ),
            ],
          ),
        ),
      ) ,
    );
  }
}