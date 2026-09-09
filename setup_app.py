import os

base_dir = r"C:\Users\userrepuestos\.gemini\antigravity\scratch\detroit_super_wash"

def write_file(rel_path, content):
    path = os.path.join(base_dir, rel_path)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# Update pubspec.yaml
pubspec_content = """name: detroit_super_wash
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.1

dependencies:
  flutter:
    sdk: flutter
  # Supabase
  supabase_flutter: ^2.8.4
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  hooks_riverpod: ^2.6.1
  flutter_hooks: ^0.21.2
  # Navigation
  go_router: ^15.1.1
  # Code generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  # Utils
  equatable: ^2.0.5
  dartz: ^0.10.1
  intl: ^0.20.2
  flutter_dotenv: ^5.2.1
  # UI
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.17
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  # Image
  image_picker: ^1.1.2
  flutter_image_compress: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.4
  riverpod_generator: ^2.6.2
  custom_lint: ^0.7.5
  riverpod_lint: ^2.6.2

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - .env
"""
write_file('pubspec.yaml', pubspec_content)

# Create .env
write_file('.env', """SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY
""")

# Append to .gitignore
gitignore_path = os.path.join(base_dir, '.gitignore')
if os.path.exists(gitignore_path):
    with open(gitignore_path, 'a') as f:
        f.write("\n.env\n")

# Asset dirs
os.makedirs(os.path.join(base_dir, 'assets', 'images'), exist_ok=True)
os.makedirs(os.path.join(base_dir, 'assets', 'icons'), exist_ok=True)
write_file('assets/images/.gitkeep', '')
write_file('assets/icons/.gitkeep', '')

# Constants
write_file('lib/core/constants/app_colors.dart', """import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Brand
  static const Color primary = Color(0xFFF5A623);      // Detroit Yellow
  static const Color primaryDark = Color(0xFFD4880A);   // Pressed/hover
  static const Color primaryLight = Color(0xFFF7C05A);  // Light variant
  
  // Background
  static const Color background = Color(0xFF0D0D0D);    // Main background
  static const Color surface = Color(0xFF1A1A1A);       // Cards
  static const Color surface2 = Color(0xFF242424);      // Inputs
  static const Color surface3 = Color(0xFF2E2E2E);      // Dividers area
  
  // Text
  static const Color onBackground = Color(0xFFFFFFFF);  // White text
  static const Color onSurface = Color(0xFFFFFFFF);     // White on cards
  static const Color textMuted = Color(0xFF9E9E9E);     // Secondary text
  static const Color textDisabled = Color(0xFF616161);  // Disabled
  
  // Semantic
  static const Color success = Color(0xFF4CAF50);  // PAGADO
  static const Color warning = Color(0xFFFF9800);  // POR COBRAR
  static const Color error = Color(0xFFF44336);    // CANCELADO/Error
  static const Color info = Color(0xFF2196F3);     // Informativo
  
  // Status colors for service orders
  static const Color statusNew = Color(0xFFF5A623);       // Nuevo - amarillo Detroit
  static const Color statusInProgress = Color(0xFF2196F3); // En progreso - azul
  static const Color statusFinished = Color(0xFF9C27B0);   // Finalizado - morado
  static const Color statusPaid = Color(0xFF4CAF50);       // Pagado - verde
  static const Color statusReceivable = Color(0xFFFF9800); // Por cobrar - naranja
  static const Color statusCancelled = Color(0xFFF44336);  // Cancelado - rojo
  
  // Divider
  static const Color divider = Color(0xFF333333);
  
  // Overlay
  static const Color overlay = Color(0x80000000);
}
""")

write_file('lib/core/constants/app_text_styles.dart', """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle heading1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static final TextStyle heading2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static final TextStyle heading3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static final TextStyle heading4 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static final TextStyle body1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );

  static final TextStyle body2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static final TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
  );
}
""")

