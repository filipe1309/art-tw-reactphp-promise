<?php

require './vendor/autoload.php';

use React\Promise\Deferred;

$deferred = new Deferred();

$deferred->promise()
    ->then(function ($data) {
        return "Hello {$data}";
    })
    ->then(function ($data) {
        return "{$data} Web";
    })
    ->then(function ($data) {
        return strtoupper($data);
    })
    ->then(function ($data) {
        echo "{$data}!" . PHP_EOL;
    });

$deferred->resolve('Treina');
