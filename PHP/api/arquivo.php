<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../controller/ArquivoController.php';
require_once __DIR__ . '/../model/Arquivo.php';

$controller = new ArquivoController();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['id_midia']) && is_numeric($_GET['id_midia'])) {
            $id = (int)$_GET['id_midia'];
            $arquivo = $controller->buscarPorId($id);
            if ($arquivo) {
                echo json_encode($arquivo);
            } else {
                http_response_code(404);
                echo json_encode(["error" => "Arquivo não encontrado."]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["error" => "Parâmetro id_midia é obrigatório e deve ser numérico."]);
        }
        break;

    case 'POST':
        if (isset($_FILES['arquivo']) && isset($_POST['id_midia']) && is_numeric($_POST['id_midia']) && $_FILES['arquivo']['error'] === UPLOAD_ERR_OK) {
            $id = (int)$_POST['id_midia'];
            $arquivoAtualizado = $controller->substituirArquivo($id, $_FILES['arquivo']);
            
            if ($arquivoAtualizado) {
                http_response_code(200);
                echo json_encode(["success" => true, "arquivo" => $arquivoAtualizado, "mensagem" => "Arquivo substituído com sucesso."]);
            } else {
                http_response_code(500);
                echo json_encode(["error" => "Falha na substituição do arquivo."]);
            }
        } 
        elseif (isset($_FILES['arquivo']) && $_FILES['arquivo']['error'] === UPLOAD_ERR_OK) {
            $novoArquivo = $controller->uploadESalvar($_FILES['arquivo']);

            if ($novoArquivo) {
                http_response_code(201);
                echo json_encode([
                    "success" => true,
                    "arquivo" => $novoArquivo
                ]);
            } else {
                http_response_code(500);
                echo json_encode(["error" => "Falha ao salvar arquivo e metadados. Verifique logs."]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["error" => "Nenhum arquivo enviado ou erro de upload."]);
        }
        break;

    case 'DELETE':
        $dados = json_decode(file_get_contents("php://input"));
        $id_midia = $dados->id_midia ?? $_GET['id_midia'] ?? null;

        if (is_numeric($id_midia)) {
            $success = $controller->deletar((int)$id_midia); 
            
            if ($success) {
                echo json_encode(["success" => true, "mensagem" => "Arquivo e metadados removidos com success."]);
            } else {
                http_response_code(500);
                echo json_encode(["error" => "Falha ao deletar o arquivo. Verifique logs."]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["error" => "Informe o ID do arquivo (id_midia) para deletar."]);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(["error" => "Método não permitido"]);
}