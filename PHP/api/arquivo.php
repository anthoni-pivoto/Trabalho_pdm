<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// --- IMPORTANTE: Adicionei o Banco.php aqui para garantir que o 'new Banco()' funcione ---
require_once __DIR__ . '/../config/Banco.php';
require_once __DIR__ . '/../controller/ArquivoController.php';
require_once __DIR__ . '/../model/Arquivo.php';

$controller = new ArquivoController();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // =================================================================================
        // ADIÇÃO: CASO 0 - PROXY DE IMAGEM (Isso resolve o problema do Flutter Web/CORS)
        // =================================================================================
        if (isset($_GET['ver_imagem'])) {
            // Pega o nome do arquivo e remove caminhos maliciosos (../../)
            $nomeArquivo = basename($_GET['ver_imagem']); 
            
            // Define onde está a pasta 'files' física no servidor
            // O __DIR__ pega a pasta atual (api), o /../ volta uma pasta
            $caminhoFisico = __DIR__ . '/../files/' . $nomeArquivo;

            if (file_exists($caminhoFisico)) {
                // Descobre se é jpg, png, pdf, etc.
                $tipoMime = mime_content_type($caminhoFisico);
                
                // Sobrescreve o header JSON lá de cima para o tipo da imagem
                header("Content-Type: " . $tipoMime);
                
                // Lê o arquivo e joga na tela
                readfile($caminhoFisico);
                exit; // MATA O SCRIPT AQUI para não enviar JSON junto
            } else {
                http_response_code(404);
                echo json_encode(["erro" => "Arquivo fisico nao encontrado no servidor"]);
                exit;
            }
        }
        // =================================================================================

        // CASO 1: Busca por ID DA ETAPA (Para o App Flutter)
        if (isset($_GET['id_etapa'])) {
            $idEtapa = $_GET['id_etapa'];
            
            // Instancia o banco diretamente
            $banco = new Banco();
            $conn = $banco->conectar();

            try {
                // SQL JOIN: Etapa -> Mídia
                $sql = "SELECT a.s_caminho, e.id_tipo_etapa 
                    FROM tb_etapa e
                    INNER JOIN tb_arquivo a ON e.id_midia = a.id_midia
                    WHERE e.id_etapa = :id_etapa";
                
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':id_etapa', $idEtapa, PDO::PARAM_INT);
                $stmt->execute();
                $resultado = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($resultado) {
                    echo json_encode($resultado);
                } else {
                    // Retorna vazio para não quebrar o Flutter
                    echo json_encode(["s_caminho" => "", "id_tipo_etapa" => ""]);
                }
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(["erro" => "Erro no SQL: " . $e->getMessage()]);
            }
        }
        // CASO 2: Busca por ID DA MÍDIA (Código legado/painel administrativo)
        else if (isset($_GET['id_midia']) && is_numeric($_GET['id_midia'])) {
            $id = (int)$_GET['id_midia'];
            $arquivo = $controller->buscarPorId($id);
            if ($arquivo) {
                echo json_encode($arquivo);
            } else {
                http_response_code(404);
                echo json_encode(["error" => "Arquivo não encontrado."]);
            }
        } else {
            // Se não mandou nem id_etapa nem id_midia (e nem ver_imagem)
            http_response_code(400);
            echo json_encode(["error" => "Parâmetro id_etapa, id_midia ou ver_imagem é obrigatório."]);
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