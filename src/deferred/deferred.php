<?php

require './vendor/autoload.php';

use React\Promise\Deferred;

$deferred = new Deferred();
$promise = $deferred->promise();

function fulfilled($data) {
    echo 'Result: ' . $data . PHP_EOL;
}

$promise->done('fulfilled');

$deferred->resolve('Hello World!');
