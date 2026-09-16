/// Standard envelope returned by all HTTP-backed clients.
class NetworkResponse<T> {
  const NetworkResponse({
    required this.data,
    this.statusCode = 200,
  });

  const NetworkResponse.failure({
    required this.statusCode,
  }) : data = null;

  final T? data;
  final int statusCode;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isFailure => !isSuccess;

  NetworkResponse<T> copyWith({T? data, int? statusCode}) =>
      NetworkResponse(data: data ?? this.data, statusCode: statusCode ?? this.statusCode);
}