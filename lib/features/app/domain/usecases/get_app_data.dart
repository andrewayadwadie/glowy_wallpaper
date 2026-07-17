import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_metadata_entity.dart';
import '../repositories/app_repository.dart';

class GetAppData extends UseCase<AppMetadataEntity, NoParams> {
  final AppRepository repository;
  GetAppData(this.repository);

  @override
  Future<Either<Failure, AppMetadataEntity>> call(NoParams params) =>
      repository.getAppData();
}
