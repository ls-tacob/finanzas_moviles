class ImportRadar {
  final String usdToCop;
  final String mensajeEstrategico;

  ImportRadar({required this.usdToCop, required this.mensajeEstrategico});

  factory ImportRadar.fromJson(Map<String, dynamic> json) {
    return ImportRadar(
      usdToCop: json['usdToCop'] ?? '0.00',
      mensajeEstrategico: json['mensajeEstrategico'] ?? 'Sin información',
    );
  }

  Map<String, dynamic> toJson() {
    return {'usdToCop': usdToCop, 'mensajeEstrategico': mensajeEstrategico};
  }
}
