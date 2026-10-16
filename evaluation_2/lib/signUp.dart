import 'package:evaluation_2/billSplitter.dart';
import 'package:evaluation_2/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final storage = FlutterSecureStorage();
  void _register(BuildContext context) async {
    print("sign Up");
    var url = Uri.parse("http://192.168.4.180:5000/signUp");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username.text,
        'password': password.text,
        'confirmPassword': confirmPassword.text,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await storage.write(key: "jwt", value: data["token"]);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => billSplitter()));
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Smart Bill Splitter & Expense Tracker Sign Up"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Text("Log In"),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Username: ",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  height: 40,
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: TextField(
                    controller: username,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17),

            Row(
              children: [
                Text(
                  "Password: ",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  height: 40,
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: TextField(
                    controller: password,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17),

            Row(
              children: [
                Text(
                  "Confirm Password: ",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: TextField(
                    controller: confirmPassword,
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                _register(context);
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
