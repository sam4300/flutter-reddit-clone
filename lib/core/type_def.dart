import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/models/failure_model.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;