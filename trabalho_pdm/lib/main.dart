import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa o pacote http
import 'dart:convert'; // Importa o conversor JSON

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
      home: const LoginPage(), // O app ainda começa na tela de login
    );
  }
}

// -----------------------------------------------------
// TELA DE LOGIN (COM MODIFICAÇÕES)
// -----------------------------------------------------
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
      // **NOTA**: A API de login provavelmente é DIFERENTE da de cadastro.
      // Estou assumindo que a API de login também usa 'email_usuario' e 'pwd_usuario'.
      // Se a sua API de login espera outros campos, ajuste o 'body' abaixo.
      final body = {
        'email_usuario': _emailController.text,
        'pwd_usuario': _passwordController.text,
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
          // TODO: Navegar para a tela principal (HomePage) após o login
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
              
              // ----------------------------------------------
              // NOVO: Botão para navegar para a tela de cadastro
              // ----------------------------------------------
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  // Navega para a CadastroPage
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

// -----------------------------------------------------
// NOVA TELA DE CADASTRO
// -----------------------------------------------------
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  // Controladores para os 3 campos
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    // A URL é a mesma, conforme sua descrição
    const String apiUrl = 'http://200.19.1.19/usuario02/api/usuario.php';

    setState(() {
      _isLoading = true;
    });

    try {
      // Cria o corpo (body) com os 3 campos para o cadastro
      final body = {
        'nm_usuario': _nomeController.text,
        'email_usuario': _emailController.text,
        'pwd_usuario': _passwordController.text,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Assumindo que 201 (Created) ou 200 (OK) são sucesso
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          // Volta para a tela de login
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