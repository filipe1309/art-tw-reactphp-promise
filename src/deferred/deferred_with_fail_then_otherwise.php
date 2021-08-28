<?php

require './vendor/autoload.php';

use React\Promise\Deferred;

$deferred = new Deferred();
$promise = $deferred->promise();

function fulfilled($data) {
    echo 'Result: ' . $data . PHP_EOL;
}

function failed($reason) {
    echo 'Error: ' . $reason . PHP_EOL;
}

$promise->then('fulfilled')->otherwise('failed');

$deferred->reject('Internal Error!');
