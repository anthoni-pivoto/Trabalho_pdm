import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt("id_usuario");
  
  runApp(MyApp(isLogged: id != null,));
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLogged ? HomePage() : LoginPage(), 
    );
  }
}

class PesquisaScreen extends StatefulWidget {
  const PesquisaScreen({Key? key}) : super(key: key);

  @override
  State<PesquisaScreen> createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  List cursos = [];
  bool carregando = false; 

  Future<void> buscarCursos(String query) async {
    if (query.isEmpty) {
      setState(() => cursos = []);
      return;
    }

    setState(() => carregando = true);
    final url = Uri.parse(
        "http://200.19.1.19/usuario02/api/curso.php?search=$query");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
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
            child: carregando
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
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  void carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState( () {
      userName = prefs.getString("nm_usuario") ?? "";
      userEmail = prefs.getString("email_usuario") ?? "";
      userPhone = prefs.getString("i_numero_telefone") ?? "";
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("id_usuario");
    await prefs.remove("nm_usuario");
    await prefs.remove("email_usuario");
    await prefs.remove("i_numero_telefone");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Perfil',
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
      body:SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar grande
          const Icon(
            Icons.account_circle,
            size: 140,
            color: Colors.black,
          ),

          const SizedBox(height: 24),

          // Nome
          _buildProfileInfo(
            icon: Icons.person,
            label: userName,
          ),

          // Email do usuário
          _buildProfileInfo(
            icon: Icons.email,
            label: userEmail,
          ),

          // Telefone (com botão editar)
          _buildProfileInfo(
            icon: Icons.phone,
            label: userPhone,
            showEdit: true,
          ),

          const SizedBox(height: 30),

          // Botão logout
          ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Sair"),
          ),
        ],
      ),
    )
    );
  }
Widget _buildProfileInfo({
  required IconData icon,
  required String label,
  bool showEdit = false,
}) {
  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          if (showEdit)
            Icon(Icons.edit, size: 20, color: Colors.black87),
        ],
      ),

      const SizedBox(height: 6),

      // Linha fina de separação
      Container(
        height: 1,
        color: Colors.black54,
      ),

      const SizedBox(height: 12),
    ],
  );
}

}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    PesquisaScreen(),
    Center(child: Text("Cursos em breve")),
    Center(child: Text("Aulas em breve")),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Pesquisar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: "Cursos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work_outlined),
            label: "Aulas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Perfil",
          ),
        ],
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
  var usuario = {};

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
        usuario = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt("id_usuario", usuario['id_usuario']);
        await prefs.setString("nm_usuario", usuario['s_nome'] ?? "");
        await prefs.setString("email_usuario", usuario['s_email'] ?? "");
        await prefs.setString("i_numero_telefone", usuario['i_numero_telefone'] ?? "");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
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