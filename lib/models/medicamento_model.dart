import 'package:cloud_firestore/cloud_firestore.dart';

class MedicamentoModel {
  String docId;
  String nome;
  String dosagem;
  String flgAtivo; // 'A' = Ativo, 'I' = Inativo
  String flgEstoque; // 'D' = Disponível, 'F' = Em Falta, 'B' = Estoque Baixo
  String flgFarmPop; // 'S' = Sim, 'N' = Não
  String flgExcluido; // 'S' = Sim, 'N' = Não
  String? justificativaFalta;
  DateTime ultimaAtualizacao;

  MedicamentoModel({
    this.docId = '',
    required this.nome,
    required this.dosagem,
    required this.flgAtivo,
    required this.flgEstoque,
    required this.flgFarmPop,
    this.flgExcluido = 'N',
    this.justificativaFalta,
    required this.ultimaAtualizacao,
  });

  factory MedicamentoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicamentoModel(
      docId: doc.id,
      nome: data['nome'] ?? '',
      dosagem: data['dosagem'] ?? '',
      flgAtivo: data['flg_ativo'] ?? 'A',
      flgEstoque: data['flg_estoque'] ?? 'D',
      flgFarmPop: data['flg_farm_pop'] ?? 'N',
      flgExcluido: data['flg_excluido'] ?? 'N',
      justificativaFalta: data['justificativa_falta'],
      ultimaAtualizacao: (data['ultima_atualizacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dosagem': dosagem,
      'flg_ativo': flgAtivo,
      'flg_estoque': flgEstoque,
      'flg_farm_pop': flgFarmPop,
      'flg_excluido': flgExcluido,
      'justificativa_falta': justificativaFalta,
      'ultima_atualizacao': Timestamp.fromDate(ultimaAtualizacao),
    };
  }
}