import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      String? erro = await _authService.registrar(
        email: _emailController.text,
        password: _senhaController.text,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
      );

      setState(() => _carregando = false);

      if (erro == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Conta criada com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta para o Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome Completo",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Informe seu nome" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: "Telefone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val!.isEmpty ? "Informe seu telefone" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.contains("@") ? null : "E-mail inválido",
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: "Senha Segura",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) {
                  if (val!.length < 6) return "Mínimo 6 caracteres";
                  if (!val.contains(RegExp(r'[A-Z]')))
                    return "Deve conter letra maiúscula";
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _carregando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registrar,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Registrar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
