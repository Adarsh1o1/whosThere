import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/chat.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  bool isloggedin = false;
  SharedPreferences? prefs;
  int? myId;
  String? username;
  WebSocketChannel? channel;
  List<Map<String, String>> chatData = [];
  bool isLoading = true;
  bool connectionError = false;
  bool showUsername = false; // Added for toggling title
  bool showSearchResults = false;
  bool showRecentChats = true;

  Future<void> _searchUsers(String query) async {
    final url = Uri.parse(
        "https://loved-seemingly-cod.ngrok-free.app/api/accounts/search/?q=$query");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // print(response.body);
      setState(() {
        var result = jsonDecode(response.body);
        print(result);
        _searchResults = result[0];
      });
      print(_searchResults);
    } else {
      print(response.body);
    }
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      myId = prefs?.getInt('myUserId');
      username = prefs?.getString('myUsername');
    });

    try {
      // Attempt to establish WebSocket connection
      channel = WebSocketChannel.connect(
        Uri.parse('ws://loved-seemingly-cod.ngrok-free.app/ws/recent/$myId/'),
      );

      // Set timeout for WebSocket connection
      Future.delayed(Duration(seconds: 30), () {
        if (isLoading) {
          setState(() {
            connectionError = true;
            isLoading = false; // Stop loading if connection fails
            Fluttertoast.showToast(
              msg: "connection timed out!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.white,
              textColor: Colors.redAccent,
              fontSize: 16.0,
            );
          });
        }
      });

      // Listen to WebSocket messages
      channel!.stream.listen((message) {
        final newMessage = jsonDecode(message);
        // print(newMessage);

        Map<String, dynamic> decodedResponse = json.decode(message);
        List<dynamic> recentChats = decodedResponse['recent_chats'];

        setState(() {
          // Clear existing chat data before updating with new data
          chatData.clear();

          // Loop through each recent chat and add it to chatData
          for (var chat in recentChats) {
            chatData.add({
              'name': chat['name'],
              'message': chat["last_message"]?.toString() ?? '',
              'time': chat["last_updated"]?.toString() ?? '',
              'online_status': chat['online_status']?.toString() ?? 'false',
              'avatarUrl': chat["image"],
              'userId': chat["userid"]?.toString() ?? '',
              'username': chat["username"]?.toString() ?? '',
            });
          }
          isLoading = false; // Set loading to false when data is received
        });
      });
    } catch (e) {
      // Handle WebSocket connection errors
      // print("WebSocket connection failed: $e");
      setState(() {
        connectionError = true;
        isLoading = false; // Stop loading if connection fails
      });
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _loadPreferences();
    checkLoggedIn();

    Timer.periodic(Duration(seconds: 60), (timer) {
      setState(() {
        showUsername = !showUsername; // Toggle the flag
      });
    });
  }

  @override
  void dispose() {
    channel!.sink.close(
        status.goingAway); // Close WebSocket connection when widget is disposed
    super.dispose();
  }

  Future<void> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    setState(() {
      isloggedin = token != null;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token"); // Remove the token
    setState(() {
      isloggedin = false;
    });

    // Show logout success message
    Fluttertoast.showToast(
      msg: "Logout Success",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Navigate back to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2E2E2),
      appBar: appBar(),
      body: Column(
        children: [
          // Search TextField
          Container(
            margin: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.11),
                  blurRadius: 40,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Color(0xffD2E2E2)),
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: const TextStyle(
                  color: Color(0xffD2E2E2),
                ),

                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showSearchResults = true;
                          showRecentChats = false;
                        });
                        if (searchController.text.isNotEmpty) {
                          _searchUsers(searchController.text);
                        }
                      },
                      icon: Icon(Icons.search),
                      color: Color(0xffD2E2E2),
                    ),
                    if(showSearchResults)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showSearchResults = false;
                          showRecentChats = true;
                        });
                        searchController.clear();
                      },
                      icon: Icon(Icons.cancel_outlined),
                      color: Color(0xffD2E2E2),
                    ),

                  ],
                ),
                filled: true,
                fillColor: Color(0xFF3f7c88),
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              cursorColor: Color(0xffD2E2E2),
              onSubmitted: (query) {
                setState(() {
                  showSearchResults = true;
                  showRecentChats = false;
                });
                if (query.isNotEmpty) {
                  _searchUsers(query);
                }
              },
            ),
          ),
          if (showSearchResults)
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final users = _searchResults[index];
                var you = users['username'] == username
                    ? "${users['username']} (you)"
                    : users['username'];

                // print
                return ListTile(
                  leading: CircleAvatar(
                      backgroundImage: NetworkImage(users['image'])),
                  title: Text(you),
                  subtitle: Text(users['bio'] ?? ''),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Chat(
                                  userId: users['user_id'],
                                  username: you,
                                  image: users['image'],
                                  name: users['full_name'],
                                )));
                  },
                );
              },
            )),

          // Loading indicator
          if (isLoading && showRecentChats)
              Expanded(
                  child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xff3F7C88)), // Change color here
                    ),
                    SizedBox(
                        height:
                            15), // Add some space between the indicator and the text
                    Text(
                      "Connecting...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ],
                ),
              )
                  // Show loading indicator while fetching data
                  )
            else
            if (!isLoading && showRecentChats)
              Expanded(
                child: ListView.builder(
                  itemCount: chatData.length,
                  itemBuilder: (context, index) {
                    final chat = chatData[index];
                    return ChatTile(
                      name: chat["name"]!,
                      message: chat["message"]!,
                      time: chat["time"]!,
                      online_status: chat["online_status"] == "true",
                      avatarUrl: chat["avatarUrl"]!,
                      userId: chat["userId"]!,
                      username: chat['username']!,
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  appBar() {
    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(seconds: 60), // Duration for the animation
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Combine both FadeTransition and RotationTransition
          return FadeTransition(
            opacity: animation,
            child: RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },

        child: Text(
          showUsername
              ? (username ?? "  🗿 Chats")
              : "  🗿 Chats", // Toggle title
          key: ValueKey<String>(
              showUsername ? (username ?? "  🗿 Chats") : "  🗿 Chats"),
          style: const TextStyle(
            color: Color(0xff3F7C88),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Color(0xFFD2E2E2),
      elevation: 0.0,
      actions: [
        IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        homepage()), // Replace with your homepage widget
              );
            },
            icon: Icon(Icons.refresh, color: Colors.black87)),
        GestureDetector(
          onTap: () {
            if (isloggedin) {
              // _loadPreferences();
              logout();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 35,
            decoration: BoxDecoration(
                color: Color(0xFFedf3f5),
                borderRadius: BorderRadius.circular(10)),
            child: isloggedin
                ? SvgPicture.asset(
                    "assets/icons/logout-svgrepo-com.svg",
                    height: 20,
                    width: 20,
                  )
                : SvgPicture.asset(
                    "assets/icons/login-svgrepo-com.svg",
                    height: 20,
                    width: 20,
                  ),
          ),
        ),
      ],
    );
  }
}

class ChatTile extends StatefulWidget {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final bool online_status;
  final String userId;
  final String username;

  ChatTile({
    required this.online_status,
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.userId,
    required this.username,
  });

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30.0, // Adjust size of avatar
            backgroundImage: CachedNetworkImageProvider(widget.avatarUrl),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12.0, // Size of the status dot
              height: 12.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.online_status ? Colors.green : Colors.grey,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(widget.name),
      subtitle: Text(
        widget.message.length > 30
            ? '${widget.message.substring(0, 30)}...'
            : widget.message,
      ),
      trailing: Text(widget.time, style: TextStyle(color: Colors.black)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              userId: widget.userId,
              username: widget.username,
              image: widget.avatarUrl,
              name: widget.name,
            ),
          ),
        );
      },
    );
  }
}
