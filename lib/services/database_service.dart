import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_farmacia/models/medicamento_model.dart';
import 'package:app_farmacia/models/administrador_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdministradorModel? usuarioLogado;
  bool get isLogado => usuarioLogado != null;

  Future<void> inicializarDadosSeVazio() async {
    try {
      final snapshotConfig = await _firestore.collection('configuracoes').doc('geral').get();
      if (!snapshotConfig.exists) {
        await _firestore.collection('configuracoes').doc('geral').set({
          'data_publicacao': '11 de Outubro de 2026',
        });
      }

      final snapshotAdmins = await _firestore.collection('administradores').get();
      if (snapshotAdmins.docs.isEmpty) {
        await _firestore.collection('administradores').add({
          'nome': 'Paulo Martins',
          'cargo': 'Coordenador',
          'email': 'paulo.martins@tubarao.sc.gov.br',
          'usuario': 'admin',
          'senha': '123',
          'flg_ativo': 'A',
        });
      }

      final snapshotMeds = await _firestore.collection('medicamentos').get();
      if (snapshotMeds.docs.isEmpty) {
        await _firestore.collection('medicamentos').add({
          'nome': 'Paracetamol',
          'dosagem': '500mg',
          'flg_ativo': 'A',
          'flg_estoque': 'D',
          'flg_farm_pop': 'N',
          'flg_excluido': 'N',
          'justificativa_falta': null,
          'ultima_atualizacao': Timestamp.now(),
        });
        await _firestore.collection('medicamentos').add({
          'nome': 'Sertralina, cloridrato',
          'dosagem': '50mg',
          'flg_ativo': 'A',
          'flg_estoque': 'F',
          'flg_farm_pop': 'N',
          'flg_excluido': 'N',
          'justificativa_falta': 'Aguardando entrega do fornecedor',
          'ultima_atualizacao': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint("Erro ao inicializar dados padrão: $e");
    }
  }

  Stream<String> escutarDataPublicacao() {
    return _firestore
        .collection('configuracoes')
        .doc('geral')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('data_publicacao')) {
        return snapshot.data()!['data_publicacao'] as String;
      }
      return "11 de Outubro de 2026";
    });
  }

  // Função auxiliar para remover acentos na hora de ordenar
  String _removerAcentos(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    String resultado = texto;
    for (int i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado.toLowerCase();
  }

// Escutar Medicamentos Públicos (Ordenados A-Z considerando acentuação brasileira)
  Stream<List<MedicamentoModel>> escutarMedicamentosPublicos() {
    return _firestore
        .collection('medicamentos')
        .where('flg_excluido', isEqualTo: 'N')
        .where('flg_ativo', isEqualTo: 'A')
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => MedicamentoModel.fromFirestore(doc))
          .toList();

      lista.sort((a, b) {
        final nomeA = _removerAcentos(a.nome);
        final nomeB = _removerAcentos(b.nome);
        return nomeA.compareTo(nomeB);
      });

      return lista;
    });
  }

  // Escutar Medicamentos Painel Admin (Ordenados A-Z considerando acentuação brasileira)
  Stream<List<MedicamentoModel>> escutarMedicamentosAdmin() {
    return _firestore
        .collection('medicamentos')
        .where('flg_excluido', isEqualTo: 'N')
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => MedicamentoModel.fromFirestore(doc))
          .toList();

      lista.sort((a, b) {
        final nomeA = _removerAcentos(a.nome);
        final nomeB = _removerAcentos(b.nome);
        return nomeA.compareTo(nomeB);
      });

      return lista;
    });
  }

  Future<void> salvarMedicamento(MedicamentoModel med) async {
    if (med.docId.isEmpty) {
      await _firestore.collection('medicamentos').add(med.toMap());
    } else {
      await _firestore
          .collection('medicamentos')
          .doc(med.docId)
          .update(med.toMap());
    }
  }

  Future<void> excluirMedicamento(String docId) async {
    await _firestore
        .collection('medicamentos')
        .doc(docId)
        .update({'flg_excluido': 'S'});
  }

  Future<void> publicarDataAtual() async {
    final agora = DateTime.now();
    final dataFormatada =
        "${agora.day} de ${_obterNomeMes(agora.month)} de ${agora.year}";

    await _firestore.collection('configuracoes').doc('geral').set({
      'data_publicacao': dataFormatada,
    }, SetOptions(merge: true));
  }

  Future<bool> autenticar(String usuario, String senha) async {
    try {
      final query = await _firestore
          .collection('administradores')
          .where('usuario', isEqualTo: usuario.trim())
          .where('senha', isEqualTo: senha.trim())
          .where('flg_ativo', isEqualTo: 'A')
          .get();

      if (query.docs.isNotEmpty) {
        usuarioLogado = AdministradorModel.fromFirestore(query.docs.first);
        return true;
      }
    } catch (e) {
      debugPrint("Erro na autenticação: $e");
    }
    return false;
  }

  String _obterNomeMes(int mes) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return meses[mes - 1];
  }
}