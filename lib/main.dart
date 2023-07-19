import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

List<String> feedItems = [];
List<String> feedId = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Matter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Dark Matter Controller'),
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
  var driveurl;
  Color fabColor = Colors.blue;

  Map<String, bool> buttonStatusMap = {};

  void getHttp() async {
    try {
      var uri = Uri.https('original-google.onrender.com', '/getfiles');
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        List<dynamic> jsonList = json.decode(response.body.toString());
        for (var item in jsonList) {
          if (item['mimeType'] != 'application/vnd.google-apps.folder') {
            String name = item['name'];
            String id = item['id'];
            feedItems.add('$name');/*$name - $id*/
            feedId.add('$id');
          }
        }
        print(feedItems);
        setState(() {
          driveurl = response.body.toString();
          buttonStatusMap = Map.fromIterable(feedId, key: (id) => id, value: (_) => true);
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
          fabColor = Colors.green;
        });
      } else {
        setState(() {
          fabColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        fabColor = Colors.red;
      });
    }
  }

  void getHttp3(var para) async {
    try {
      var uri = Uri.https('original-google.onrender.com', '/createrepo', {
        'fileid': para,
      });
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          buttonStatusMap[para] = jsonResponse != null && jsonResponse.isNotEmpty;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
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
                  String id = feedId[index];
                  bool isButtonEnabled = buttonStatusMap[id] ?? true;
                  return Card(
                    child: ListTile(
                      title: Text(feedItems[index]),
                      trailing: ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () {
                          getHttp3(id);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          primary: isButtonEnabled ? Colors.blue : Colors.grey,
                        ),
                        child: Text('Upload'),/*$index*/
                      ),
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
        backgroundColor: fabColor,
        child: const Icon(Icons.power),
      ),
    );
  }
}
