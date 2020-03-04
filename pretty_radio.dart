import 'package:flutter/material.dart';

/// Data Object
class PrettyRadioItem {
  final dynamic id;
  final String value;

  PrettyRadioItem({@required this.id, @required this.value});
}

/// Controller
class PrettyRadioController extends ValueNotifier<String> {
  PrettyRadioController({String id}) : super(id == null ? null : id);

  PrettyRadioController.fromValue(String id) : super(id);

  String get id => value ?? "";

  set id(String newID) => value = newID;
}

/// Widget
class PrettyRadio extends StatefulWidget {
  static const int DEFAULT_AXIS_CUTOFF = 3;
  static const Color DEFAULT_SELECTED_COLOR = Colors.blue;
  static const Color DEFAULT_UNSELECTED_COLOR = Colors.grey;

  final PrettyRadioController controller;
  final int itemCount;
  final PrettyRadioItem Function(int) builder;
  final Axis layoutAxis;

  PrettyRadio(
      {@required this.controller,
      @required List<PrettyRadioItem> items,
      Axis axis})
      : this.itemCount = items.length,
        this.builder = ((int index) => items[index]),
        this.layoutAxis = axis ?? items.length > DEFAULT_AXIS_CUTOFF
            ? Axis.vertical
            : Axis.horizontal;

  PrettyRadio.builder(
      {@required this.controller,
      @required this.itemCount,
      @required this.builder,
      Axis axis})
      : this.layoutAxis = axis ?? itemCount > DEFAULT_AXIS_CUTOFF
            ? Axis.vertical
            : Axis.horizontal;

  PrettyRadio.fromMap(
      {@required this.controller,
      @required Map<dynamic, String> map,
      Axis axis})
      : this.itemCount = map.length,
        this.builder = ((int index) {
          MapEntry<dynamic, String> entry = map.entries.elementAt(index);
          return PrettyRadioItem(id: entry.key, value: entry.value);
        }),
        this.layoutAxis = axis ?? map.length > DEFAULT_AXIS_CUTOFF
            ? Axis.vertical
            : Axis.horizontal;

  @override
  State<StatefulWidget> createState() => _PrettyRadioState();
}

/// State
class _PrettyRadioState extends State<PrettyRadio> {
  PrettyRadioItem getItem(int index) => widget.builder(index);

  @override
  void initState() {
    super.initState();

    if (widget.controller.id.isEmpty) widget.controller.id = getItem(0).id;
  }

  void onClick(PrettyRadioItem item) {
    if (item.id != widget.controller.id) {
      print("PrettyRadio - ${item.id}:${item.value}");
      setState(() => widget.controller.id = item.id);
    }
  }

  List<Widget> buildChildren({bool expanded = false}) =>
      List.generate(widget.itemCount, (e) => e).map((i) {
        PrettyRadioItem item = getItem(i);

        final radioItem = _PrettyRadioItem(
          onSelect: () => onClick(item),
          text: item.value,
          parentAxis: widget.layoutAxis,
          isSelected: item.id == widget.controller.id,
        );

        return expanded ? Expanded(child: Center(child: radioItem)) : radioItem;
      }).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return widget.layoutAxis == Axis.horizontal
        ? Row(children: buildChildren(expanded: true))
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildChildren(),
          );
  }
}

/// List Item Widget
class _PrettyRadioItem extends StatelessWidget {
  final String text;
  final Function() onSelect;
  final Axis parentAxis;
  final bool isSelected;

  _PrettyRadioItem({
    @required this.text,
    @required this.onSelect,
    @required this.parentAxis,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final textView = Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: this.isSelected
            ? DEFAULT_SELECTED_COLOR
            : DEFAULT_UNSELECTED_COLOR,
      ),
    );

    final circle = CircleAvatar(
      maxRadius: 4,
      backgroundColor: this.isSelected
          ? DEFAULT_SELECTED_COLOR
          : this.parentAxis == Axis.vertical
              ? DEFAULT_UNSELECTED_COLOR
              : Colors.transparent,
    );

    final buttonContents = this.parentAxis == Axis.horizontal
        ? Column(children: <Widget>[
            textView,
            SizedBox(height: 2),
            circle,
          ])
        : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            circle,
            SizedBox(width: 4),
            textView,
          ]);

    final button = Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: StyleValue.BLUE_FADED,
        onTap: this.onSelect,
        child: Container(
          padding: EdgeInsets.only(left: 4, right: 12, top: 4, bottom: 4),
          child: buttonContents,
        ),
      ),
    );

    return button;
  }
}
