import 'package:app_farmacia/models/medicamento_model.dart';
import 'package:app_farmacia/services/database_service.dart';

class TelaConsultaController {
  final DatabaseService _db = DatabaseService.instance;

  Stream<List<MedicamentoModel>> escutarECalcularFiltros({
    required String filtroTipo,
    required String textoBusca,
  }) {
    return _db.escutarMedicamentosPublicos().map((lista) {
      return lista.where((med) {
        bool atendeFiltro = true;
        if (filtroTipo == 'FALTA') {
          atendeFiltro = med.flgEstoque == 'F';
        } else if (filtroTipo == 'BAIXO') {
          atendeFiltro = med.flgEstoque == 'B';
        } else if (filtroTipo == 'FARM_POP') {
          atendeFiltro = med.flgFarmPop == 'S';
        }

        bool atendeBusca = true;
        if (textoBusca.trim().length >= 4) {
          final nomeCompleto = "${med.nome} ${med.dosagem}".toLowerCase();
          atendeBusca = nomeCompleto.contains(textoBusca.trim().toLowerCase());
        }

        return atendeFiltro && atendeBusca;
      }).toList();
    });
  }
}