import 'dart:math';

import 'package:flutter/material.dart';
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

  List<int> val = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40];


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
                    defaultItemIndex: 0,
                    items: val.map<String>((i) => 'value $i').toList(),
                    dropdownItemBuilder: (context, String value, index, isSelected){
                      return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Text(value, overflow: TextOverflow.ellipsis,)
                      );
                    },
                    dropdownButtonBuilder: (context, int index){
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text('value ${val[index]}', overflow: TextOverflow.ellipsis)
                      );
                    },
                    onValueChanged: (value, index){
                      print("value changed $value");
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
