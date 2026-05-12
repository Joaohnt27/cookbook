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

  static const Color _primaryColor = Color(0xFFE67E22);
  static const Color _secondaryColor = Color(0xFF34495E);

  @override
  void initState() {
    super.initState();
    _carregarIndicacoes();
  }

  void _carregarIndicacoes() async {
    if (!mounted) return;
    setState(() => _carregando = true);
    final resultados = await _apiService.buscarReceitasExternas("a");
    if (mounted) {
      setState(() {
        _resultados = resultados;
        _carregando = false;
      });
    }
  }

  void _pesquisar() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _carregando = true);
    final resultados = await _apiService.buscarReceitasExternas(
      _searchController.text,
    );
    if (mounted) {
      setState(() {
        _resultados = resultados;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Explorar Receitas",
          style: TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _pesquisar(),
              decoration: InputDecoration(
                hintText: "Buscar no mundo todo...",
                prefixIcon: const Icon(Icons.public, color: _primaryColor),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _pesquisar,
                  color: _primaryColor,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: _primaryColor, width: 2),
                ),
              ),
            ),
          ),
          _carregando
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  ),
                )
              : Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: _resultados.length,
                    itemBuilder: (context, index) {
                      final meal = _resultados[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReceitaDetalhesPage(meal: meal),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    meal['strMealThumb'] ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: _primaryColor,
                                            ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal['strMeal'] ?? 'Sem nome',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _secondaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "Ver Receita",
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
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
