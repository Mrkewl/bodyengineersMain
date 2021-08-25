import 'package:flutter/material.dart';

class MultiSelectorWidget extends StatefulWidget {
  List<MultiSelectorElement>? choices = [];
  Function? onChanged;
  List<int>? values;
  String? title;
  MultiSelectorWidget({this.values, this.choices, this.onChanged, this.title});
  @override
  _MultiSelectorWidgetState createState() => _MultiSelectorWidgetState();
}

class _MultiSelectorWidgetState extends State<MultiSelectorWidget> {
  List<dynamic> result = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.choices!.forEach((element) {
      if (widget.values!.contains(element.value)) {
        element.isSelected = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title!,
          style: TextStyle(color: Colors.black45),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
            onTap: () {
              result = widget.choices!
                  .where((element) => element.isSelected)
                  .map((e) => int.parse(e.value.toString()))
                  .toList();
              widget.onChanged!(result);
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black45,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 13, right: 15),
            child: GestureDetector(
              onTap: () {
                result = widget.choices!
                    .where((element) => element.isSelected)
                    .map((e) => int.parse(e.value.toString()))
                    .toList();
                widget.onChanged!(result);
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(fontSize: 18, color: Colors.black45),
              ),
            ),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: widget.choices!.length,
          itemBuilder: (context, index) {
            return SelectItem(widget.choices![index]);
          }),
    );
  }
}

class SelectItem extends StatefulWidget {
  MultiSelectorElement multiSelectorElement;
  SelectItem(this.multiSelectorElement);

  @override
  _SelectItemState createState() => _SelectItemState();
}

class _SelectItemState extends State<SelectItem> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.multiSelectorElement.name!),
      activeColor: Color.fromRGBO(86, 177, 191, 1),
      value: widget.multiSelectorElement.isSelected,
      onChanged: (value) {
        setState(() {
          widget.multiSelectorElement.isSelected =
              !widget.multiSelectorElement.isSelected;
        });
      },
      controlAffinity:
          ListTileControlAffinity.trailing, //  <-- leading Checkbox
    );

    // Container(
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.only(left: 10),
    //         child: Text(widget.multiSelectorElement.name!),
    //       ),
    //       Checkbox(
    //         value: widget.multiSelectorElement.value != null,
    //         onChanged: (value) {
    //           setState(() {
    //             widget.multiSelectorElement.isSelected =
    //                 !widget.multiSelectorElement.isSelected;
    //           });
    //         },
    //       ),
    //     ],
    //   ),
    // );
  }
}

class MultiSelectorElement {
  String? name;
  dynamic value;
  bool isSelected = false;
  MultiSelectorElement({this.name, this.value});
}
