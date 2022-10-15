### Usage
```dart
    DropDownListView(
        defaultItemIndex: 0,
        items: ['item1', 'item2', 'item3'],
        curve: Curves.ease, // opening or exit animation
        safeArea: true, // popup will display with safearea, Default: true
        physics: const NeverScrollableScrollPhysics() // scrollphysic for popup dropdown menu
        elevation: 5, // elevation for popup dropdown
        transitionPerPixel: 0.5, // popup menu duration for each pixel, in other word, control speed of popup menu depend on length
        iconData: Icons.arrow_drop_down, // icon for dropdown menu
        dropdownItemBuilder: (BuildContext context, dynamic value, int index, bool isSelected){
            // value => value of specific item
            // index => index of item
            // isSelected => true when current index was selected
            return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(value, overflow: TextOverflow.ellipsis)
            );
        },
        dropdownButtonBuilder: (context, int index){ // Build dropdown button
            // index => index give the current selected index;
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('value ${val[index]}', overflow: TextOverflow.ellipsis)
            );
        },
        onValueChanged: (value, index){ // this function is optional and will called with selection changed.
          print("value changed $value");
        },
    )
```