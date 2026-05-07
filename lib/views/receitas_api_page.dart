import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'receita_detalhes_page.dart';

class ReceitasApiPage extends StatefulWidget {
  const ReceitasApiPage({super.key});

  @override
  State<ReceitasApiPage> createState() => _ReceitasApiPageState();
}

class _ReceitasApiPageState extends State<ReceitasApiPage> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  List<dynamic> _resultados = [];
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarIndicacoes();
  }

  void _carregarIndicacoes() async {
    setState(() => _carregando = true);
    final resultados = await _apiService.buscarReceitasExternas("a");
    setState(() {
      _resultados = resultados;
      _carregando = false;
    });
  }

  void _pesquisar() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _carregando = true);
    final resultados = await _apiService.buscarReceitasExternas(
      _searchController.text,
    );
    setState(() {
      _resultados = resultados;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explorar Receitas")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar receitas (em inglês)...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (_) => _pesquisar(),
            ),
          ),
          _carregando
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              0.75, 
                        ),
                    itemCount: _resultados.length,
                    itemBuilder: (context, index) {
                      final meal = _resultados[index];
                      return Card(
                        clipBehavior: Clip
                            .antiAlias, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            print(
                              "Clicou em: ${meal['strMeal']}",
                            ); // Debug no console
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReceitaDetalhesPage(meal: meal),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.network(
                                  meal['strMealThumb'],
                                  fit: BoxFit.cover,
                                  // Tratamento de erro caso a imagem da API falhe
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal['strMeal'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      meal['strCategory'] ?? '',
                                      style: TextStyle(
                                        color: Colors.orange[900],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
