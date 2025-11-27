import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(), 
    );
  }
}

class PesquisaScreen extends StatefulWidget {
  const PesquisaScreen({Key? key}) : super(key: key);

  @override
  State<PesquisaScreen> createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  // Variável para controlar qual ícone da barra inferior está selecionado
  int _selectedIndex = 0;
  List cursos = [];
  bool carregando = false; 

Future<void> buscarCursos(String query) async {
    if (query.isEmpty) {
      setState(() => cursos = []);
      return;
    }

    setState(() => carregando = true);
    print("Buscando cursos: $query");
    final url = Uri.parse(
        "http://200.19.1.19/usuario02/api/curso.php?search=$query");

    try {
      final response = await http.get(url);
      print("Status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        setState(() {
          print("Body recebido: ${response.body}");
          cursos = jsonDecode(response.body);
          carregando = false;
        });
      } else {
        setState(() {
          cursos = [];
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        cursos = [];
        carregando = false;
      });
    }
  }
  // Função chamada quando um item da barra é tocado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Aqui você pode adicionar lógica de navegação para as outras telas
    // ex: if (index == 3) { Navigator.push(context, ...) }
  }

  Widget buildCourseItem({
    required String titulo,
    required String descricao,
    required VoidCallback onIngresso,
    required VoidCallback onConversar,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/128/2901/2901131.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                
                child: ElevatedButton(
                  onPressed: onIngresso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 214, 214), // Cor cinza
                    elevation: 4,                      // Elevação (sombra)
                    shadowColor: Colors.black,         // Cor da sombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Bordas quadradas
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  ),
                  child: const Text(
                    "Ingressar",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: onConversar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 214, 214), // Cor cinza
                    elevation: 4,                      // Elevação (sombra)
                    shadowColor: Colors.black,         // Cor da sombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Bordas quadradas
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  ),
                  child: const Text(
                    "Conversar",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // 1. O AppBar (barra preta superior)
      // Usamos PreferredSize para customizar a altura e a forma
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Altura do AppBar
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black, // Cor de fundo preta
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24), // Bordas arredondadas
            ),
          ),
          // Usamos SafeArea para evitar a barra de status do celular
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () {
                      // Se esta tela foi 'pushReplacement' do login,
                      // o 'pop' pode não funcionar como esperado.
                      // Mas se foi 'push', está correto.
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 8.0),
                  // Título
                  const Text(
                    'Pesquisar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 2. O Corpo da Tela (fundo branco)
            // 2. O Corpo da Tela (fundo branco)

      // 2. O Corpo da Tela (fundo branco)

      // 2. O Corpo da Tela (fundo branco)

      // 2. O Corpo da Tela (fundo branco)
      // 2. O Corpo da Tela (fundo branco)

      backgroundColor: Colors.white, // Fundo branco como na imagem
      body: Column(
        children: [
          // 3. A Barra de Pesquisa (TextField)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
            child: TextField(
              onChanged: (value) => buscarCursos(value),
              decoration: InputDecoration(
                hintText: 'Pesquisar...', // Texto de sugestão
                // Ícone da lupa dentro da barra
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[200], // Fundo cinza claro
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                // Bordas arredondadas sem linha de contorno
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 4. O Texto Central (ocupa o resto da tela)
          Expanded(
            child:  carregando
                ? const Center(child: CircularProgressIndicator())
                : cursos.isEmpty
                    ? Center(
                        child: Text(
                          'Pesquise por um curso\npara exibir os resultados',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cursos.length,
                        itemBuilder: (context, index) {
                          final curso = cursos[index];

                          return buildCourseItem(
                            titulo: curso['s_nm_curso'],
                            descricao: curso['s_descricao_curso'],
                            onIngresso: () {
                              print("Ingressou no curso ${curso['id_curso']}");
                            },
                            onConversar: () {
                              print("Conversar sobre o curso ${curso['id_curso']}");
                            },
                          );
                        },
                      ),
          ),
        ],
      ),

      // 5. A Barra de Navegação Inferior (BottomNavBar)// 
      // 5. A Barra de Navegação Inferior (BottomNavBar)//
      // 5. A Barra de Navegação Inferior (BottomNavBar)//
      // 5. A Barra de Navegação Inferior (BottomNavBar)//
      // 5. A Barra de Navegação Inferior (BottomNavBar)//
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Fundo preto
        type: BottomNavigationBarType.fixed, // Garante que todos os 4 apareçam
        showSelectedLabels: false, // Não mostrar texto
        showUnselectedLabels: false, // Não mostrar texto

        // Cor dos ícones (branco selecionado, cinza não selecionado)
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],

        // Definição dos 4 ícones
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Cursos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work_outlined), // Ícone de "grupo"
            label: 'Aulas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex, // Usa a variável de estado
        onTap: _onItemTapped, // Chama a função ao tocar
      ),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    const String apiUrl = 'http://200.19.1.19/usuario02/api/usuario.php';

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'email_usuario': _emailController.text,
        'pwd_usuario': _passwordController.text,
        'action':'login'
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          
          );
          Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PesquisaScreen(),
          ),
        );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no login: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao conectar: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela de Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ex: maria@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroPage()),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    const String apiUrl = 'http://200.19.1.19/usuario02/api/usuario.php';

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'nm_usuario': _nomeController.text,
        'email_usuario': _emailController.text,
        'pwd_usuario': _passwordController.text,
        'action':'register'
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no cadastro: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao conectar: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
        // O botão de "voltar" é adicionado automaticamente pelo Navigator
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Campo de Nome
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'ex: Maria da Silva',
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16.0),
              // Campo de Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ex: maria@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              // Campo de Senha
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32.0),
              // Botão de Cadastrar
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _cadastrar,
                      child: const Text('Cadastrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}