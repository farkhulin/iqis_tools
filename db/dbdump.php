<?php

/**
 * @file
 */

include_once('variables.php');

parse_str($argv[2], $output);

$excluded_tables = explode(',', $output['EXCLUDED_TABLES']);
array_shift($excluded_tables);

include_once('mysqldump.php');

use Ifsnop\Mysqldump as IMysqldump;

if ($output['ACTION'] == 'backup') {
    if ($output['TYPE'] == 'full') {
        $dumpSettings = array(
            'compress' => IMysqldump\Mysqldump::GZIP,
            'add-drop-database' => false,
            'add-drop-table' => false,
            'add-drop-trigger' => true,
            'add-locks' => false,
            'single-transaction' => true,
            'lock-tables' => true,
            'extended-insert' => true,
            'skip-triggers' => false,
            'databases' => false,
            'hex-blob' => true
        );
        $dump = new Ifsnop\Mysqldump\Mysqldump('mysql:host=' . $output["DB_HOST"] . ';dbname=' . $output["DB_NAME"] . '', $output["DB_USER"], $output["DB_PASS"], $dumpSettings);
        $dump->start($output['FILE']);   
    }
}

if ($output['ACTION'] == 'custom_backup') {
    if ($output['TYPE'] == 'full') {
        $dumpSettings = array(
            'compress' => IMysqldump\Mysqldump::GZIP,
            'add-drop-database' => false,
            'add-drop-table' => false,
            'add-drop-trigger' => true,
            'add-locks' => false,
            'single-transaction' => true,
            'lock-tables' => true,
            'extended-insert' => true,
            'skip-triggers' => false,
            'databases' => false,
            'hex-blob' => true
        );
        $dump = new Ifsnop\Mysqldump\Mysqldump('mysql:host=' . $output["DB_HOST"] . ';dbname=' . $output["DB_NAME"] . '', $output["DB_USER"], $output["DB_PASS"], $dumpSettings);
        $dump->start($output['FILE']);   
    }

    if ($output['TYPE'] == 'structure') {
        $dumpSettings = array(
            'compress' => IMysqldump\Mysqldump::GZIP,
            'add-drop-database' => false,
            'add-drop-table' => false,
            'add-drop-trigger' => true,
            'add-locks' => false,
            'single-transaction' => true,
            'lock-tables' => true,
            'extended-insert' => true,
            'skip-triggers' => false,
            'databases' => false,
            'hex-blob' => true,
            'no-data' => true
        );
        $dump = new Ifsnop\Mysqldump\Mysqldump('mysql:host=' . $output["DB_HOST"] . ';dbname=' . $output["DB_NAME"] . '', $output["DB_USER"], $output["DB_PASS"], $dumpSettings);
        $dump->start($output['FILE']);   
    }
    
    if ($output['TYPE'] == 'content') {
        $dumpSettings = array(
            'exclude-tables' => $excluded_tables,
            'compress' => IMysqldump\Mysqldump::GZIP,
            'add-drop-database' => false,
            'add-drop-table' => false,
            'add-drop-trigger' => true,
            'add-locks' => false,
            'single-transaction' => true,
            'no-create-info' => true,
            'lock-tables' => true,
            'extended-insert' => true,
            'skip-triggers' => false,
            'databases' => false,
            'hex-blob' => true
        );
        $dump = new Ifsnop\Mysqldump\Mysqldump('mysql:host=' . $output["DB_HOST"] . ';dbname=' . $output["DB_NAME"] . '', $output["DB_USER"], $output["DB_PASS"], $dumpSettings);
        $dump->start($output['FILE']);   
    }
}
