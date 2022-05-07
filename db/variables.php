<?php

/**
 * @file
 */

$variables_path = realpath(dirname(__FILE__));
$variables_path = explode('/', $variables_path);
array_pop($variables_path);
array_push($variables_path, 'src');
$variables_path = implode('/', $variables_path);

$variables = file($variables_path . '/variables.sh');

$parsed_variables = [];
foreach($variables as $variable) {
    $variable = explode('=', $variable);
    if (count($variable) == 2) {
        $parsed_variables[$variable[0]] = substr($variable[1], 1, -2);
    }
}

extract($parsed_variables, EXTR_PREFIX_SAME, "wddx");
