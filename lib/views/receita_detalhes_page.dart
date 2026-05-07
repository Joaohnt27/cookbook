import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class ReceitaDetalhesPage extends StatefulWidget {
  final dynamic meal;

  const ReceitaDetalhesPage({super.key, required this.meal});

  @override
  State<ReceitaDetalhesPage> createState() => _ReceitaDetalhesPageState();
}

class _ReceitaDetalhesPageState extends State<ReceitaDetalhesPage> {
  final translator = GoogleTranslator();

  // Variáveis para armazenar as traduções
  String _nome = "";
  String _categoria = "";
  String _origem = "";
  String _instrucoes = "Traduzindo conteúdo...";
  bool _estaTraduzindo = true;

  @override
  void initState() {
    super.initState();
    _traduzirTudo();
  }

  // processamento de dados de API externa
  Future<void> _traduzirTudo() async {
    try {
      var tradNome = await translator.translate(
        widget.meal['strMeal'],
        from: 'en',
        to: 'pt',
      );
      var tradCat = await translator.translate(
        widget.meal['strCategory'],
        from: 'en',
        to: 'pt',
      );
      var tradArea = await translator.translate(
        widget.meal['strArea'],
        from: 'en',
        to: 'pt',
      );
      var tradInst = await translator.translate(
        widget.meal['strInstructions'],
        from: 'en',
        to: 'pt',
      );

      if (mounted) {
        setState(() {
          _nome = tradNome.text;
          _categoria = tradCat.text;
          _origem = tradArea.text;
          _instrucoes = tradInst.text;
          _estaTraduzindo = false;
        });
      }
    } catch (e) {
      // Caso a tradução falhe, mantém o original para não quebrar o app
      if (mounted) {
        setState(() {
          _nome = widget.meal['strMeal'];
          _categoria = widget.meal['strCategory'];
          _origem = widget.meal['strArea'];
          _instrucoes = widget.meal['strInstructions'];
          _estaTraduzindo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _estaTraduzindo ? "Carregando..." : _nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.meal['strMealThumb'], fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges de Categoria e Origem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.restaurant, size: 16),
                          label: Text(_estaTraduzindo ? "..." : _categoria),
                        ),
                        Chip(
                          avatar: const Icon(Icons.public, size: 16),
                          label: Text(_estaTraduzindo ? "..." : _origem),
                          backgroundColor: Colors.orange[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "Modo de Preparo",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),

                    // Feedback de progresso 
                    _estaTraduzindo
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Text(
                            _instrucoes,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                    const SizedBox(height: 80), // Espaço para o FAB
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange[700],
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Adicionado aos favoritos!"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        label: const Text(
          "SALVAR RECEITA",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.favorite),
      ),
    );
  }
}
