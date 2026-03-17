class ImportRadar {
  final String usdToCop;
  final String mensajeEstrategico;
  final String noticiaTitular;
  final String calculoRetorno;

  ImportRadar({
    required this.usdToCop,
    required this.mensajeEstrategico,
    required this.noticiaTitular,
    required this.calculoRetorno,
  });


factory ImportRadar.fromJson(Map<String, dynamic> json) {
    return ImportRadar(
      usdToCop: json['radar_divisas']['usd_to_cop'] ?? "0.00",
      mensajeEstrategico:
          json['radar_divisas']['mensaje_estrategico'] ?? "Consultando...",
      noticiaTitular:
          json['noticias_emprendimiento'][0]['titular'] ?? "Sin noticias",
      calculoRetorno:
          json['calculo_ejemplo']['retorno_mercancia_cop'] ?? "0 COP",
    );
  }
}
