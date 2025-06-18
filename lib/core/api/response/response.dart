// api_response.dart

/// Enum for HTTP status codes with readable names
enum ApiStatusCode {
  // Success codes (2xx)
  ok(200, 'OK'),
  created(201, 'Created'),
  accepted(202, 'Accepted'),
  noContent(204, 'No Content'),
  
  // Client error codes (4xx)
  badRequest(400, 'Bad Request'),
  unauthorized(401, 'Unauthorized'),
  forbidden(403, 'Forbidden'),
  notFound(404, 'Not Found'),
  methodNotAllowed(405, 'Method Not Allowed'),
  requestTimeout(408, 'Request Timeout'),
  conflict(409, 'Conflict'),
  unprocessableEntity(422, 'Unprocessable Entity'),
  tooManyRequests(429, 'Too Many Requests'),
  
  // Server error codes (5xx)
  internalServerError(500, 'Internal Server Error'),
  badGateway(502, 'Bad Gateway'),
  serviceUnavailable(503, 'Service Unavailable'),
  gatewayTimeout(504, 'Gateway Timeout'),
  
  // Custom/Unknown
  unknown(-1, 'Unknown Status');

  const ApiStatusCode(this.code, this.description);
  
  final int code;
  final String description;
  
  /// Get status code enum from integer value
  static ApiStatusCode fromCode(int code) {
    for (ApiStatusCode status in ApiStatusCode.values) {
      if (status.code == code) {
        return status;
      }
    }
    return ApiStatusCode.unknown;
  }
  
  /// Check if status code indicates success (2xx)
  bool get isSuccess => code >= 200 && code < 300;
  
  /// Check if status code indicates client error (4xx)
  bool get isClientError => code >= 400 && code < 500;
  
  /// Check if status code indicates server error (5xx)
  bool get isServerError => code >= 500 && code < 600;
  
  /// Check if status code indicates any error (4xx or 5xx)
  bool get isError => isClientError || isServerError;
}

/// Generic API Response model that can handle any type of data
class ApiResponse<T> {
  final T? data;
  final String message;
  final ApiStatusCode statusCode;
  final String? accessToken;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    this.data,
    required this.message,
    required this.statusCode,
    this.accessToken,
    this.metadata,
  });

  /// Factory constructor from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final statusCode = ApiStatusCode.fromCode(json['status'] ?? -1);
    
    T? parsedData;
    if (json['data'] != null && fromJsonT != null) {
      try {
        parsedData = fromJsonT(json['data']);
      } catch (e) {
        // If parsing fails, keep data as null
        parsedData = null;
      }
    }

    return ApiResponse<T>(
      data: parsedData,
      message: json['message'] ?? '',
      statusCode: statusCode,
      accessToken: json['access_token'],
      metadata: json.containsKey('metadata') ? json['metadata'] : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    final json = <String, dynamic>{
      'message': message,
      'status': statusCode.code,
    };

    if (data != null) {
      if (toJsonT != null) {
        json['data'] = toJsonT(data as T);
      } else {
        json['data'] = data;
      }
    }

    if (accessToken != null) {
      json['access_token'] = accessToken;
    }

    if (metadata != null) {
      json['metadata'] = metadata;
    }

    return json;
  }

  /// Check if the response is successful
  bool get isSuccess => statusCode.isSuccess;

  /// Check if the response has an error
  bool get isError => statusCode.isError;

  /// Check if the response is a client error
  bool get isClientError => statusCode.isClientError;

  /// Check if the response is a server error
  bool get isServerError => statusCode.isServerError;

  /// Get a user-friendly error message
  String get errorMessage {
    if (isSuccess) return '';
    
    // Return custom message if available, otherwise use status description
    if (message.isNotEmpty) {
      return message;
    }
    
    return statusCode.description;
  }

  /// Create a success response
  static ApiResponse<T> success<T>({
    T? data,
    String message = 'Success',
    ApiStatusCode statusCode = ApiStatusCode.ok,
    String? accessToken,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      data: data,
      message: message,
      statusCode: statusCode,
      accessToken: accessToken,
      metadata: metadata,
    );
  }

  /// Create an error response
  static ApiResponse<T> error<T>({
    String message = 'An error occurred',
    ApiStatusCode statusCode = ApiStatusCode.internalServerError,
    T? data,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      data: data,
      message: message,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  /// Create a response for network errors
  static ApiResponse<T> networkError<T>([String? customMessage]) {
    return ApiResponse<T>(
      data: null,
      message: customMessage ?? 'Network connection failed',
      statusCode: ApiStatusCode.serviceUnavailable,
    );
  }

  /// Create a response for timeout errors
  static ApiResponse<T> timeoutError<T>([String? customMessage]) {
    return ApiResponse<T>(
      data: null,
      message: customMessage ?? 'Request timeout',
      statusCode: ApiStatusCode.requestTimeout,
    );
  }

  /// Create a response for parsing errors
  static ApiResponse<T> parseError<T>([String? customMessage]) {
    return ApiResponse<T>(
      data: null,
      message: customMessage ?? 'Failed to parse response',
      statusCode: ApiStatusCode.internalServerError,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{data: $data, message: $message, statusCode: ${statusCode.code} (${statusCode.description}), accessToken: $accessToken}';
  }

  /// Copy with method for creating modified copies
  ApiResponse<T> copyWith({
    T? data,
    String? message,
    ApiStatusCode? statusCode,
    String? accessToken,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      data: data ?? this.data,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      accessToken: accessToken ?? this.accessToken,
      metadata: metadata ?? this.metadata,
    );
  }
}

