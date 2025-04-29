class Machine {
  final String machineid;
  final String ip_address;
  final bool onlyLocal;

  Machine({required this.machineid,required this.ip_address, required this.onlyLocal});

  Map<String, Object?> toMap() {
    return {'machineid': machineid, 'ip_address': ip_address, 'onlyLocal': onlyLocal ? 1 : 0};
  }

  @override
  String toString() {
    return 'Machine{machineid: $machineid, ip_address: $ip_address, onlyLocal: $onlyLocal}';
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
  return Machine(
    machineid: map['machineid'],
    ip_address: map['ip_address'],
    onlyLocal: (map['onlyLocal'] ?? 0) == 1, 
  );
}

}
