import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';

class billSplitter extends StatefulWidget {
  const billSplitter({super.key});

  @override
  State<billSplitter> createState() => _billSplitterState();
}

class _billSplitterState extends State<billSplitter> {
  TextEditingController peopleEating = TextEditingController();
  TextEditingController finalBill = TextEditingController();
  var finalTipwithBill;
  var costPerPerson;
  final storage = FlutterSecureStorage();

  void _saveTheBill(BuildContext context) async {
    print('bill');
    final token = await storage.read(key: "jwt");
    var url = Uri.parse("http://192.168.4.180:5000/bills");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user': token,
        'trueFinalCost': finalTipwithBill,
        'costForEach': costPerPerson,
        'numOfPeople': peopleEating.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "jwt", value: data["token"]);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => billSplitter()));
    }
    ;
  }

  void _splitTheBill(BuildContext context) async {
    print("route hit");
    var url = Uri.parse("http://192.168.4.180:5000/split");
    print(peopleEating.text);
    print(finalBill.text);
    print(dropDownValue.toString());
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        'peopleEating': peopleEating.text,
        'finalBill': finalBill.text,
        'tipPercent': dropDownValue.toString(),
      }),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      print("success");
      final data = jsonDecode(response.body);
      final info = Map<String, dynamic>.from(data);
      print(info["finalBill"]);
      print(info["costPerPerson"]);
      setState(() {
        finalTipwithBill = info["finalBill"];
        costPerPerson = info["costPerPerson"];
      });
      print(finalTipwithBill);
      print(costPerPerson);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Column(
            children: [
              Text('The final cost including tip is \$${finalTipwithBill}'),
              Text('The Cost per person is \$${costPerPerson}'),
              ElevatedButton(
                onPressed: () {
                  print("save Bill");
                  _saveTheBill(context);
                },
                child: Text("Save Receipt? (otherwise click outside)"),
              ),
            ],
          ),
        ),
      );
    }
  }

  double dropDownValue = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
        title: Text("Smart Bill Splitter & Expense Tracker Sign Up"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("How Many People Did you eat with? "),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 157, 238, 167),
                    border: BoxBorder.all(
                      color: const Color.fromARGB(255, 21, 49, 22),
                      width: 3,
                    ),
                  ),

                  width: MediaQuery.sizeOf(context).width * 0.3,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                    child: TextField(
                      controller: peopleEating,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "4",
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(103, 8, 8, 8),
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("What ended up being the Final Bill? "),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 157, 238, 167),
                      border: BoxBorder.all(
                        color: const Color.fromARGB(255, 21, 49, 22),
                        width: 3,
                      ),
                    ),

                    width: MediaQuery.sizeOf(context).width * 0.3,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                      child: TextField(
                        controller: finalBill,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "113.99",
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(103, 8, 8, 8),
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<double>(
              value: dropDownValue,
              items: [
                DropdownMenuItem(value: 0.0, child: Text("0%")),
                DropdownMenuItem(value: 0.05, child: Text("5%")),
                DropdownMenuItem(value: 0.1, child: Text("10%")),
                DropdownMenuItem(value: 0.15, child: Text("15%")),
              ],
              onChanged: (selected) {
                if (selected != null) {
                  setState(() => dropDownValue = selected);
                }
              },
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color.fromARGB(255, 157, 238, 167),
                border: BoxBorder.all(
                  color: const Color.fromARGB(255, 21, 49, 22),
                  width: 3,
                ),
              ),

              width: MediaQuery.sizeOf(context).width * 0.6,
              height: 70,
              child: SizedBox.expand(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 157, 238, 167),
                  ),
                  onPressed: () {
                    _splitTheBill(context);
                  },
                  child: Text(
                    "Calculate Bill",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 21, 49, 22),
                    ),
                  ),
                ),
              ),
            ),

            // if (costPerPerson != null && finalTipwithBill != null)
            //   Text(costPerPerson.toString()),
            // if (costPerPerson != null && finalTipwithBill != null)
            //   Text(finalTipwithBill.toString()),
          ],
        ),
      ),
    );
  }
}
