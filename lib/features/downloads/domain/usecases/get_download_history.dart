import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/download_record_entity.dart';
import '../repositories/download_repository.dart';

class GetDownloadHistory extends UseCase<List<DownloadRecordEntity>, NoParams> {
  final DownloadRepository repository;
  GetDownloadHistory(this.repository);

  @override
  Future<Either<Failure, List<DownloadRecordEntity>>> call(NoParams params) =>
      repository.getDownloadHistory();
}
