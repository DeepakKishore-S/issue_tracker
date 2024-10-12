abstract class ApiStaus {}

class Success extends ApiStaus {
  final String code;
  final Object response;
  Success({
    required this.code,
    required this.response,
  });
}

class Failure extends ApiStaus {
  final String code;
  final String message;
  Failure({
    required this.code,
    required this.message,
  });
}
