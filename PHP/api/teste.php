<?php
// Coloque este arquivo na pasta /api/ e acesse pelo navegador
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "<h1>Diagnóstico de Arquivos</h1>";

$arquivos = [
    '../config/Banco.php',
    '../model/Questionario.php',
    '../model/Pergunta.php',
    '../model/Alternativa.php',
    '../controller/QuestionarioController.php'
];

foreach ($arquivos as $arq) {
    $caminhoCompleto = __DIR__ . '/' . $arq;
    echo "Tentando carregar: <b>$arq</b> ... ";
    
    if (file_exists($caminhoCompleto)) {
        echo "<span style='color:green'>ENCONTRADO!</span><br>";
        try {
            require_once $caminhoCompleto;
            echo "&nbsp;&nbsp;? Carregado com sucesso (Sintaxe OK)<br>";
        } catch (Throwable $t) {
            echo "&nbsp;&nbsp;? <span style='color:red'>ERRO DE SINTAXE: " . $t->getMessage() . "</span><br>";
        }
    } else {
        echo "<span style='color:red'>FALHOU! (Arquivo não existe ou nome está errado)</span><br>";
    }
    echo "<hr>";
}

echo "Se todos estiverem verdes, o problema é na conexão com o Banco.";
?>