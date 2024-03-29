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
      title: 'CORE :: Controller',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MyHomePage(title: 'CORE :: Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  late AnimationController controller = AnimationController(vsync: this);
  bool determinate = false;

  TextEditingController serverAddressController = TextEditingController();
  TextEditingController serverAddressController2 = TextEditingController();
  var driveurl;
  bool hide_progess_indicator = false;
  bool variable_for_button1 = true;
  bool variable_for_button2 = true;
  String serverurl = '';
  Color fabColor = Colors.blue;
  Timer? periodicTimer; // Timer instance
  Map<String, bool> buttonStatusMap = {};
  Map<String, bool> buttonStatusMap_database = {};
  Map<String, bool> buttonStatusMap_github = {};


  bool isTextFieldVisible = false;

  void toggleTextFieldVisibility() {
    setState(() {
      isTextFieldVisible = !isTextFieldVisible;
    });
  }

  void getvidfiles() async {
    try {
      hide_progess_indicator = true;
      serverurl = serverAddressController.text;
      variable_for_button1 = true;
      variable_for_button2 = true;
      var uri = Uri.http(serverurl, '/getmappeddata');
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Fetched")));
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    hide_progess_indicator = false;
  }

  void getfiles_database() async {
    try {
      hide_progess_indicator = true;
      serverurl = serverAddressController.text;
      variable_for_button1 = false;
      variable_for_button2 = false;
      var uri = Uri.http(serverurl, '/movie_data');
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Fetched")));
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    hide_progess_indicator = false;
  }

  void tele_files() async {
    try {
      hide_progess_indicator = true;
      serverurl = serverAddressController2.text;
      variable_for_button1 = false;
      variable_for_button2 = false;
      var uri = Uri.http(serverurl, '/default/TELECORE', {'limit': '500', 'user1_to_bot': 'true'});
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        feedItems.clear();
        feedId.clear();
        List<dynamic> jsonList = json.decode(response.body.toString());
        for (var item in jsonList) {
          String name = item['file_name'];
          feedItems.add('$name');
          feedId.add('$name');
        }
        print(feedItems);
        setState(() {
          buttonStatusMap_database = Map.fromIterable(feedId_database,
              key: (id) => id, value: (_) => true);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Fetched")));
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    hide_progess_indicator = false;
  }

  void getfiles_github() async {
    try {
      hide_progess_indicator = true;
      serverurl = serverAddressController.text;
      variable_for_button2 = true;
      variable_for_button1 = false;
      var uri = Uri.http(serverurl, '/getrepo');
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Fetched")));
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    hide_progess_indicator = false;
  }

  void online_test_url() {
    void fetchStatus() async {
      try {
        hide_progess_indicator = true;
        serverurl = serverAddressController.text;
        final response = await http.get(Uri.parse('http://' + serverurl));
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
      hide_progess_indicator = false;
    }

    periodicTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchStatus();
      print('periodicTimer');
    });
  }

  void createrepo(var para) async {
    try {
      serverurl = serverAddressController.text;
      var uri = Uri.http(serverurl, '/createrepo', {
        'fileid': para,
      });
      await http.get(uri);
    } catch (e) {
      print('Error: $e');
    }
  }
  void rerunworkflow(var para) async {
    try {
      serverurl = serverAddressController.text;
      var uri = Uri.http(serverurl, '/workflow', {
        'workflowrepo': para,
      });
      await http.get(uri);
    } catch (e) {
      print('Error: $e');
    }
  }


  void deletefile(var para) async {
    try {
      serverurl = serverAddressController.text;
      var uri = Uri.http(serverurl, '/deletefile', {
        'file_id': para,
      });
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        // If the deletion was successful, refresh the widget by calling getvidfiles()
        setState(() {
          buttonStatusMap[para] =
          false; // Assuming the item was deleted successfully
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Fetched")));
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  @override
  void initState() {
    serverurl = serverAddressController.text;
    controller = AnimationController(
    /// [AnimationController]s can be created with `vsync: this` because of
    /// [TickerProviderStateMixin].
    vsync: this,
    duration: const Duration(seconds: 2),
    )..addListener(() {
    setState(() {});
    });
    controller.repeat(reverse: true);
    super.initState();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: toggleTextFieldVisibility,
          child: Text(widget.title),
        ),
        bottom: hide_progess_indicator ? PreferredSize(
          preferredSize: Size(double.infinity, 1.0),
          child: LinearProgressIndicator(
            value: controller.value,
            semanticsLabel: 'Linear progress indicator',
          ),
        ) : null,

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: isTextFieldVisible,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: serverAddressController,
                      decoration: InputDecoration(
                        labelText: 'Server Address 1',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: serverAddressController2,
                      decoration: InputDecoration(
                        labelText: 'Server Address 2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: feedItems.length,
                itemBuilder: (context, index) {
                  String id = feedId[index];
                  bool isButtonEnabled = buttonStatusMap[id] ?? true;
                  return Card(
                    color: Colors.black38,
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
      floatingActionButton: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomFloatingActionButton(
              onPressed: online_test_url,
              backgroundColor: fabColor,
              icon: Icons.power,
            ),
            SizedBox(height: 12),
            RawMaterialButton(
              onPressed: getvidfiles,
              elevation: 2.0,
              fillColor: Colors.transparent,
              child: Image.asset(
                'assets/drive.png',
                width: 50,
                height: 50,
              ),
              shape: CircleBorder(),
            ),
            SizedBox(height: 12),
            RawMaterialButton(
              onPressed: getfiles_database,
              elevation: 2.0,
              fillColor: Colors.transparent,
              child: Image.asset(
                'assets/mongo.png',
                width: 50,
                height: 50,
              ),
              shape: CircleBorder(),
            ),
            SizedBox(height: 12),
            RawMaterialButton(
              onPressed: getfiles_github,
              elevation: 2.0,
              fillColor: Colors.transparent,
              child: Image.asset(
                'assets/github.png',
                width: 50,
                height: 50,
              ),
              shape: CircleBorder(),
            ),
            SizedBox(height: 12),
            RawMaterialButton(
              onPressed: tele_files,
              elevation: 2.0,
              fillColor: Colors.transparent,
              child: Image.asset(
                'assets/telegram.png',
                width: 50,
                height: 50,
              ),
              shape: CircleBorder(),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }}