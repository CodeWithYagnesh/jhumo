extension NewPrintMethod on Object {
  void get toPrint => print("Yagnesh MSG: ${this} \nStack: ${StackTrace.current}");
}
