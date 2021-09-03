import 'package:flutter/material.dart';
import 'package:flutter_widgets/widgets/auto_complete_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _Item? _selectedItem;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flutter Widgets"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            AutoCompleteTextField<_Item>(
                onSearchTextChanges: (text) async {
                  List<_Item> items = _values
                      .where((element) => element.text.contains(text))
                      .toList();
                  return items;
                },
                inputDecoration:
                    InputDecoration(contentPadding: EdgeInsets.all(10)),
                onResultSelected: (result) => setState(() {
                      _selectedItem = result;
                    }),
                itemView: (value) => value.text,
                label: "Items search"),
            Expanded(child: Text(_selectedItem?.text ?? " "))
          ],
        ));
  }
}

class _Item {
  final String text;

  const _Item({required this.text});
}

const List<_Item> _values = [
  _Item(text: "User1 "),
  _Item(text: "User12"),
  _Item(text: "User0"),
  _Item(text: "User14"),
  _Item(text: "User11"),
];
