import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers to get text input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  // final TextEditingController confirmPasswordController = TextEditingController();


  // GlobalKey to handle form validation
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFD2E2E2),
      appBar: AppBar(
        title: const Text('Signup',style: TextStyle(color: Color(0xff3F7C88), fontSize: 25,
            fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFFD2E2E2),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 18, right: 18),
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
              ),
              SizedBox(height: 18.0),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    color: Color(0xff3f7c88),
                    fontSize: 18,
                  ),
                  fillColor: Color(0xff3f7c88),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xff3f7c88),
                      width: 1.5,
                    )
                  )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  // if (value.length < 6) {
                  //   return 'Password must be at least 6 characters long';
                  // }
                  return null;
                },
              ),
              SizedBox(height: 18.0),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),SizedBox(height: 18.0),
              // Password TextField
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 22.0),
              // Login Button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });

                    String email = emailController.text;
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;
                    String username = usernameController.text;

                    await register(email, password, confirmPassword, username, context);

                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3f7c88),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isLoading? SizedBox(height: 30, width: 30 ,child: CircularProgressIndicator(color: Colors.black,))
                : const Text('Create Account',
                    style: TextStyle(color: Color(0xffD2E2E2),fontSize: 17)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("Already have an account?", style: TextStyle(
                fontSize: 16
            ),),

            CupertinoButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text("Log in", style: TextStyle(
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

const String apiUrl ="https://loved-seemingly-cod.ngrok-free.app/api/accounts/register/";


Future<void> register(String email, String password, String confirmPassword, String username, BuildContext context)async {
  try{
    final response = await http.post(Uri.parse(apiUrl),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'email': email, 'password':password,'password2':confirmPassword,'username':username}),
    );
    if (response.statusCode == 201){
      final data = jsonDecode(response.body);
      Fluttertoast.showToast(
        msg: 'Account Created!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Position of the toast
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff3F7C88),
        textColor: Color(0xFFA5DBDC),
        fontSize: 16.0,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    } else if (response.statusCode == 400){
      Fluttertoast.showToast(
        msg: 'Field error!(check email, passwords or username)',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Position of the toast
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Color(0xFFA5DBDC),
        fontSize: 16.0,
      );
    }

  }catch (e){
    print(e);
  }
}


