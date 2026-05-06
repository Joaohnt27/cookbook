import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EsqueceuSenhaPage extends StatefulWidget {
  const EsqueceuSenhaPage({super.key});

  @override
  State<EsqueceuSenhaPage> createState() => _EsqueceuSenhaPageState();
}

class _EsqueceuSenhaPageState extends State<EsqueceuSenhaPage> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;

  void _recuperar() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, informe seu e-mail.")),
      );
      return;
    }

    setState(() => _carregando = true);

    String? erro = await _authService.recuperarSenha(_emailController.text);

    setState(() => _carregando = false);

    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link de recuperação enviado para o seu e-mail!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Volta para a tela de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Senha")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Insira seu e-mail para receber um link de redefinição de senha.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _carregando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _recuperar,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Enviar E-mail"),
                  ),
          ],
        ),
      ),
    );
  }
}