write_file('lib/core/constants/app_constants.dart', """class AppConstants {
  AppConstants._();
  static const String appName = 'Detroit Súper Wash';
  static const String companyDocument = '1020456810';
  static const String timezone = 'America/Bogota';
  static const int maxPhotosPerOrder = 5;
  static const double defaultCommissionPct = 40.0;
  static const String orderPrefix = 'DSW';
  
  // Payment methods
  static const String pmEfectivo = 'efectivo';
  static const String pmTransferencia = 'transferencia';
  static const String pmNequi = 'nequi';
  static const String pmDaviplata = 'daviplata';
  static const String pmTarjetaDebito = 'tarjeta_debito';
  static const String pmTarjetaCredito = 'tarjeta_credito';
  static const String pmPse = 'pse';
  
  // Order statuses  
  static const String statusNew = 'new';
  static const String statusInProgress = 'in_progress';
  static const String statusFinished = 'finished';
  static const String statusPaid = 'paid';
  static const String statusReceivable = 'receivable';
  static const String statusCancelled = 'cancelled';
  
  // User roles
  static const String roleAdminGeneral = 'admin_general';
  static const String roleAdminPunto = 'admin_punto';
  static const String roleOperador = 'operador';
}
""")

write_file('lib/core/constants/app_routes.dart', """class AppRoutes {
  AppRoutes._();
  
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String clientes = '/clientes';
  static const String vehiculos = '/vehiculos';
  static const String servicios = '/servicios';
  static const String caja = '/caja';
  static const String gastos = '/gastos';
  static const String reportes = '/reportes';
  static const String configuracion = '/configuracion';
  static const String cierres = '/cierres';
}
""")

# Errors
write_file('lib/core/errors/failures.dart', """abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}
""")

write_file('lib/core/errors/app_exception.dart', """class AppException implements Exception {
  final String code;
  final String message;
  
  const AppException({required this.code, required this.message});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
""")

# Theme
write_file('lib/core/theme/app_theme.dart', """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onBackground,
        onSecondary: AppColors.onBackground,
        onSurface: AppColors.onSurface,
        onBackground: AppColors.onBackground,
        onError: AppColors.onBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
        hintStyle: GoogleFonts.inter(color: AppColors.textDisabled),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface2,
        labelStyle: GoogleFonts.inter(color: AppColors.onBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
""")

# Utils
write_file('lib/core/utils/currency_formatter.dart', """import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static double parse(String text) {
    String cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return 0.0;
    return double.parse(cleanText);
  }
}
""")

write_file('lib/core/utils/date_formatter.dart', """import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime dt) {
    final bogotaTime = dt.toUtc().subtract(const Duration(hours: 5));
    return DateFormat('dd/MM/yyyy').format(bogotaTime);
  }

  static String formatDateTime(DateTime dt) {
    final bogotaTime = dt.toUtc().subtract(const Duration(hours: 5));
    return DateFormat('dd/MM/yyyy HH:mm').format(bogotaTime);
  }

  static String formatTime(DateTime dt) {
    final bogotaTime = dt.toUtc().subtract(const Duration(hours: 5));
    return DateFormat('HH:mm').format(bogotaTime);
  }

  static DateTime todayBogota() {
    return DateTime.now().toUtc().subtract(const Duration(hours: 5));
  }
}
""")

write_file('lib/core/utils/validators.dart', """class Validators {
  Validators._();

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^3\d{9}$');
    if (!regex.hasMatch(value)) {
      return 'Formato de teléfono inválido (ej: 3001234567)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Correo electrónico inválido';
    }
    return null;
  }

  static String? validatePlate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[a-zA-Z]{3}[0-9]{2}[a-zA-Z0-9]{1}$');
    if (!regex.hasMatch(value)) {
      return 'Placa inválida (ej: ABC123, ABC12D)';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(cleanValue);
    if (amount == null || amount <= 0) {
      return 'Monto inválido';
    }
    return null;
  }
}
""")

