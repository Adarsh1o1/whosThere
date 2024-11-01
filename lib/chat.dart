import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class Chat extends StatefulWidget {
  final String name;
  final String userId;
  final String username;
  final String image;

  Chat({
    required this.userId,
    required this.username,
    required this.image,
    required this.name,
  });

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, String>> messages = [];
  late WebSocketChannel channel;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void sendMessage({String? imageData}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myname = prefs.getString("myUsername");
    String msg = messageController.text.trim();

    if (msg.isNotEmpty || imageData != null) {
      Map<String, String> messageData = {'username': myname!};

      if (imageData != null) {
        // This is an image message
        messageData['message_type'] = 'image';
        messageData['message'] = imageData;
      } else {
        // This is a text message
        messageData['message'] = msg;
        messageData['message_type'] = 'text';
        messageController.clear();
      }
      String jsonMessage = jsonEncode(messageData);
      print(jsonMessage);
      channel.sink.add(jsonMessage);
       // Clear the input field
    }
  }

  @override
  void initState() {
    super.initState();
    _initializingWebsocket();
  }

  Future<void> _initializingWebsocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    _fetchChats();
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://loved-seemingly-cod.ngrok-free.app/ws/chat/${widget.userId}/?token=$token'),
    );
    channel.stream.listen((message) {
      final newMessage = jsonDecode(message);
      String formattedTime = DateFormat('hh:mm a').format(DateTime.now());
      String formattedDate = DateFormat('EEE MMM d, y').format(DateTime.now());
      print('socket $newMessage');
      setState(() {
        messages.insert(0, {
          // Insert at the start instead of adding to the end
          'message_type': newMessage['message_type'] ?? '',
          'message': newMessage['message'],
          'username': newMessage['username'],
          'timestamp': formattedTime,
          'date': formattedDate,
        });
      });
    });

    // await _fetchChats();
  }

//DateTime.parse(DateTime.now().toIso8601String()).toLocal().toString().split(' ')[1]
  @override
  void dispose() {
    channel.sink.close(); // Close WebSocket when disposing
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          'https://loved-seemingly-cod.ngrok-free.app/api/chat/chatHistory/${widget.userId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> history = jsonDecode(response.body);
      if (history.isNotEmpty) {
        List<dynamic> messagesHistory = history[0];
        setState(() {
          messages = messagesHistory.map((msg) {
            return {
              'message': msg['Message'].toString(),
              'username': msg['sender'].toString(),
              'timestamp': msg['time'].toString(),
              'date': msg['date'].toString(),
              'message_type': msg['message_type'].toString(),
            };
          }).toList();
        });
      }
    } else {
      print("Failed to load chat history: ${response.statusCode}");
    }
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    var uri = Uri.parse(
        'https://loved-seemingly-cod.ngrok-free.app/api/chat/uploads/');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('file', pickedFile!.path));

    var response = await request.send();
    if (response.statusCode == 201) {
      String responseBody = await response.stream.bytesToString();
      var json = jsonDecode(responseBody);
      var file_url = json['file_url'];
      sendMessage(imageData: file_url);
    } else {
      print('Upload failed with status: ${response.statusCode}');
    }
  }

  void _scrollToBottom() {
    // Check if there are clients and messages are present
    if (_scrollController.hasClients && messages.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2E2E2),
      appBar: AppBar(
        backgroundColor: Color(0xFFD2E2E2),
        automaticallyImplyLeading: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(widget.image),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.username,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/three-dots-vertical-svgrepo-com.svg',
                height: 22,
                width: 22,
              ),
              onPressed: () {
                print('button pressed');
              },
            ),
          ],
        ),
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
                  bool isCurrentUser =
                      messages[index]['username'] != widget.username;

                  String formattedDate = messages[index]['date']!;
                  String? previousMessageDate;
                  if (index < messages.length - 1) {
                    previousMessageDate = messages[index + 1]['date'];
                  }
                  bool showDateSeparator = previousMessageDate != null &&
                      previousMessageDate != formattedDate;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Display date separator if needed
                      if (showDateSeparator)
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            formattedDate, // Date format for the separator
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Container(
                        margin: isCurrentUser
                            ? EdgeInsets.only(left: 50)
                            : EdgeInsets.only(right: 50),
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (messages[index]['message_type'] == 'text')
                                Container(
                                  padding: EdgeInsets.only(
                                      right: 15, left: 15, top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Color(0xFF3f7c88),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    messages[index]['message'] ?? '',
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.black87
                                          : Color(0xFFd2e2e2),
                                      fontSize: 17,
                                    ),
                                  ),
                                )
                              else if (messages[index]['message_type'] ==
                                  'image') // For image messages
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to full-screen view on tap
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenImage(
                                            imageUrl: messages[index]
                                                ['message']!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: messages[index]['message']!,
                                        height: 200,
                                        width: 150,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 3),
                              // Add some spacing between message and timestamp
                              Text(
                                messages[index]['timestamp']!,
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF3f7c88),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        style: TextStyle(
                          color: Color(0xffD2E2E2),
                        ),
                        decoration: InputDecoration(
                          hintText: "Message...",
                          hintStyle: const TextStyle(
                            color: Color(0xffD2E2E2),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                        ),
                        cursorColor: Color(0xffD2E2E2),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF3f7c88),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: () {
                        sendImage();
                      },
                      icon: Icon(
                        Icons.photo_camera_outlined,
                        color: Color(0xFFd2e2e2),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF3f7c88),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Color(0xFFd2e2e2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}
