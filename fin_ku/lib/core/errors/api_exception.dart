class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const {},
  });

  ApiException.network(this.statusCode)
      : message = 'Tidak dapat terhubung ke server. Periksa koneksi dan konfigurasi alamat API.',
        fieldErrors = const {};

  ApiException.unauthorized()
      : statusCode = 401,
        message = 'Sesi berakhir. Silakan login kembali.',
        fieldErrors = const {};

  /// Status HTTP dari response. -1 untuk kegagalan jaringan/dns.
  final int statusCode;
  final String message;

  /// Error validasi dari backend: { field: [pesan, ...] }
  final Map<String, List<String>> fieldErrors;

  String fieldError(String field) {
    final list = fieldErrors[field];
    return list == null || list.isEmpty ? '' : list.first;
  }

  @override
  String toString() => message;
}
