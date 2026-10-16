import 'package:evaluation_2/billSplitter.dart';
import 'package:evaluation_2/signUp.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  final storage = FlutterSecureStorage();

  void _login(BuildContext context) async {
    var url = Uri.parse("http://192.168.4.180:5000/login");
    print("login");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'username': username.text, 'password': password.text}),
    );

    if (response.statusCode == 200) {
      print("Hit Too");
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
        title: Text("Smart Bill Splitter & Expense Tracker Log In"),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => signUp()),
              );
            },
            child: Text("Sign Up"),
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

            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: Text("Log In"),
            ),
          ],
        ),
      ),
    );
  }
}
