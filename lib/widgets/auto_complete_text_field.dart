import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A textfield with search auto complete.
///
/// Use [onSearchTextChanges] to generate search results list.
///
/// [onResultSelected] Handles th result onclick action.
///
/// Use the [validator] to validate current selected value of the widget.
///
/// **Example**
/// ```
/// AutoCompleteTextField<Product>(
///   label: "Product",
///   itemView: (Product product) {
///     return product.name;
///   },
///   onResultSelected: (product) {
///     bloc.changeProduct(product);
///     if (bloc.product != null) {
///       _amounteditingController.text = bloc.amount.toString();
///     }
///   },
///   onSearchTextChanges: (value) async {
///     var data = await MainRepository.instance().searchitems(value);
///     return data.data;
///   },
/// );
///
/// ```
///
class AutoCompleteTextField<T> extends StatefulWidget {
  final Future<List<T>>? Function(String)? onSearchTextChanges;
  final void Function(T)? onResultSelected;
  final String Function(T) itemView;
  final InputDecoration? inputDecoration;
  final String? listTitle;
  final String? label;
  final String? Function(String?)? validator;
  final T? value;

  AutoCompleteTextField({
    this.onSearchTextChanges,
    this.onResultSelected,
    this.listTitle,
    this.validator,
    this.value,
    this.inputDecoration,
    required this.itemView,
    required this.label,
  });
  @override
  _AutoCompleteTextFieldState<T> createState() =>
      _AutoCompleteTextFieldState<T>();
}

class _AutoCompleteTextFieldState<T> extends State<AutoCompleteTextField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  TextEditingController? _textEditingController;
  String? _searchTerm;
  ValueNotifier<T>? _value;

  @override
  void initState() {
    _searchTerm = "";

    _textEditingController = TextEditingController();

    if (widget.value != null) {
      _value = ValueNotifier<T>(widget.value!);
      _textEditingController?.text = widget.itemView(widget.value!);
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (this._overlayEntry == null) {
          _overlayEntry = _createOverlayEntry([]);
          Overlay.of(context)?.insert(this._overlayEntry!);
        }
      } else {
        deleteOverlay();
      }
    });
    super.initState();
  }

  OverlayEntry _createOverlayEntry(List<T> items) {
    RenderBox? renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    double listHeight = items.length * (100 + 5.0);
    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        top: 0,
        right: 40,
        height: listHeight >= 200 ? 200 : listHeight,
        width: MediaQuery.of(context).size.width -
            (MediaQuery.of(context).size.width * 0.1),
        child: CompositedTransformFollower(
            link: this._layerLink,
            showWhenUnlinked: false,
            offset: Offset(size.height * 0.1, size.height * 0.8),
            child: Material(
                elevation: 4.0,
                child: Column(children: [
                  Container(
                    height: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                          ),
                          onPressed: () {
                            this._overlayEntry?.remove();
                            _overlayEntry = null;
                          },
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(widget.itemView(items[index])),
                      onTap: () {
                        this._overlayEntry?.remove();
                        _overlayEntry = null;
                        _textEditingController?.text =
                            widget.itemView(items[index]);
                        _value?.value = items[index];
                        widget.onResultSelected!(items[index]);
                      },
                    ),
                  ))
                ]))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        CompositedTransformTarget(
            link: _layerLink,
            child: Container(
                height: 50,
                child: TextFormField(
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  onFieldSubmitted: (value) {},
                  onEditingComplete: () {
                    _textEditingController?.text =
                        widget.itemView(_value!.value);
                  },
                  validator: widget.validator ??
                      (value) {
                        return _value?.value == null
                            ? "Please Select an item"
                            : null;
                      },
                  decoration: widget.inputDecoration ??
                      InputDecoration(
                        enabled: true,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.secondary,
                        helperText: " ",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                  onTap: () {},
                  onChanged: (String value) async {
                    value.trim();
                    if (_searchTerm == value) {
                      return;
                    }
                    _searchTerm = value;
                    if (_searchTerm == null) {
                      deleteOverlay();
                      return;
                    }
                    List<T> items = [];
                    items = await widget.onSearchTextChanges!(value)!;
                    _overlayEntry?.remove();
                    _overlayEntry = _createOverlayEntry(items);
                    Overlay.of(context)?.insert(this._overlayEntry!);
                  },
                )))
      ]);

  void deleteOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
