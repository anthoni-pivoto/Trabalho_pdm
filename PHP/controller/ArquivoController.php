<?php

require_once __DIR__ . '/../config/Banco.php'; 
require_once __DIR__ . '/../model/Arquivo.php';

class ArquivoController
{
    private $conn;
    const UPLOAD_DIR = __DIR__ . '/../files/';

    public function __construct()
    {
        $banco = new Banco();
        $this->conn = $banco->conectar();
    }

    public function buscarPorId(int $id_midia)
    {
        try {
            $sql = "SELECT id_midia, s_caminho, hash, s_nome_arquivo 
                    FROM tb_arquivo 
                    WHERE id_midia = :id";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(":id", $id_midia, PDO::PARAM_INT);
            $stmt->execute();
            
            return $stmt->fetch(PDO::FETCH_ASSOC);

        } catch (PDOException $e) {
            error_log("Erro ao buscar arquivo por ID: " . $e->getMessage());
            return false;
        }
    }


    public function uploadESalvar(array $fileData): Arquivo|bool
    {
        if ($fileData['error'] !== UPLOAD_ERR_OK) {
            error_log("Erro no upload: " . $fileData['error']);
            return false;
        }

        $nomeOriginal = $fileData['name'];
        $extensao = pathinfo($nomeOriginal, PATHINFO_EXTENSION);
        $hash = hash_file('sha256', $fileData['tmp_name']);
        $nomeNoServidor = $hash . '.' . $extensao;
        $caminhoAbsoluto = self::UPLOAD_DIR . $nomeNoServidor;
        $caminhoRelativo = 'files/' . $nomeNoServidor;

        try {
            if (!is_dir(self::UPLOAD_DIR)) {
                mkdir(self::UPLOAD_DIR, 0777, true); 
            }

            if (!move_uploaded_file($fileData['tmp_name'], $caminhoAbsoluto)) {
                 throw new Exception("Falha ao mover o arquivo para o disco.");
            }
        } catch (Exception $e) {
            error_log("Erro ao salvar arquivo em disco: " . $e->getMessage());
            return false;
        }

        try {
            $sql = "INSERT INTO tb_arquivo (s_caminho, hash, s_nome_arquivo) 
                    VALUES (:caminho, :hash, :nome_arquivo)
                    RETURNING id_midia";

            $stmt = $this->conn->prepare($sql);
            
            $stmt->bindParam(":caminho", $caminhoRelativo);
            $stmt->bindParam(":hash", $hash);
            $stmt->bindParam(":nome_arquivo", $nomeOriginal);
            
            $stmt->execute();
            
            if (strpos($sql, 'RETURNING') !== false) {
                 $id_midia = $stmt->fetchColumn();
            } else {
                 $id_midia = $this->conn->lastInsertId();
            }
            
            return new Arquivo($id_midia, $caminhoRelativo, $hash, $nomeOriginal);
            
        } catch (PDOException $e) {
            if (file_exists($caminhoAbsoluto)) {
                 unlink($caminhoAbsoluto);
            }
            error_log("Falha no insert do arquivo: " . $e->getMessage());
            return false;
        }
    }

    public function substituirArquivo(int $id_midia_antiga, array $fileData)
    {
        $arquivoAntigo = $this->buscarPorId($id_midia_antiga);

        if (!$arquivoAntigo) {
            error_log("Tentativa de substituir arquivo inexistente com ID: " . $id_midia_antiga);
            return false;
        }

        $hashAntigo = $arquivoAntigo['hash'];
        $caminhoRelativoAntigo = $arquivoAntigo['s_caminho'];

        $novoArquivo = $this->uploadESalvar($fileData); 
        
        if (!$novoArquivo) {
            error_log("Falha ao fazer upload/salvar novo arquivo durante a substituição.");
            return false;
        }

        try {
            $sql = "UPDATE tb_arquivo 
                    SET s_caminho = :novo_caminho, hash = :novo_hash, s_nome_arquivo = :novo_nome 
                    WHERE id_midia = :id_antiga";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(':novo_caminho', $novoArquivo->s_caminho);
            $stmt->bindValue(':novo_hash', $novoArquivo->hash);
            $stmt->bindValue(':novo_nome', $novoArquivo->s_nome_arquivo);
            $stmt->bindValue(':id_antiga', $id_midia_antiga, PDO::PARAM_INT);
            $stmt->execute();
            
            if ($stmt->rowCount() === 0) {
                error_log("Nenhuma linha atualizada para ID: " . $id_midia_antiga);
                return false;
            }

        } catch (PDOException $e) {
            error_log("Erro ao atualizar metadados do arquivo: " . $e->getMessage());
            return false;
        }
        
        $sqlCount = "SELECT COUNT(*) FROM tb_arquivo WHERE hash = :hash AND id_midia != :id_antiga";
        $stmtCount = $this->conn->prepare($sqlCount);
        $stmtCount->bindValue(":hash", $hashAntigo);
        $stmtCount->bindValue(":id_antiga", $id_midia_antiga, PDO::PARAM_INT);
        $stmtCount->execute();
        $count = $stmtCount->fetchColumn();

        if ($count == 0 && $hashAntigo !== $novoArquivo->hash) {
            $caminhoAbsolutoAntigo = __DIR__ . '/../' . $caminhoRelativoAntigo;
            if (file_exists($caminhoAbsolutoAntigo)) {
                unlink($caminhoAbsolutoAntigo);
            }
        }

        return $this->buscarPorId($id_midia_antiga); 
    }


    public function deletar(int $id_midia): bool
    {
        try {
            $sqlSelect = "SELECT s_caminho, hash FROM tb_arquivo WHERE id_midia = :id";
            $stmtSelect = $this->conn->prepare($sqlSelect);
            $stmtSelect->bindParam(":id", $id_midia, PDO::PARAM_INT);
            $stmtSelect->execute();
            $arquivoData = $stmtSelect->fetch(PDO::FETCH_ASSOC);

            if (!$arquivoData) {
                return true;
            }
            
            $caminhoRelativo = $arquivoData['s_caminho'];
            $hashDoArquivo = $arquivoData['hash'];
            $caminhoAbsoluto = __DIR__ . '/../' . $caminhoRelativo;

            $sqlDelete = "DELETE FROM tb_arquivo WHERE id_midia = :id";
            $stmtDelete = $this->conn->prepare($sqlDelete);
            $stmtDelete->bindParam(":id", $id_midia, PDO::PARAM_INT);
            $stmtDelete->execute();

            if ($stmtDelete->rowCount() === 0) {
                return false; 
            }

            $sqlCount = "SELECT COUNT(*) FROM tb_arquivo WHERE hash = :hash";
            $stmtCount = $this->conn->prepare($sqlCount);
            $stmtCount->bindParam(":hash", $hashDoArquivo);
            $stmtCount->execute();
            $count = $stmtCount->fetchColumn();

            if ($count == 0) {
                if (file_exists($caminhoAbsoluto)) {
                    return unlink($caminhoAbsoluto);
                }
            }
            
            return true;
            
        } catch (PDOException $e) {
            error_log("Falha ao deletar arquivo: " . $e->getMessage());
            return false;
        }
    }
}