<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../controller/UsuarioController.php';
require_once __DIR__ . '/../model/Usuario.php';

$controller = new UsuarioController();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['id_usuario'])) {
            echo json_encode($controller->listarPorId($_GET['id_usuario']));
        } else {
            echo json_encode($controller->listar());
        }
        break;
    case 'POST':
        try {
            $dados = json_decode(file_get_contents("php://input"));
            if (!isset($dados->action)) {
                http_response_code(400);
                echo json_encode(["sucesso" => false, "message" => "Ação não especificada."]);
                break;
            }
            switch ($dados->action) {
                
                case 'login':
                    if (isset($dados->email_usuario) && isset($dados->pwd_usuario)) {
                        
                        $usuarioLogado = $controller->login($dados->email_usuario, $dados->pwd_usuario);
                        if ($usuarioLogado) {
                            http_response_code(200);
                            echo json_encode($usuarioLogado);
                        } else {
                            http_response_code(401);
                            echo json_encode([
                                "sucesso" => false,
                                "message" => "Email ou senha inválidos."
                            ]);
                        }
                    } else {
                        
                        http_response_code(400); 
                        echo json_encode(["sucesso" => false, "message" => "Dados de login incompletos."]);
                    }
                    break;
                case 'register':
                    if (isset($dados->nm_usuario) && isset($dados->email_usuario) && isset($dados->pwd_usuario)) {
                        $usuario = new Usuario(
                            null,
                            $dados->nm_usuario,
                            $dados->email_usuario,
                            $dados->pwd_usuario, 
                            $dados->email_contato ?? null,
                            $dados->numero_telefone ?? null
                        );
                        $sucesso = $controller->criar($usuario); 
                        
                        if ($sucesso) {
                            http_response_code(201);
                            echo json_encode(["sucesso" => true, "message" => "Usuário criado com sucesso."]);
                        } else {
                            http_response_code(500);
                            echo json_encode(["sucesso" => false, "message" => "Erro ao criar usuário."]);
                        }
                    } else {
                        http_response_code(400);
                        echo json_encode(["sucesso" => false, "message" => "Dados de registro incompletos."]);
                    }
                    break;

                default:
                    http_response_code(400);
                    echo json_encode(["sucesso" => false, "message" => "Ação desconhecida."]);
            }

        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode(["sucesso" => false, "message" => "Requisição inválida: " . $e->getMessage()]);
        }
        break;
        

    case 'PUT':
        $dados = json_decode(file_get_contents("php://input"));
        if (isset($dados->id_usuario) && isset($dados->nm_usuario) && isset($dados->email_usuario)) {
            $usuario = new Usuario(
                $dados->id_usuario,
                $dados->nm_usuario,
                $dados->email_usuario,
                $dados->pwd_usuario ?? null,
                $dados->email_contato ?? null,
                $dados->numero_telefone ?? null
            );
            $sucesso = $controller->atualizar($usuario);
            if ($sucesso) {
                echo json_encode(["sucesso" => true]);
            } else {
                http_response_code(404);
                echo json_encode(["erro" => "Nenhum registro atualizado"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["erro" => "Dados incompletos para atualizar"]);
        }
        break;

    case 'DELETE':
        $dados = json_decode(file_get_contents("php://input"));
        if (isset($dados->id_usuario)) {
            $sucesso = $controller->deletar($dados->id_usuario);
            if ($sucesso) {
                echo json_encode(["sucesso" => true]);
            } else {
                http_response_code(500);
            }
        } else {
            echo json_encode(["erro" => "Informe o ID"]);
        }
        break;

    default:
        echo json_encode(["erro" => "Método não permitido"]);
}
