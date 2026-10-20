import 'package:app_farmacia/services/database_service.dart';

class TelaLoginController {
  final DatabaseService _db = DatabaseService.instance;

  Future<bool> realizarLogin(String usuario, String senha) async {
    return await _db.autenticar(usuario, senha);
  }
}