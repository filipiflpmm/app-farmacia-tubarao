import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_farmacia/controllers/tela_inicial_controller.dart';

class TelaInicialView extends StatefulWidget {
  const TelaInicialView({super.key});

  @override
  State<TelaInicialView> createState() => _TelaInicialViewState();
}

class _TelaInicialViewState extends State<TelaInicialView> {
  final TelaInicialController _controller = TelaInicialController();

  void _navegarParaConsulta(String filtro) {
    Navigator.pushNamed(context, '/consulta', arguments: filtro);
  }

  void _acessarAreaRestrita() {
    if (_controller.isLogado) {
      Navigator.pushNamed(context, '/admin');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _abrirUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmácia Central'),
        centerTitle: true,
      ),
      body: Center( // <-- Envolvemos em Center para ficar centralizado na Web
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700), // <-- Limita a largura máxima no PC
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBannerComImagem(
                  urlImagem:
                  'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&auto=format&fit=crop&q=60',
                  titulo: 'FARMÁCIA MUNICIPAL CENTRAL DE TUBARÃO',
                  corFundo: const Color(0xFF003366),
                ),
                const SizedBox(height: 10),
                _buildBannerComImagem(
                  urlImagem:
                  'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&auto=format&fit=crop&q=60',
                  titulo: 'POLICLÍNICA DE TUBARÃO - SC',
                  corFundo: const Color(0xFF0056B3),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.8, // <-- Ajustado para 1.8 para os cards não ficarem gigantes na altura
                  children: [
                    _buildCardBanner('Medicamentos\nDisponibilizados',
                        const Color(0xFF0056B3), Icons.check_circle_outline,
                            () => _navegarParaConsulta('TODOS')),
                    _buildCardBanner('Medicamentos\nEm Falta',
                        const Color(0xFFC8102E), Icons.highlight_off,
                            () => _navegarParaConsulta('FALTA')),
                    _buildCardBanner('Medicamentos\nEstoque Baixo',
                        const Color(0xFFD97706), Icons.warning_amber_rounded,
                            () => _navegarParaConsulta('BAIXO')),
                    _buildCardBanner('Medicamentos\nFarmácia Popular',
                        const Color(0xFF059669), Icons.local_pharmacy,
                            () => _navegarParaConsulta('FARM_POP')),
                  ],
                ),
                const SizedBox(height: 16),

                StreamBuilder<String>(
                  stream: _controller.streamDataPublicacao,
                  builder: (context, snapshot) {
                    final dataTexto = snapshot.data ?? "Carregando...";
                    return Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF003366), width: 1.5),
                      ),
                      child: Text(
                        'Atualizado em: $dataTexto',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF003366),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBotaoRedondo(Icons.search, 'Consultar',
                            () => _navegarParaConsulta('TODOS')),
                    _buildBotaoRedondo(
                        Icons.language,
                        'Prefeitura',
                            () => _abrirUrl(
                            'https://tubarao.sc.gov.br/lista-de-medicamentos/')),
                    _buildBotaoRedondo(
                        Icons.support_agent,
                        'WhatsApp',
                            () => _abrirUrl(
                            'https://api.whatsapp.com/send?phone=554836219626')),
                    _buildBotaoRedondo(
                        Icons.admin_panel_settings,
                        'Acesso Restrito',
                        _acessarAreaRestrita),
                  ],
                ),
                const SizedBox(height: 20),

                _buildBannerComImagem(
                  urlImagem:
                  'https://images.unsplash.com/photo-1577495508048-b635879837f1?w=800&auto=format&fit=crop&q=60',
                  titulo: 'PREFEITURA MUNICIPAL DE TUBARÃO',
                  corFundo: const Color(0xFF1E293B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerComImagem(
      {required String urlImagem,
        required String titulo,
        required Color corFundo}) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              urlImagem,
              width: double.infinity,
              height: 70,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.55),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: corFundo),
            ),
          ),
          Center(
            child: Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBanner(
      String titulo, Color cor, IconData icone, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoRedondo(IconData icone, String rotulo, VoidCallback onTap) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFF003366),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          child: Icon(icone, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          rotulo,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003366),
          ),
        ),
      ],
    );
  }
}