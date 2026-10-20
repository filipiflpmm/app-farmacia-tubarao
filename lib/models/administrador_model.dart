import 'package:cloud_firestore/cloud_firestore.dart';

class AdministradorModel {
  String id;
  String nome;
  String cargo;
  String email;
  String usuario;
  String senha;

  AdministradorModel({
    required this.id,
    required this.nome,
    required this.cargo,
    required this.email,
    required this.usuario,
    required this.senha,
  });

  factory AdministradorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdministradorModel(
      id: doc.id,
      nome: data['nome'] ?? '',
      cargo: data['cargo'] ?? '',
      email: data['email'] ?? '',
      usuario: data['usuario'] ?? '',
      senha: data['senha'] ?? '',
    );
  }
}