import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


void main() {
  runApp(const MyApp());
}

List<String> feedItems = [];
List<String> feedId = [];
List<String> feedId_database = [];
List<String> feedId_github = [];
List<bool> feed_check = [];

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
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MyHomePage(title: 'Dark Matter'),
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
  bool variable_for_button1 = true;
  bool variable_for_button2 = true;
  String serverurl = 'original-google.onrender.com';
  Color fabColor = Colors.blue;
  Timer? periodicTimer; // Timer instance
  Map<String, bool> buttonStatusMap = {};
  Map<String, bool> buttonStatusMap_database = {};
  Map<String, bool> buttonStatusMap_github = {};

  void getvidfiles() async {
    try {
      variable_for_button1 = true;
      variable_for_button2 = true;
      var uri = Uri.https(serverurl, '/getmappeddata');
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        feedId.clear();
        feedItems.clear();
        feed_check.clear();
        List<dynamic> jsonList = json.decode(response.body.toString());
        for (var item in jsonList) {
          if (item['mimeType'] != 'application/vnd.google-apps.folder') {
            String name = item['name'];
            String id = item['id'];
            feedItems.add('$name'); /*$name - $id*/
            feedId.add('$id');
            if (item.containsKey('check')) {
              feed_check.add(item['check']);
            }
            else {
              feed_check.add(false);
              }
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

  void getfiles_database() async {
    try {
      variable_for_button1 = false;
      variable_for_button2 = false;
      var uri = Uri.https(serverurl, '/movie_data');
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        feedItems.clear();
        feedId.clear();
        List<dynamic> jsonList = json.decode(response.body.toString());
        for (var item in jsonList) {
          String name = item['movie_name'];
          feedItems.add('$name');
          feedId.add('$name');
        }
        print(feedItems);
        setState(() {
          buttonStatusMap_database = Map.fromIterable(feedId_database,
              key: (id) => id, value: (_) => true);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void getfiles_github() async {
    try {
      variable_for_button2 = true;
      variable_for_button1 = false;
      var uri = Uri.https(serverurl, '/getrepo');
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        feedItems.clear();
        feedId.clear();
        List<dynamic> jsonList = json.decode(response.body.toString());
        List<String> extractedData = List<String>.from(jsonList);
        for (String element in extractedData) {
          print(element);
          feedItems.add('$element');
          feedId.add('$element');
        }

        setState(() {
          buttonStatusMap_github = Map.fromIterable(feedId_github,
              key: (id) => id, value: (_) => true);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void online_test_url() {
    void fetchStatus() async {
      try {
        final response = await http.get(Uri.parse('https://' + serverurl));
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

  void createrepo(var para) async {
    try {
      var uri = Uri.https(serverurl, '/createrepo', {
        'fileid': para,
      });
      await http.get(uri);
    } catch (e) {
      print('Error: $e');
    }
  }
  void rerunworkflow(var para) async {
    try {
      var uri = Uri.https(serverurl, '/workflow', {
        'workflowrepo': para,
      });
      await http.get(uri);
    } catch (e) {
      print('Error: $e');
    }
  }


  void deletefile(var para) async {
    try {
      var uri = Uri.https(serverurl, '/deletefile', {
        'file_id': para,
      });
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        // If the deletion was successful, refresh the widget by calling getvidfiles()
        setState(() {
          buttonStatusMap[para] =
          false; // Assuming the item was deleted successfully
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
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            feedItems[index],
                          ),
                        ),
                        if (variable_for_button1 || variable_for_button2)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: (variable_for_button1 || variable_for_button2)
                                    ? () => rerunworkflow(id)
                                    : () => createrepo(id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  isButtonEnabled ? Colors.blue : Colors.grey,
                                ),
                                child: Text('Upload'), /*$index*/
                              ),
                              if (variable_for_button1 && variable_for_button2)
                                ElevatedButton(
                                  onPressed: isButtonEnabled ? () => deletefile(id) : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    isButtonEnabled ? Colors.red : Colors.grey,
                                  ),
                                  child: Text('Remove'),
                                ),
                            ],
                          ),
                        if (variable_for_button1 && variable_for_button2)
                        Icon(
                          Icons.star,
                          color: feed_check[index] ? Colors.green : Colors.red,
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
            onPressed: online_test_url,
            backgroundColor: fabColor,
            icon: Icons.power,
          ),
          SizedBox(height: 12), // Adjust the spacing between the FABs
          CustomFloatingActionButton(
            onPressed: getvidfiles,
            backgroundColor: Colors.orange, // Set the desired background color
            icon: Icons.file_copy_sharp, // Set the desired icon
          ),
          SizedBox(height: 12), // Adjust the spacing between the FABs
          CustomFloatingActionButton(
            onPressed: getfiles_database,
            backgroundColor:
            Colors.blueAccent, // Set the desired background color
            icon: Icons.data_array, // Set the desired icon
          ),
          SizedBox(height: 12), // Adjust the spacing between the FABs
          CustomFloatingActionButton(
            onPressed: getfiles_github,
            backgroundColor: Colors.black38,
            icon: Icons.data_array, // Use the GitHub icon from flutter_icons
          ),
        ],
      ),
    );
  }
}
