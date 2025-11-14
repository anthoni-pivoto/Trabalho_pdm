<?php
require_once __DIR__ . '/../config/Banco.php';
require_once __DIR__ . '/../model/Usuario.php';

class UsuarioController
{
    private $conn;

    public function __construct()
    {
        $banco = new Banco();
        $this->conn = $banco->conectar();
    }

    public function listar()
    {
        $sql = "SELECT * FROM tb_usuario";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function login($email, $senha)
    {
        try {
            $sql = "SELECT * FROM tb_usuario WHERE s_email = :email";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(":email", $email);
            $stmt->execute();

            $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($usuario) {
                if (password_verify($senha, $usuario['s_senha'])) {
                    unset($usuario['s_senha']);
                    return $usuario;
                }
            }
            return false;
        } catch (PDOException $e) {
            return false;
        }
    }

   public function criar($usuario)
    {
        try {
            $senhaHash = password_hash($usuario->pwd_usuario, PASSWORD_DEFAULT);

            $sql = "INSERT INTO tb_usuario (id_usuario, s_nome, s_email, s_senha) 
                    VALUES (nextval('tb_usuario_id_usuario_seq'), :nome, :email, :senha)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(":nome", $usuario->nm_usuario);
            $stmt->bindParam(":email", $usuario->email_usuario);
            
            $stmt->bindParam(":senha", $senhaHash); 
            
            $stmt->execute();
            return true;
        } catch (PDOException $e) {
            return false;
        }
    }

    public function atualizar($usuario)
    {
        try {
            $sql = "UPDATE tb_usuario 
                       SET s_nome = :nome, 
                           s_email = :email,
                           s_email_contato = :email_contato, 
                           i_numero_telefone = :numero_telefone
                     WHERE id_usuario = :id";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(":nome", $usuario->nm_usuario);
            $stmt->bindParam(":email", $usuario->email_usuario);
            $stmt->bindParam(":email_contato", $usuario->email_contato);
            $stmt->bindParam(":numero_telefone", $usuario->numero_telefone);
            $stmt->bindParam(":id", $usuario->id_usuario, PDO::PARAM_INT);

            $stmt->execute();
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            echo json_encode(["erro" => "Falha no update: " . $e->getMessage()]);
            return false;
        }
    }

    public function deletar($id)
    {
        $sql = "DELETE FROM tb_usuario WHERE id_usuario = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        return $stmt->execute();
    }
}
