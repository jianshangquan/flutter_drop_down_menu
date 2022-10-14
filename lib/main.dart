import 'dart:math';

import 'package:flutter/material.dart';
import 'package:menu_items/DropDownListView/drop_down_list_position.dart';
import 'package:menu_items/DropDownListView/drop_down_list_view.dart';

void main() {
  runApp(const HomeView());
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: 1500,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(),
                  DropDownListView(
                    height: 200,
                    defaultItemIndex: 1,
                    position: DropdownPosition.top,
                    items: const ["value1", 'value5', 'value6','value5', 'value6','value5', 'value6','value5', 'value6','value5', 'value6','value5', 'value6','value5', 'value6', 'value7value7value7value7value7value7value7value7value7value7value7'],
                    dropdownItemBuilder: (context, String value){
                      return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Text(value, overflow: TextOverflow.ellipsis,)
                      );
                    },
                    dropdownButtonBuilder: (context, String value){
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text('$value', overflow: TextOverflow.ellipsis)
                      );
                    },
                    onValueChanged: (value, index){
                      print(value);
                    },
                  ),
                  TextField(),
                ],
              )
            ),
          )
        ),
      )
    );
  }
}
