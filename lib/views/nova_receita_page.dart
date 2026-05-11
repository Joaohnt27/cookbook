import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receita_model.dart'; 

class NovaReceitaPage extends StatefulWidget {
  final Receita? receitaParaEdicao;

  const NovaReceitaPage({super.key, this.receitaParaEdicao});

  @override
  State<NovaReceitaPage> createState() => _NovaReceitaPageState();
}

class _NovaReceitaPageState extends State<NovaReceitaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers late para inicialização no initState
  late TextEditingController _nomeController;
  late TextEditingController _ingredientesController;
  late TextEditingController _preparoController;
  late TextEditingController _tempoController;
  String _categoriaSelecionada = 'Almoço';

  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.receitaParaEdicao?.nome ?? "",
    );
    _ingredientesController = TextEditingController(
      text: widget.receitaParaEdicao?.ingredientes ?? "",
    );
    _preparoController = TextEditingController(
      text: widget.receitaParaEdicao?.modoPreparo ?? "",
    );
    _tempoController = TextEditingController(
      text: widget.receitaParaEdicao != null
          ? widget.receitaParaEdicao!.tempoPreparo.toString()
          : "",
    );

    if (widget.receitaParaEdicao != null) {
      _categoriaSelecionada = widget.receitaParaEdicao!.categoria;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _ingredientesController.dispose();
    _preparoController.dispose();
    _tempoController.dispose();
    super.dispose();
  }

  void _processarDados() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      try {
        final user = FirebaseAuth.instance.currentUser;

        final Map<String, dynamic> dadosReceita = {
          'nome': _nomeController.text,
          'ingredientes': _ingredientesController.text,
          'modoPreparo': _preparoController.text,
          'tempoPreparo': int.parse(_tempoController.text),
          'categoria': _categoriaSelecionada,
          'userId': user?.uid,
          'ultimaAtualizacao': FieldValue.serverTimestamp(),
        };

        if (widget.receitaParaEdicao == null) {
          await FirebaseFirestore.instance
              .collection('receitas')
              .add(dadosReceita);
        } else {
          await FirebaseFirestore.instance
              .collection('receitas')
              .doc(widget.receitaParaEdicao!.id)
              .update(dadosReceita);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.receitaParaEdicao == null
                    ? "Receita criada com sucesso!"
                    : "Receita atualizada com sucesso!",
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Feedback de erro para o usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao processar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = widget.receitaParaEdicao == null
        ? "Nova Receita"
        : "Editar Receita";

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome da Receita",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Informe o nome" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _ingredientesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Ingredientes",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Informe os ingredientes" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _preparoController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Modo de Preparo",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Informe o preparo" : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempoController,
                      decoration: const InputDecoration(
                        labelText: "Tempo (min)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoriaSelecionada,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Categoria",
                      ),
                      items: ['Almoço', 'Jantar', 'Sobremesa', 'Lanche']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _categoriaSelecionada = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _carregando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _processarDados,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Colors.orange,
                      ),
                      child: Text(
                        widget.receitaParaEdicao == null
                            ? "SALVAR RECEITA"
                            : "ATUALIZAR RECEITA",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
