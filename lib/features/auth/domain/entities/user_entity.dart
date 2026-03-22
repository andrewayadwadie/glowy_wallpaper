import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final bool isPremium;

  const UserEntity({
    required this.id,
    required this.displayName,
    required this.email,
    required this.isPremium,
  });

  @override
  List<Object?> get props => [id, displayName, email, isPremium];
}
