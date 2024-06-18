// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:prototype_ss/views/search_page.dart';
import '../model/chatdata.dart';

final messages = [
    ChatData(username:"@fashionista42", message:"Nice!", date:"2024/4/12"),
    ChatData(username:"@vintage_vibes", message:"Great!", date:"2024/4/12"),
    ChatData(username:"@sneakerhead123", message:"I want to buy!", date:"2024/4/13"),
    ChatData(username:"@eco_wear", message:"Recommendations?", date:"2024/4/14"),
    ChatData(username:"@luxury_looks", message:"Thoughts?", date:"2024/4/14"),
    ChatData(username:"@streetwear_savvy", message:"LAny ideas?", date:"2024/4/15"),
    ChatData(username:"@diy_designs", message:"my first handmade skirt!", date:"2024/4/15")
];
class ChatPage extends StatelessWidget {

  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:Text(
                'Chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Abhaya Libre SemiBold',
                  fontWeight: FontWeight.w600,
                  height: 0.02,
                  letterSpacing: -0.41,
                ),
              ),
      ),
      body:
      Padding(
            padding:EdgeInsets.fromLTRB(20.0,10.0,20.0, 10.0),
            child:Column(
              children: [
                Divider(
                  height: 20,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.black,
                ),
                buildSearchBar(context, (fn) { }),
                
                Column(
                  children:messages.asMap().entries.map((entry){
                     final val = entry.value;
                     return ChatBar(username: val.username, message: val.message, date: val.date);
                   }
                  ).toList(),
                )

              ],
            ) ,
          )
      
    );
  }
}

class ChatBar extends StatelessWidget {
  final String username;
  final String message;
  final String date;
  const ChatBar({super.key,required this.username,required this.message,required this.date});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.0,),
        Column(
          children: [
            SizedBox(
              width: 333,
              height: 57,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 9,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: ShapeDecoration(
                        color: Color(0xFFD9D9D9),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 65,
                    top: 9,
                    child: Text(
                      username,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Abhaya Libre SemiBold',
                        fontWeight: FontWeight.w600,
                        height: 0.09,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 55,
                    top: 29,
                    child: SizedBox(
                      width: 146,
                      height: 17,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF513D3D),
                          fontSize: 13,
                          fontFamily: 'Abhaya Libre SemiBold',
                          fontWeight: FontWeight.w600,
                          height: 0.13,
                          letterSpacing: -0.41,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 263,
                    top: 9,
                    child: Text(
                      date,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Abhaya Libre SemiBold',
                        fontWeight: FontWeight.w600,
                        height: 0.09,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 59,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(30.0),
                      width: 374,
                      height: 57,
                      decoration: ShapeDecoration(
                        color: Colors.black.withOpacity(0.029999999329447746),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}