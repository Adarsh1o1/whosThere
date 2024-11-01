// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_app/login.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import 'dart:convert';
// // ignore: camel_case_types
// class homepage extends StatefulWidget {
//
//   @override
//   _homepageState createState() => _homepageState();
// }
//
// class _homepageState extends State<homepage> {
//   bool isloggedin = false;
//   @override
//   void initState() {
//     super.initState();
//     checkLoggedIn();  // Check login status when the widget is initialized
//   }
//
//   Future<void> checkLoggedIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var token = prefs.getString("token");
//     // String? token = await storage.read(key: 'auth_token');
//     setState(() {
//       isloggedin = token != null;  // Set the login status based on token
//     });
//
//     // Set the navigation bar color
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       systemNavigationBarColor: Color(0xFFD2E2E2), // Set your custom color here
//       systemNavigationBarIconBrightness:
//           Brightness.light, // Set icon color (light/dark)
//     ));
//   }
//
//   Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove("token"); // Remove the token
//     setState(() {
//       isloggedin = false; // Update UI
//     });
//
//     Fluttertoast.showToast(
//       msg: "Logout Success",
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.redAccent,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//
//     // Navigate back to login screen after logout
//     // Navigator.pushReplacement(
//     //   context,
//     //   MaterialPageRoute(builder: (context) => LoginPage()),
//     // );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFD2E2E2),
//       appBar: appBar(),
//       body: Column(
//         children: [
//           Container(
//             margin: EdgeInsets.only(top: 10, left: 20, right: 20),
//             decoration: BoxDecoration(boxShadow: [
//               BoxShadow(
//                 color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.11),
//                 blurRadius: 40,
//                 spreadRadius: 0.0,
//               )
//             ]),
//             child: TextField(
//               decoration: InputDecoration(
//                   hintText: "Search",
//                   hintStyle: const TextStyle(
//                     color: Color(0xffD2E2E2),
//                   ),
//                   filled: true,
//                   fillColor: Color(0xFF3f7c88),
//                   contentPadding: EdgeInsets.all(15),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: BorderSide.none,
//                   )),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   AppBar appBar() {
//     // bool isloggedin = false;
//     // print(isloggedin);
//     // Future<void> isLoggedIn() async {
//     //   String? token = await storage.read(key: 'auth_token');
//     //   if (token != null) {
//     //     isloggedin = true;  // Token exists, user is logged in
//     //   } else {
//     //     isloggedin = false; // Token is null, user is not logged in
//     //   }
//     // }
//     // isLoggedIn();
//     return AppBar(
//       title: const Text(
//         "Chats",
//         style: TextStyle(
//           color: Color(0xff3F7C88),
//           fontSize: 25,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: Color(0xFFD2E2E2),
//       elevation: 0.0,
//       actions: [
//         GestureDetector(
//           onTap: () {
//       if (isloggedin) {
//         logout(); // Call logout function when user taps the button
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage()),
//         );
//       }
//           },
//
//           child: Container(
//             margin: const EdgeInsets.all(10),
//             // padding: const EdgeInsets.only(right: 5, left: 5),
//             alignment: Alignment.center,
//             width: 35,
//             decoration: BoxDecoration(
//                 color: Color(0xFFedf3f5),
//                 borderRadius: BorderRadius.circular(10)),
//             // if not logged in then is code
//             child: isloggedin
//                 ? SvgPicture.asset(
//                     "assets/icons/logout-svgrepo-com.svg",
//                     height: 20,
//                     width: 20,
//                   )
//
//                 // else this code
//                 : SvgPicture.asset(
//                     "assets/icons/login-svgrepo-com.svg",
//                     height: 20,
//                     width: 20,
//
//                   ),
//           ),
//         ),
//       ],
//
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_app/login.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import 'dart:convert';
//
// class homepage extends StatefulWidget {
//   @override
//   _homepageState createState() => _homepageState();
// }
//
// class _homepageState extends State<homepage> {
//   bool isloggedin = false;
//   SharedPreferences? prefs;
//   int? myId;
//   late WebSocketChannel channel;
//   List<Map<String, String>> chatData = [];
//
//   Future<void> _loadPreferences() async {
//     prefs = await SharedPreferences.getInstance();
//     setState(() {
//       myId = prefs?.getInt('myUserId');
//       print("my id is : $myId"); // Fetch myId from SharedPreferences
//     });
//     channel = WebSocketChannel.connect(
//       Uri.parse(
//           'ws://loved-seemingly-cod.ngrok-free.app/ws/recent/$myId/'), // Replace with your WebSocket URL
//     );
//     print("Connected to WebSocket with ID: $myId");
//     channel.stream.listen((message) {
//       final newMessage = jsonDecode(message);
//       print(newMessage);
//
//       Map<String, dynamic> decodedResponse = json.decode(message);
//       List<dynamic> recentChats = decodedResponse['recent_chats'];
//
//       setState(() {
//         // Clear existing chat data before updating with new data
//         chatData.clear();
//
//         // Loop through each recent chat and add it to chatData
//         for (var chat in recentChats) {
//           chatData.add({
//             'name': chat['name'],
//             'message': chat["last_message"]?.toString() ?? '',
//             'time': chat["last_updated"]?.toString() ?? '',
//             'online_status': chat['online_status']?.toString() ?? "",
//             'avatarUrl': chat["image"]
//           });
//         }
//       });
//     });
//     @override
//     void dispose() {
//       channel.sink.close(status
//           .goingAway); // Close the WebSocket connection when the widget is disposed
//       super.dispose();
//     }
//   }
//
//   Future<void> checkLoggedIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var token = prefs.getString("token");
//     // String? token = await storage.read(key: 'auth_token');
//     setState(() {
//       isloggedin = token != null; // Set the login status based on token
//     });
//
//     // Set the navigation bar color
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       systemNavigationBarColor: Color(0xFFD2E2E2), // Set your custom color here
//       systemNavigationBarIconBrightness:
//       Brightness.light, // Set icon color (light/dark)
//     ));
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//     checkLoggedIn();
//   }
//
//   Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove("token"); // Remove the token
//     setState(() {
//       isloggedin = false; // Update UI
//     });
//
//     Fluttertoast.showToast(
//       msg: "Logout Success",
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.redAccent,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//
//     // Navigate back to login screen after logout
//     // Navigator.pushReplacement(
//     //   context,
//     //   MaterialPageRoute(builder: (context) => LoginPage()),
//     // );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFD2E2E2),
//       appBar: appBar(),
//       body: Column(
//         children: [
//           // Search TextField
//           Container(
//             margin: EdgeInsets.only(top: 10, left: 20, right: 20),
//             decoration: BoxDecoration(
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.11),
//                   blurRadius: 40,
//                   spreadRadius: 0.0,
//                 ),
//               ],
//             ),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Don't search(abhi banaya nahi h🗿)",
//                 hintStyle: const TextStyle(
//                   color: Color(0xffD2E2E2),
//                 ),
//                 filled: true,
//                 fillColor: Color(0xFF3f7c88),
//                 contentPadding: EdgeInsets.all(15),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//           // Expanded widget to allow ListView to take up remaining space
//           Expanded(
//             child: ListView.builder(
//               itemCount: chatData.length,
//               itemBuilder: (context, index) {
//                 final chat = chatData[index];
//                 return ChatTile(
//                   name: chat["name"]!,
//                   message: chat["message"]!,
//                   time: chat["time"]!,
//                   online_status: chat["online_status"] == "true",
//                   avatarUrl: chat["avatarUrl"]!,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   AppBar appBar() {
//     return AppBar(
//       title: const Text(
//         "Chats",
//         style: TextStyle(
//           color: Color(0xff3F7C88),
//           fontSize: 25,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: Color(0xFFD2E2E2),
//       elevation: 0.0,
//       actions: [
//         GestureDetector(
//           onTap: () {
//             if (isloggedin) {
//               logout();
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginPage()),
//                     (Route<dynamic> route) => false,
//               );
//             } else {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginPage()),
//               );
//             }
//           },
//           child: Container(
//             margin: const EdgeInsets.all(10),
//             // padding: const EdgeInsets.only(right: 5, left: 5),
//             alignment: Alignment.center,
//             width: 35,
//             decoration: BoxDecoration(
//                 color: Color(0xFFedf3f5),
//                 borderRadius: BorderRadius.circular(10)),
//             // if not logged in then is code
//             child: isloggedin
//                 ? SvgPicture.asset(
//               "assets/icons/logout-svgrepo-com.svg",
//               height: 20,
//               width: 20,
//             )
//
//             // else this code
//                 : SvgPicture.asset(
//               "assets/icons/login-svgrepo-com.svg",
//               height: 20,
//               width: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class ChatTile extends StatelessWidget {
//   final String name;
//   final String message;
//   final String time;
//   final String avatarUrl;
//   final bool online_status;
//
//   ChatTile({
//     required this.online_status,
//     required this.name,
//     required this.message,
//     required this.time,
//     required this.avatarUrl,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Stack(
//         children: [
//           CircleAvatar(
//             radius: 30.0, // Adjust size of avatar
//             backgroundImage: NetworkImage(avatarUrl),
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: Container(
//               width: 12.0, // Size of the status dot
//               height: 12.0,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: online_status
//                     ? Colors.green
//                     : Colors.grey, // Green if online, grey if offline
//                 border: Border.all(
//                   color: Colors
//                       .white, // White border around the dot for better visibility
//                   width: 2.0,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       title: Text(name),
//       subtitle: Text(message),
//       trailing: Text(time, style: TextStyle(color: Colors.black)),
//       onTap: () {
//         // Navigate to chat screen or handle the tap event
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class Chat extends StatefulWidget {
  // Your existing code...

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, String>> messages = [];
  // Your existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2E2E2),
      appBar: AppBar(
        backgroundColor: Color(0xFFD2E2E2),
        title: Text("Chat"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                reverse: true, // Start from the bottom
                itemBuilder: (context, index) {
                  bool isCurrentUser = messages[index]['username'] != widget.username;

                  String formattedDate = messages[index]['date']!;
                  DateTime messageDate = DateFormat("yyyy-MM-dd").parse(formattedDate);
                  String? previousMessageDate;
                  if (index < messages.length - 1) {
                    previousMessageDate = messages[index + 1]['date'];
                  }
                  bool showDateSeparator = previousMessageDate != null && previousMessageDate != formattedDate;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display date separator if needed
                      if (showDateSeparator)
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            DateFormat('MMMM dd, yyyy').format(messageDate), // Date format for the separator
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                      Container(
                        margin: isCurrentUser ? EdgeInsets.only(left: 50) : EdgeInsets.only(right: 50),
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                  color: isCurrentUser ? Colors.white : Color(0xFF3f7c88),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  messages[index]['message'] ?? '',
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.black87 : Color(0xFFd2e2e2),
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              SizedBox(height: 3), // Add some spacing between message and timestamp
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
