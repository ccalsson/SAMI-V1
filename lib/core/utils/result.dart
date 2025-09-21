class Result<T> {
  const Result._(this.value, this.error);

  final T? value;
  final Object? error;

  bool get isSuccess => error == null;
  bool get isError => error != null;

  static Result<T> success<T>(T value) => Result._(value, null);
  static Result<T> failure<T>(Object error) => Result._(null, error);
}
