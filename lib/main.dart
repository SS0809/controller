import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}
List<String> feedItems = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Dark matter Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var driveurl ;
  Color fabColor = Colors.blue;
  // Move the getHttp function inside the _MyHomePageState class
  void getHttp() async {
    try {
      var uri = Uri.https('original-google.onrender.com', '/getfiles');
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        List<dynamic> jsonList = json.decode(response.body.toString());
        for (var item in jsonList) {
          if(item['mimeType']!='application/vnd.google-apps.folder') {
            String name = item['name'];
            String id = item['id'];
            feedItems.add('$name - $id');
          }
        }
        print(feedItems);
        setState(() {
          driveurl = response.body.toString(); // Update driveurl with the new value
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  void getHttp2() async {
    try {
      final response = await http.get(Uri.parse('https://original-google.onrender.com'));
      if (response.statusCode == 200) {
        setState(() {
          fabColor = Colors.green; // Change to green if successful response
        });
      } else {
        setState(() {
          fabColor = Colors.red; // Change to red if there's an error
        });
      }
    } catch (e) {
      setState(() {
        fabColor = Colors.red; // Change to red if an exception occurs
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle button press here
                    getHttp();
                    print('ElevatedButton pressed');
                  },
                  child: Text('Fetch Files'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: feedItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(feedItems[index]),
                      // Customize the ListTile as per your requirements
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getHttp2,
        tooltip: 'Increment',
        backgroundColor: fabColor, // Set the color of the FloatingActionButton
        child: const Icon(Icons.power),
      ),
    );
  }
}
