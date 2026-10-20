import 'package:app_farmacia/models/medicamento_model.dart';
import 'package:app_farmacia/services/database_service.dart';

class TelaAtualizacaoController {
  final DatabaseService _db = DatabaseService.instance;

  Future<void> salvarMedicamento(MedicamentoModel med) async {
    await _db.salvarMedicamento(med);
  }
}