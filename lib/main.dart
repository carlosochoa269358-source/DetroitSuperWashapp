import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

// Se compilan en el código en tiempo de build (--dart-define-from-file=.env),
// en vez de cargarse en tiempo de ejecución desde un archivo .env. Un archivo
// .env servido como asset es frágil para despliegues estáticos (Netlify y
// similares pueden no subir archivos que empiezan con punto, o el navegador
// puede cachear una versión vieja/rota).
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty,
    'Faltan SUPABASE_URL/SUPABASE_ANON_KEY. Corre con --dart-define-from-file=.env',
  );

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const ProviderScope(child: DetroitApp()));
}
