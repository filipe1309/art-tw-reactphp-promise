<?php

require './vendor/autoload.php';

use React\Promise\Promise;

$promise = new Promise(function(Closure $resolve, Closure $reject) {
    $number = \random_int(1, 1000000);
    if ($number % 2 === 0) {
        $resolve("Gen {$number}: even number.");
    } else {
        $reject("Gen {$number}: odd number.");
    }
});

function resolve($data) {
    echo 'Resolve: ' . $data . PHP_EOL;
}

function reject($reason) {
    echo 'Reject: ' . $reason . PHP_EOL;
}

$promise->then('resolve')->otherwise('reject');
