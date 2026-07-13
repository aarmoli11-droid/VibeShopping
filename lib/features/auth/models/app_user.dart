// ======================================================
// Archivo: features/auth/models/app_user.dart
// Responsabilidad: Definir la estructura del usuario
//   autenticado dentro de la aplicación
// Qué hace: Declara los campos que representan a un
//   usuario (id, email, nombre, foto) y los expone
//   como un modelo inmutable
// Quién lo utiliza: AuthProvider, SupabaseAuthService,
//   ProfileView
//
// Flujo dentro de la aplicación:
//   1. SupabaseAuthService recibe un User de Supabase
//   2. Lo convierte a AppUser con _mapUser()
//   3. AuthProvider guarda AppUser y lo expone a los
//      widgets mediante context.watch()
//   4. Los widgets leen AppUser para mostrar datos
//      del usuario en el drawer, chat, etc.
//
// Conceptos utilizados:
//   - Modelo de datos: clase simple con solo campos
//   - Inmutabilidad: todos los campos son final, no
//     se pueden modificar después de crear el objeto
//   - Desacoplamiento: AppUser es nuestro propio tipo,
//     no depende del SDK de Supabase. Si cambiamos de
//     proveedor de auth, solo cambia SupabaseAuthService
// ======================================================

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