# Entities
write_file('lib/domain/entities/user_entity.dart', """class UserEntity {
  final String id;
  final String companyId;
  final String roleId;
  final String roleName; 
  final String fullName;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.companyId,
    required this.roleId,
    required this.roleName,
    required this.fullName,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdminGeneral => roleName == 'admin_general';
  bool get isAdminPunto => roleName == 'admin_punto';
  bool get isOperador => roleName == 'operador';
}
""")

write_file('lib/domain/entities/company_entity.dart', """class CompanyEntity {
  final String id;
  final String document;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  CompanyEntity({
    required this.id,
    required this.document,
    required this.name,
    this.address,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });
}
""")

write_file('lib/domain/repositories/auth_repository.dart', """import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password});
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
""")

write_file('lib/domain/usecases/sign_in_usecase.dart', """import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
""")

write_file('lib/domain/usecases/sign_out_usecase.dart', """import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
""")

write_file('lib/domain/usecases/get_current_user_usecase.dart', """import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() {
    return repository.getCurrentUser();
  }
}
""")

write_file('lib/data/models/user_model.dart', """import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.companyId,
    required super.roleId,
    required super.roleName,
    required super.fullName,
    super.email,
    super.phone,
    required super.isActive,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      roleId: json['role_id'] as String,
      roleName: json['role_name'] as String? ?? 'operador',
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'role_id': roleId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
""")

write_file('lib/data/models/company_model.dart', """import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  CompanyModel({
    required super.id,
    required super.document,
    required super.name,
    super.address,
    super.phone,
    required super.isActive,
    required super.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      document: json['document'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document': document,
      'name': name,
      'address': address,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
""")

write_file('lib/data/datasources/auth_datasource.dart', """import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserModel> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw Exception('Login failed');
    }
    
    final userData = await _client
        .from('users')
        .select('*, roles:role_id(name)')
        .eq('id', user.id)
        .single();

    userData['role_name'] = userData['roles']['name'];
    return UserModel.fromJson(userData);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final userData = await _client
          .from('users')
          .select('*, roles:role_id(name)')
          .eq('id', user.id)
          .single();

      userData['role_name'] = userData['roles']['name'];
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;
      return await getCurrentUser();
    });
  }
}
""")

write_file('lib/data/repositories/auth_repository_impl.dart', """import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> signIn({required String email, required String password}) async {
    try {
      final user = await dataSource.signIn(email, password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => dataSource.authStateChanges;
}
""")

write_file('lib/presentation/providers/auth_provider.dart', """import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

part 'auth_provider.g.dart';

@riverpod
AuthDataSource authDataSource(AuthDataSourceRef ref) => AuthDataSource();

@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
}

@riverpod
SignInUseCase signInUseCase(SignInUseCaseRef ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SignOutUseCase signOutUseCase(SignOutUseCaseRef ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(GetCurrentUserUseCaseRef ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
Stream<UserEntity?> authStateChanges(AuthStateChangesRef ref) {
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
""")

write_file('lib/presentation/pages/splash/splash_page.dart', """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateChangesProvider, (previous, next) {
      if (next.hasData) {
        if (next.value != null) {
          context.go(AppRoutes.dashboard);
        } else {
          context.go(AppRoutes.login);
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Detroit', style: AppTextStyles.heading1.copyWith(color: AppColors.primary)),
            Text('Súper Wash', style: AppTextStyles.heading2),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
""")

write_file('lib/presentation/pages/auth/login_page.dart', """import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/detroit_button.dart';
import '../../widgets/common/detroit_text_field.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Detroit Súper Wash',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lavadero de autos y motos',
                    style: AppTextStyles.body1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (authState.hasError) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        authState.error.toString(),
                        style: AppTextStyles.body2.copyWith(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  DetroitTextField(
                    controller: emailController,
                    label: 'Correo Electrónico',
                    hint: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  DetroitTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    isPassword: true,
                    validator: Validators.validateRequired,
                  ),
                  const SizedBox(height: 32),
                  DetroitButton(
                    text: 'INICIAR SESIÓN',
                    isLoading: authState.isLoading,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ref.read(authNotifierProvider.notifier).signIn(
                              emailController.text.trim(),
                              passwordController.text,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
""")

