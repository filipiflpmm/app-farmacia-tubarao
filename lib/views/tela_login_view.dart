import 'package:flutter/material.dart';
import 'package:app_farmacia/controllers/tela_login_controller.dart';

class TelaLoginView extends StatefulWidget {
  const TelaLoginView({super.key});

  @override
  State<TelaLoginView> createState() => _TelaLoginViewState();
}

class _TelaLoginViewState extends State<TelaLoginView> {
  final TelaLoginController _controller = TelaLoginController();
  final TextEditingController _usuarioCtrl =
  TextEditingController(text: 'admin');
  final TextEditingController _senhaCtrl = TextEditingController(text: '123');
  final TextEditingController _emailCtrl = TextEditingController();

  bool _mostrarEsqueciSenha = false;
  bool _isCarregando = false;

  void _tentarLogin() async {
    setState(() => _isCarregando = true);
    final sucesso = await _controller.realizarLogin(_usuarioCtrl.text, _senhaCtrl.text);
    setState(() => _isCarregando = false);

    if (mounted) {
      if (sucesso) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ou senha inválidos!')),
        );
      }
    }
  }

  bool _validarEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email.trim());
  }

  void _enviarRedefinicaoEmail() {
    final emailDigitado = _emailCtrl.text.trim();
    if (_validarEmail(emailDigitado)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Instruções de redefinição enviadas para o e-mail: $emailDigitado'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      setState(() {
        _mostrarEsqueciSenha = false;
        _emailCtrl.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, insira um e-mail válido no formato: exemplo@exemplo.com'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Acesso Restrito - Login'),
          centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person, size: 60, color: Color(0xFF003366)),
                const SizedBox(height: 16),
                TextField(
                  controller: _usuarioCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Usuário',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Senha',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.key)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: _isCarregando ? null : _tentarLogin,
                  child: _isCarregando
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Entrar'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mostrarEsqueciSenha = !_mostrarEsqueciSenha;
                    });
                  },
                  child: const Text('Esqueci minha senha',
                      style: TextStyle(color: Color(0xFF003366))),
                ),
                if (_mostrarEsqueciSenha) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Digite seu e-mail (exemplo@exemplo.com)',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056B3),
                        foregroundColor: Colors.white),
                    onPressed: _enviarRedefinicaoEmail,
                    child: const Text('Enviar'),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}