import 'package:app_farmacia/services/database_service.dart';

class TelaInicialController {
  final DatabaseService _db = DatabaseService.instance;
  Stream<String> get streamDataPublicacao => _db.escutarDataPublicacao();
  bool get isLogado => _db.isLogado;
}