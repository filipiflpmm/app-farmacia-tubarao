import 'package:flutter/material.dart';
import 'package:app_farmacia/controllers/tela_admin_controller.dart';
import 'package:app_farmacia/models/medicamento_model.dart';

class TelaAdminView extends StatefulWidget {
  const TelaAdminView({super.key});

  @override
  State<TelaAdminView> createState() => _TelaAdminViewState();
}

class _TelaAdminViewState extends State<TelaAdminView> {
  final TelaAdminController _controller = TelaAdminController();

  void _confirmarExclusao(MedicamentoModel med) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar exclusão?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              'Deseja realmente excluir o medicamento "${med.nome} ${med.dosagem}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Não', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _controller.excluirMedicamento(med.docId);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Medicamento excluído com sucesso!')),
                  );
                }
              },
              child: const Text('Sim', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmarPublicacao() {
    final agora = DateTime.now();
    final dataFormatada = "${agora.day}/${agora.month}/${agora.year}";

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Publicar Atualização',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              'Deseja publicar uma atualização na data atual ($dataFormatada)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Não', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366)),
              onPressed: () async {
                await _controller.publicarDataAtual();
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Data de atualização publicada no Firebase para $dataFormatada!'),
                      backgroundColor: Colors.green.shade800,
                    ),
                  );
                }
              },
              child: const Text('Sim', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF003366)),
              accountName: Text('Olá, ${_controller.nomeUsuarioLogado}'),
              accountEmail: Text(_controller.emailUsuarioLogado),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF003366)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Sair (Logout)'),
              onTap: () {
                _controller.realizarLogout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar Novo Medicamento'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/atualizacao');
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<List<MedicamentoModel>>(
                  stream: _controller.escutarTodosMedicamentos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final todosMedicamentos = snapshot.data ?? [];

                    if (todosMedicamentos.isEmpty) {
                      return const Center(
                          child: Text('Nenhum medicamento cadastrado.'));
                    }

                    return ListView.builder(
                      itemCount: todosMedicamentos.length,
                      itemBuilder: (context, index) {
                        final med = todosMedicamentos[index];

                        String tituloAdmin = "${med.nome} ${med.dosagem}";
                        if (med.flgEstoque == 'F' &&
                            med.justificativaFalta != null &&
                            med.justificativaFalta!.trim().isNotEmpty) {
                          tituloAdmin += " (${med.justificativaFalta!.trim()})";
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            title: Text(tituloAdmin),
                            subtitle: Text(
                              "Status: ${med.flgAtivo == 'A' ? 'Ativo' : 'Inativo'} | "
                                  "Estoque: ${med.flgEstoque}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFF0056B3)),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/atualizacao',
                                      arguments: med,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmarExclusao(med),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 42),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Tela Inicial'),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 42),
                      ),
                      icon: const Icon(Icons.publish),
                      label: const Text('Publicar'),
                      onPressed: _confirmarPublicacao,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}