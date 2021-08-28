<?php

require './vendor/autoload.php';

use React\Promise\Deferred;

$deferred = new Deferred();

$deferred->promise()
    ->then(function ($data) {
        return "Hello {$data}";
    })
    ->then(function ($data) {
        throw new InvalidArgumentException("Exception: {$data} Web");
    })
    ->otherwise(function (InvalidArgumentException $exception) {
        return strtoupper($exception->getMessage());
    })
    ->done(function ($data) {
        echo "{$data}!" . PHP_EOL;
    });

$deferred->resolve('Treina');
