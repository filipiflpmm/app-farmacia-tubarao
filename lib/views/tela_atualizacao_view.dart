import 'package:flutter/material.dart';
import 'package:app_farmacia/controllers/tela_atualizacao_controller.dart';
import 'package:app_farmacia/models/medicamento_model.dart';

class TelaAtualizacaoView extends StatefulWidget {
  const TelaAtualizacaoView({super.key});

  @override
  State<TelaAtualizacaoView> createState() => _TelaAtualizacaoViewState();
}

class _TelaAtualizacaoViewState extends State<TelaAtualizacaoView> {
  final TelaAtualizacaoController _controller = TelaAtualizacaoController();

  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _dosagemCtrl = TextEditingController();
  final TextEditingController _justificativaCtrl = TextEditingController();

  String _docId = '';
  String _flgAtivo = 'A';
  String _flgEstoque = 'D';
  bool _isFarmaciaPopular = false;
  bool _isCarregado = false;
  bool _isSalvando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isCarregado) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is MedicamentoModel) {
        _docId = args.docId;
        _nomeCtrl.text = args.nome;
        _dosagemCtrl.text = args.dosagem;
        _flgAtivo = args.flgAtivo;
        _flgEstoque = args.flgEstoque;
        _isFarmaciaPopular = args.flgFarmPop == 'S';
        _justificativaCtrl.text = args.justificativaFalta ?? '';
      }
      _isCarregado = true;
    }
  }

  void _confirmar() async {
    setState(() => _isSalvando = true);

    final med = MedicamentoModel(
      docId: _docId,
      nome: _nomeCtrl.text,
      dosagem: _dosagemCtrl.text,
      flgAtivo: _flgAtivo,
      flgEstoque: _flgEstoque,
      flgFarmPop: _isFarmaciaPopular ? 'S' : 'N',
      justificativaFalta: _flgEstoque == 'F' ? _justificativaCtrl.text : null,
      ultimaAtualizacao: DateTime.now(),
    );

    await _controller.salvarMedicamento(med);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicamento salvo com sucesso no Firebase!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_docId.isEmpty ? 'Novo Medicamento' : 'Editar Medicamento'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nome do Medicamento',
                      filled: true,
                      fillColor: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _dosagemCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Dosagem (ex: 50mg)',
                      filled: true,
                      fillColor: Colors.white),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    const Text('Status do Cadastro: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _flgAtivo,
                      items: const [
                        DropdownMenuItem(value: 'A', child: Text('Ativo')),
                        DropdownMenuItem(value: 'I', child: Text('Inativo')),
                      ],
                      onChanged: (String? novoValor) {
                        if (novoValor != null) {
                          setState(() {
                            _flgAtivo = novoValor;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),

                const Text('Situação do Estoque:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SwitchListTile(
                  title: const Text('Disponível'),
                  value: _flgEstoque == 'D',
                  onChanged: (val) {
                    if (val) setState(() => _flgEstoque = 'D');
                  },
                ),
                SwitchListTile(
                  title: const Text('Em Falta'),
                  value: _flgEstoque == 'F',
                  onChanged: (val) {
                    if (val) setState(() => _flgEstoque = 'F');
                  },
                ),

                if (_flgEstoque == 'F') ...[
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _justificativaCtrl,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: 'Justificativa da falta (máx. 50 caracteres)',
                        hintText: 'Ex: Aguardando fornecedor',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],

                SwitchListTile(
                  title: const Text('Estoque Baixo'),
                  value: _flgEstoque == 'B',
                  onChanged: (val) {
                    if (val) setState(() => _flgEstoque = 'B');
                  },
                ),
                const Divider(),

                CheckboxListTile(
                  title: const Text('Oferta pela Farmácia Popular'),
                  value: _isFarmaciaPopular,
                  onChanged: (val) =>
                      setState(() => _isFarmaciaPopular = val ?? false),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(130, 42),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, 42),
                      ),
                      onPressed: _isSalvando ? null : _confirmar,
                      child: _isSalvando
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                          : const Text('Confirmar'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}