class Employee {
  final String employeeid;
  final String employeename;
  final String employeerole;
  final String employeecard;

  Employee(this.employeeid, this.employeename, this.employeerole, this.employeecard);

  @override
  String toString() {
    return 'Employee{employeeid: $employeeid, employeename: $employeename, employeerole: $employeerole, employeecard: $employeecard}';
  }
}
