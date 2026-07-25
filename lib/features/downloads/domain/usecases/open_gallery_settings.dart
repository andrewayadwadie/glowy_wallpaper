import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/download_repository.dart';

/// Sends the user to the OS app-settings page after the legacy storage
/// permission was permanently denied. Keeps the permission plumbing out of
/// the presentation layer, which only decides *when* to offer the route.
class OpenGallerySettings extends UseCase<void, NoParams> {
  final DownloadRepository repository;
  OpenGallerySettings(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.openGallerySettings();
}
