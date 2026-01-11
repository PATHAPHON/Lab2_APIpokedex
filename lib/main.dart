import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดป้าย Debug ตรงมุมขวาบน
      home: PokemonListScreen(),
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemons = [];
  bool isGrid = false; // ตัวแปรสลับโหมด List/Grid

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1000');
    try {
      final response = await http.get(url);
      final jsonData = jsonDecode(response.body);
      setState(() {
        pokemons = jsonData['results'];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // ฟังก์ชันช่วยดึง ID จาก URL (เอาไว้โชว์รูป)
  String getPokemonId(String url) {
    return url.split('/').where((e) => e.isNotEmpty).last;
  }

  String getImageUrl(String id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (pokemons.isEmpty) {
      content = const Center(child: CircularProgressIndicator());
    } else if (isGrid) {
      // --- Grid ---
      content = GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1 / 1,
        ),
        itemCount: pokemons.length,
        itemBuilder: (context, index) {
          var p = pokemons[index];
          var id = getPokemonId(p['url']);
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () => _goToDetail(p['name'], p['url']),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60, child: Image.network(getImageUrl(id))),
                  Text(
                    p['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // --- List ---
      content = ListView.builder(
        itemCount: pokemons.length,
        itemBuilder: (context, index) {
          var p = pokemons[index];
          var id = getPokemonId(p['url']);

          return ListTile(
            leading: SizedBox(width: 50, child: Image.network(getImageUrl(id))),
            title: Text(p['name'].toString()),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _goToDetail(p['name'], p['url']),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
        ],
      ),
      body: content,
    );
  }

  void _goToDetail(String name, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(pokemonName: name, url: url),
      ),
    );
  }
}

class PokemonDetailScreen extends StatefulWidget {
  final String pokemonName;
  final String url;

  const PokemonDetailScreen({
    super.key,
    required this.pokemonName,
    required this.url,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    String id = widget.url.split('/').where((e) => e.isNotEmpty).last;
    String imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return Scaffold(
      appBar: AppBar(title: Text(widget.pokemonName.toUpperCase())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.network(
                imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text("#$id"),
            Text(widget.pokemonName),
          ],
        ),
      ),
    );
  }
}
