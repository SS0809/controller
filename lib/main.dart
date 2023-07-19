import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

List<String> feedItems = [];
List<String> feedId = [];

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;

  const CustomFloatingActionButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: CircleBorder(),
      elevation: 4.0,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Icon(icon),
      ),
    );
  }
}

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
  String serverurl = 'original-google.onrender.com';
  Color fabColor = Colors.blue;
  Timer? periodicTimer; // Timer instance
  Map<String, bool> buttonStatusMap = {};

  void getHttp() async {
    try {
      var uri = Uri.https(serverurl, '/getfiles');
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        List<dynamic> jsonList = json.decode(response.body.toString());
        for (var item in jsonList) {
          if (item['mimeType'] != 'application/vnd.google-apps.folder') {
            String name = item['name'];
            String id = item['id'];
            feedItems.add('$name'); /*$name - $id*/
            feedId.add('$id');
          }
        }
        print(feedItems);
        setState(() {
          driveurl = response.body.toString();
          buttonStatusMap =
              Map.fromIterable(feedId, key: (id) => id, value: (_) => true);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void getHttp2() {
    void fetchStatus() async {
      try {
        final response =
            await http.get(Uri.parse('https://'+serverurl));
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

    periodicTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchStatus();
      print('periodicTimer');
    });
  }

  void getHttp3(var para) async {
    try {
      var uri = Uri.https(serverurl, '/createrepo', {
        'fileid': para,
      });
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void getHttp4(var para) async {
    try {
      var uri = Uri.https(serverurl, '/deletefile', {
        'file_id': para,
      });
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        // If the deletion was successful, refresh the widget by calling getHttp()
        setState(() {
          buttonStatusMap[para] = false; // Assuming the item was deleted successfully
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
            Expanded(
              child: ListView.builder(
                itemCount: feedItems.length,
                itemBuilder: (context, index) {
                  String id = feedId[index];
                  bool isButtonEnabled = buttonStatusMap[id] ?? true;
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            feedItems[index],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: isButtonEnabled
                                  ? () {
                                      getHttp3(id);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isButtonEnabled ? Colors.blue : Colors.grey,
                              ),
                              child: Text('Upload'), /*$index*/
                            ),
                            ElevatedButton(
                              onPressed:
                                  isButtonEnabled ? () => getHttp4(id) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isButtonEnabled ? Colors.red : Colors.grey,
                              ),
                              child: Text('Remove'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFloatingActionButton(
            onPressed: getHttp2,
            backgroundColor: fabColor,
            icon: Icons.power,
          ),
          SizedBox(height: 12), // Adjust the spacing between the FABs
          CustomFloatingActionButton(
            onPressed: getHttp,
            backgroundColor: Colors.orange, // Set the desired background color
            icon: Icons.add, // Set the desired icon
          ),
        ],
      ),
    );
  }
}
