class Machine {
  final String machineid;
  final String ip_address;

  Machine({required this.machineid,required this.ip_address});

  Map<String, Object?> toMap() {
    return {'machineid': machineid, 'ip_address': ip_address};
  }

  @override
  String toString() {
    return 'Machine{machineid: $machineid, ip_address: $ip_address';
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
  return Machine(
    machineid: map['machineid'],
    ip_address: map['ip_address'],
  );
}

}
