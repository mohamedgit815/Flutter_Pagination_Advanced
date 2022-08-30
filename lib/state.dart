import 'package:flutter/material.dart';


class MainState extends ChangeNotifier{

  /// Counter
  int count = 0;

  int countState(int v) {
    notifyListeners();
    return count = v;
  }
  /// Counter

  /// Value
  late String value = '';
  String funcChange(String v){
    notifyListeners() ;
    return value = v;
  }

  void equalNull(){
    value = '';
    notifyListeners();
  }
  /// Value


  /// VarSwitch
  bool varSwitch = true;

  bool funcSwitch() {
    notifyListeners();
    return varSwitch = !varSwitch;
  }

  bool trueSwitch(){
    notifyListeners();
    return varSwitch = true;
  }

  bool falseSwitch(){
    notifyListeners();
    return varSwitch = false;
  }
  /// VarSwitch



}