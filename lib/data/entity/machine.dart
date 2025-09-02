class Machine {
  final String machineid;
  final String ip_address;
  final int isTruckingOn;

  Machine({
    required this.machineid,
    required this.ip_address,
    required this.isTruckingOn,
  });

  Map<String, Object?> toMap() {
    return {
      'machineid': machineid,
      'ip_address': ip_address,
      'isTruckingOn': isTruckingOn,
    };
  }

  @override
  String toString() {
    return 'Machine{machineid: $machineid, ip_address: $ip_address, isTruckingOn:$isTruckingOn}';
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(machineid: map['machineid'], ip_address: map['ip_address'], isTruckingOn: map['isTruckingOn']);
  }
}
