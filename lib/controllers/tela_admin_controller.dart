import 'package:app_farmacia/models/medicamento_model.dart';
import 'package:app_farmacia/services/database_service.dart';

class TelaAdminController {
  final DatabaseService _db = DatabaseService.instance;

  Stream<List<MedicamentoModel>> escutarTodosMedicamentos() =>
      _db.escutarMedicamentosAdmin();

  String get nomeUsuarioLogado => _db.usuarioLogado?.nome ?? 'Administrador';
  String get usuarioLogado => _db.usuarioLogado?.usuario ?? 'admin';
  String get emailUsuarioLogado =>
      _db.usuarioLogado?.email ?? 'admin@tubarao.sc.gov.br';

  void realizarLogout() => _db.usuarioLogado = null;

  Future<void> excluirMedicamento(String docId) async {
    await _db.excluirMedicamento(docId);
  }

  Future<void> publicarDataAtual() async {
    await _db.publicarDataAtual();
  }
}