import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/signup.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers to get text input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // GlobalKey to handle form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2E2E2),
      appBar: AppBar(
        title: const Text('Login',style: TextStyle(color: Color(0xff3F7C88), fontSize: 25,
            fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFFD2E2E2),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email TextField
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    color: Color(0xFF3f7c88), // Label text color
                    fontSize: 18.0, // Label font size
                  ),
                  fillColor: Color(0xFF3f7c88),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF3f7c88),
                        width: 1.5,
                      )),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF3f7c88), // Border color when focused
                      width: 2.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                cursorColor: Colors.black,
              ),
              SizedBox(height: 19.0),

              // Password TextField
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: Color(0xFF3f7c88), // Label text color
                    fontSize: 18.0, // Label font size
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF3f7c88), // Border color when unfocused
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF3f7c88), // Border color when focused
                      width: 2.0,
                    ),
                  ),
                ),
                obscureText: true,
                cursorColor: Colors.black,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // if (value.length < 6) {
                  //   return 'Password must be at least 6 characters long';
                  // }
                  return null;
                },
              ),
              SizedBox(height: 24.0),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Handle login logic here
                    String email = emailController.text;
                    String password = passwordController.text;
                    await login(email, password, context);
                    // String? response = await login(email, password, context);
                    // return response;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3f7c88),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Login',
                    style: TextStyle(color: Color(0xffD2E2E2))),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("Don't have an account?", style: TextStyle(
                fontSize: 16
            ),),

            CupertinoButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) {
                        return SignupPage();
                      }
                  ),
                    (Route<dynamic> route) => false,
                );
              },
              child: Text("Sign Up", style: TextStyle(
                color: Color(0xff3F7C88),
                  fontSize: 16
              ),),
            ),

          ],
        ),
      ),

    );
  }
}

const String apiUrl =
    "https://loved-seemingly-cod.ngrok-free.app/api/accounts/login/";

Future<String?> login(String email, String password,BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(data);
      String token = data['token']['access'];
      int myUserId = data["your_id"];
      String myUserName = data["username"];
      // print(token,myUser);
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      print("data saved");
      await prefs.setInt("myUserId", myUserId);
      print("data saved");
      await prefs.setString("myUsername", myUserName);
      print("data saved");
      Fluttertoast.showToast(
        msg: "Login Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Position of the toast
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xFFA5DBDC),
        textColor: Color(0xff3F7C88),
        fontSize: 16.0,
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => homepage()),
         (Route<dynamic> route) => false,
      );
      return null; // Return the token if needed
    } else {
      final data = jsonDecode(response.body);
      Fluttertoast.showToast(
        msg: data['errors']['non_fields_errors'][0].toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM, // Position of the toast
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.redAccent,
        fontSize: 16.0,
      );
      // Handle error responses here
      print('Login failed: ${response.body}');
      return data['errors']['non_fields_errors'][0].toString();
    }
  } catch (e) {
    print("$e");
    return null;
  }
}
