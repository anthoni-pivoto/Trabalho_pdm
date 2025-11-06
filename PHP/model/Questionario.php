<?php

class Questionario {
    public $id_questionario;
    public $id_curso;
    public $nm_questionario;
    public $perguntas = []; // array de Pergunta

    // Construtor com valores default para permitir new Questionario() sem parâmetros
    public function __construct($id_curso = null, $nm_questionario = null, $id_questionario = null) {
        $this->id_curso = $id_curso;
        $this->nm_questionario = $nm_questionario;
        $this->id_questionario = $id_questionario;
        $this->perguntas = [];
    }
}