write_file('lib/presentation/pages/dashboard/dashboard_page.dart', """import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/detroit_app_bar.dart';
import '../../widgets/dashboard/stat_card_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: DetroitAppBar(
        title: 'Detroit Súper Wash',
        onLogout: () => ref.read(authNotifierProvider.notifier).signOut(),
        userName: user?.fullName,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatDate(DateFormatter.todayBogota()),
                  style: AppTextStyles.heading4,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Text(
                    'Turno: Abierto',
                    style: AppTextStyles.label.copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  StatCardWidget(
                    title: 'Nuevas',
                    value: '0',
                    color: AppColors.statusNew,
                    icon: Icons.new_releases,
                  ),
                  StatCardWidget(
                    title: 'Finalizadas',
                    value: '0',
                    color: AppColors.statusFinished,
                    icon: Icons.check_circle,
                  ),
                  StatCardWidget(
                    title: 'Por Cobrar',
                    value: '\$0',
                    color: AppColors.statusReceivable,
                    icon: Icons.payment,
                  ),
                  StatCardWidget(
                    title: 'Ventas del día',
                    value: '\$0',
                    color: AppColors.success,
                    icon: Icons.attach_money,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Operación'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}
""")

write_file('lib/presentation/widgets/common/detroit_button.dart', """import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum DetroitButtonType { primary, secondary, danger }

class DetroitButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final DetroitButtonType type;
  final bool fullWidth;

  const DetroitButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = DetroitButtonType.primary,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;

    switch (type) {
      case DetroitButtonType.primary:
        bgColor = AppColors.primary;
        fgColor = AppColors.background;
        break;
      case DetroitButtonType.secondary:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        break;
      case DetroitButtonType.danger:
        bgColor = AppColors.error;
        fgColor = AppColors.onBackground;
        break;
    }

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Text(
            text,
            style: AppTextStyles.label.copyWith(color: fgColor),
          );

    Widget button;
    if (type == DetroitButtonType.secondary) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: content,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: bgColor.withOpacity(0.5),
        ),
        child: content,
      );
    }

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
""")

write_file('lib/presentation/widgets/common/detroit_text_field.dart', """import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/constants/app_colors.dart';

class DetroitTextField extends HookWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;

  const DetroitTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final obscureText = useState(isPassword);

    return TextFormField(
      controller: controller,
      obscureText: obscureText.value,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText.value ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  obscureText.value = !obscureText.value;
                },
              )
            : null,
      ),
    );
  }
}
""")

write_file('lib/presentation/widgets/common/detroit_card.dart', """import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DetroitCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  const DetroitCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: accentColor != null 
            ? Border(left: BorderSide(color: accentColor!, width: 4))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
""")

write_file('lib/presentation/widgets/common/detroit_app_bar.dart', """import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class DetroitAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;
  final String? userName;

  const DetroitAppBar({
    super.key,
    required this.title,
    this.onLogout,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
      actions: [
        if (userName != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(userName!, style: AppTextStyles.body2),
            ),
          ),
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: onLogout,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.primary,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
""")

write_file('lib/presentation/widgets/common/loading_widget.dart', """import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
""")

write_file('lib/presentation/widgets/dashboard/stat_card_widget.dart', """import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../common/detroit_card.dart';

class StatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DetroitCard(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.body2),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: AppColors.onBackground),
          ),
        ],
      ),
    );
  }
}
""")

write_file('lib/app.dart', """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/providers/auth_provider.dart';

class DetroitApp extends ConsumerWidget {
  const DetroitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final isAuth = authState.value != null;
        final isSplash = state.uri.toString() == AppRoutes.splash;
        final isLogin = state.uri.toString() == AppRoutes.login;

        if (authState.isLoading) return null;

        if (!isAuth && !isLogin && !isSplash) {
          return AppRoutes.login;
        }

        if (isAuth && (isLogin || isSplash)) {
          return AppRoutes.dashboard;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
""")

write_file('lib/main.dart', """import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const ProviderScope(child: DetroitApp()));
}
""")
