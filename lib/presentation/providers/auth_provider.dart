import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

part 'auth_provider.g.dart';

@riverpod
AuthDataSource authDataSource(Ref ref) => AuthDataSource();

@riverpod
AuthRepositoryImpl authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
}

@riverpod
SignInUseCase signInUseCase(Ref ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
Stream<UserEntity?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserEntity?> build() async {
    final usecase = ref.watch(getCurrentUserUseCaseProvider);
    final result = await usecase();
    return result.fold((l) => null, (r) => r);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(signInUseCaseProvider);
    final result = await usecase(email: email, password: password);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    final usecase = ref.read(signOutUseCaseProvider);
    await usecase();
    state = const AsyncValue.data(null);
  }
}
