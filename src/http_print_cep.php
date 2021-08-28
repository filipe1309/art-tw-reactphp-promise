<?php

require './vendor/autoload.php';

use React\Http\Browser;
use Psr\Http\Message\ResponseInterface;

$browser = new Browser();

$ceps = [
    '01311200', // Bela Vista
    '70630904', // Setor Militar Urbano
    '70165900', // Zona Cívico-Administrativa
    '32685888', // Erro, cep não existe.
];

foreach ($ceps as $cep) {
    $browser->get("https://api.postmon.com.br/v1/cep/{$cep}")
    ->then(function(ResponseInterface $response) {
        $endereco = json_decode($response->getBody());
        echo $endereco->bairro . PHP_EOL;
    })
    ->otherwise(function (\Exception $exception) use ($cep) {
        echo 'Erro no CEP: ' . $cep . PHP_EOL;
    });
}
