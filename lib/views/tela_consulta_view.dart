import 'package:flutter/material.dart';
import 'package:app_farmacia/controllers/tela_consulta_controller.dart';
import 'package:app_farmacia/models/medicamento_model.dart';

class TelaConsultaView extends StatefulWidget {
  const TelaConsultaView({super.key});

  @override
  State<TelaConsultaView> createState() => _TelaConsultaViewState();
}

class _TelaConsultaViewState extends State<TelaConsultaView> {
  final TelaConsultaController _controller = TelaConsultaController();
  final TextEditingController _buscaController = TextEditingController();

  String _filtroAtual = 'TODOS';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _filtroAtual = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Medicamentos'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _buscaController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Digite o nome (min. 4 letras)...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF003366)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<MedicamentoModel>>(
                  stream: _controller.escutarECalcularFiltros(
                    filtroTipo: _filtroAtual,
                    textoBusca: _buscaController.text,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final medicamentos = snapshot.data ?? [];

                    if (medicamentos.isEmpty) {
                      return const Center(
                          child: Text('Nenhum medicamento encontrado.'));
                    }

                    return ListView.builder(
                      itemCount: medicamentos.length,
                      itemBuilder: (context, index) {
                        final med = medicamentos[index];

                        final bool temJustificativa = med.flgEstoque == 'F' &&
                            med.justificativaFalta != null &&
                            med.justificativaFalta!.trim().isNotEmpty;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          elevation: 2,
                          child: ListTile(
                            title: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "${med.nome} ${med.dosagem}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: med.flgFarmPop == 'S'
                                          ? const Color(0xFF059669)
                                          : Colors.black,
                                    ),
                                  ),
                                  if (temJustificativa)
                                    TextSpan(
                                      text: " (${med.justificativaFalta!.trim()})",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF0056B3),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            subtitle: Text(
                              med.flgEstoque == 'F'
                                  ? 'Status: Em Falta'
                                  : med.flgEstoque == 'B'
                                  ? 'Status: Estoque Baixo'
                                  : 'Status: Disponível',
                              style: TextStyle(
                                fontWeight: med.flgEstoque == 'F'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: med.flgEstoque == 'F'
                                    ? const Color(0xFFC8102E)
                                    : med.flgEstoque == 'B'
                                    ? const Color(0xFFD97706)
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFiltroBtn('Disponíveis', 'TODOS', const Color(0xFF0056B3)),
                    _buildFiltroBtn('Em Falta', 'FALTA', const Color(0xFFC8102E)),
                    _buildFiltroBtn('Estoque Baixo', 'BAIXO', const Color(0xFFD97706)),
                    _buildFiltroBtn('Farm. Popular', 'FARM_POP', const Color(0xFF059669)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroBtn(String rotulo, String filtro, Color cor) {
    final bool ativo = _filtroAtual == filtro;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ativo ? cor : Colors.grey.shade200,
        foregroundColor: ativo ? Colors.black87 : Colors.black87,
        elevation: ativo ? 3 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      onPressed: () => setState(() => _filtroAtual = filtro),
      child: Text(rotulo,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ativo ? Colors.white : Colors.black87)),
    );
  }
}