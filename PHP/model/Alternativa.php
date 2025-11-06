<?php
class Alternativa {
    public $id_alternativa;
    public $id_pergunta;
    public $ds_alternativa;
    public $correta;

    // Já tinha valores default, só deixei consistente
    public function __construct($ds_alternativa = null, $correta = false, $id_pergunta = null, $id_alternativa = null) {
        $this->ds_alternativa = $ds_alternativa;
        $this->correta = (bool)$correta;
        $this->id_pergunta = $id_pergunta;
        $this->id_alternativa = $id_alternativa;
    }
}