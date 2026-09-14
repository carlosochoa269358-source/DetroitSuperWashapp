import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/cash_register_entity.dart';
import 'domain/entities/customer_entity.dart';
import 'domain/entities/vehicle_entity.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/clientes/cliente_detail_page.dart';
import 'presentation/pages/clientes/cliente_form_page.dart';
import 'presentation/pages/clientes/clientes_list_page.dart';
import 'presentation/pages/configuracion/configuracion_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/operacion/cliente_vehiculo_page.dart';
import 'presentation/pages/operacion/orden_detalle_page.dart';
import 'presentation/pages/operacion/seleccionar_servicio_page.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/turno/turno_historial_detalle_page.dart';
import 'presentation/pages/turno/turno_historial_page.dart';
import 'presentation/pages/turno/turno_page.dart';
import 'presentation/pages/vehiculos/buscar_placa_page.dart';
import 'presentation/pages/vehiculos/vehiculo_form_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cash_register_provider.dart';

class DetroitApp extends ConsumerWidget {
  const DetroitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    // Se usa el turno abierto (sin importar el día en que se abrió) para
    // decidir si se puede entrar al resto de la app. Si solo se mirara el
    // turno de HOY, un turno viejo sin cerrar dejaba al usuario sin salida:
    // la app lo mandaba a "/turno" a cerrarlo, pero cerrarlo requiere
    // resolver órdenes pendientes desde Operación — a la que no se podía
    // llegar porque la propia redirección lo devolvía a "/turno".
    final turnoAsync = ref.watch(anyOpenCashRegisterProvider);

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final isAuth = authState.value != null;
        final isSplash = state.uri.toString() == AppRoutes.splash;
        final isLogin = state.uri.toString() == AppRoutes.login;
        final isTurno = state.uri.toString() == AppRoutes.turno;

        if (authState.isLoading) return null;

        if (!isAuth && !isLogin && !isSplash) {
          return AppRoutes.login;
        }

        if (isAuth && (isLogin || isSplash)) {
          return AppRoutes.dashboard;
        }

        if (isAuth && !turnoAsync.isLoading) {
          final hasOpenTurno = turnoAsync.value != null;
          if (!hasOpenTurno && !isTurno) return AppRoutes.turno;
          if (hasOpenTurno && isTurno) return AppRoutes.dashboard;
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
          path: AppRoutes.turno,
          builder: (context, state) => const TurnoPage(),
        ),
        GoRoute(
          path: AppRoutes.turnoHistorial,
          builder: (context, state) => const TurnoHistorialPage(),
        ),
        GoRoute(
          path: AppRoutes.turnoHistorialDetalle,
          builder: (context, state) => TurnoHistorialDetallePage(register: state.extra as CashRegisterEntity),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.nuevoServicio,
          builder: (context, state) => const ClienteVehiculoPage(),
        ),
        GoRoute(
          path: AppRoutes.seleccionarServicio,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return SeleccionarServicioPage(
              customerId: data['customerId'] as String,
              vehicleId: data['vehicleId'] as String,
              vehicleTypeId: data['vehicleTypeId'] as String?,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.ordenDetalle,
          builder: (context, state) => OrdenDetallePage(
            orderId: state.pathParameters['id']!,
            vehicleTypeId: state.extra as String,
          ),
        ),
        GoRoute(
          path: AppRoutes.clientes,
          builder: (context, state) => const ClientesListPage(),
        ),
        GoRoute(
          path: AppRoutes.clienteNuevo,
          builder: (context, state) => const ClienteFormPage(),
        ),
        GoRoute(
          path: AppRoutes.clienteDetalle,
          builder: (context, state) => ClienteDetailPage(customerId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: AppRoutes.clienteEditar,
          builder: (context, state) => ClienteFormPage(customer: state.extra as CustomerEntity?),
        ),
        GoRoute(
          path: AppRoutes.vehiculos,
          builder: (context, state) => const BuscarPlacaPage(),
        ),
        GoRoute(
          path: AppRoutes.vehiculoNuevo,
          builder: (context, state) => VehiculoFormPage(customerId: state.extra as String),
        ),
        GoRoute(
          path: AppRoutes.vehiculoEditar,
          builder: (context, state) {
            final vehicle = state.extra as VehicleEntity;
            return VehiculoFormPage(customerId: vehicle.customerId, vehicle: vehicle);
          },
        ),
        GoRoute(
          path: AppRoutes.configuracion,
          builder: (context, state) => const ConfiguracionPage(),
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
