class AppRoutes {
  AppRoutes._();
  
  static const String splash = '/splash';
  static const String login = '/login';
  static const String turno = '/turno';
  static const String dashboard = '/dashboard';
  static const String nuevoServicio = '/servicios/nuevo';
  static const String clientes = '/clientes';
  static const String clienteNuevo = '/clientes/nuevo';
  static const String clienteDetalle = '/clientes/:id';
  static const String clienteEditar = '/clientes/:id/editar';
  static const String vehiculos = '/vehiculos';
  static const String vehiculoNuevo = '/vehiculos/nuevo';
  static const String vehiculoEditar = '/vehiculos/:id/editar';
  static const String servicios = '/servicios';
  static const String caja = '/caja';
  static const String gastos = '/gastos';
  static const String reportes = '/reportes';
  static const String configuracion = '/configuracion';
  static const String cierres = '/cierres';

  static String clienteDetalleFor(String id) => '/clientes/$id';
  static String clienteEditarFor(String id) => '/clientes/$id/editar';
  static String vehiculoEditarFor(String id) => '/vehiculos/$id/editar';
}
