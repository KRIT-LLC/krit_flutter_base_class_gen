import 'package:flutter/cupertino.dart';
import 'base_view_model.dart';

class BaseSearchViewModel extends BaseViewModel {
  BaseSearchViewModel(
      {TextEditingController? controller,
      Function(String?)? onSearch,
      this.blockUI})
      : super(blockUI: blockUI) {
    if (controller != null) {
      searchController = controller;
    }
    if (onSearch != null) {
      searchController.addListener(() => onSearch(searchController.text));
    }
  }

  @override
  final Function(bool)? blockUI;

  final FocusNode node = FocusNode();
  TextEditingController searchController = TextEditingController();
  bool searchEnabled = false;
  bool clearEnabled = false;
  int valuesCount = 0;

  void updateClearEnabled() {
    clearEnabled == searchController.text.isNotEmpty;
    notifyListeners();
  }

  void unfocusSearch({bool needUpdate = false}) {
    node.unfocus();
    searchEnabled = false;
    if (needUpdate) {
      notifyListeners();
    }
  }

  void setSearchEnabled() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchEnabled = !searchEnabled;
      searchController.clear();
      if (searchEnabled) {
        node.requestFocus();
      } else {
        unfocusSearch();
      }
      notifyListeners();
    });
  }

  String? updateText(String? text) {
    notifyListeners();
    return text;
  }
}
