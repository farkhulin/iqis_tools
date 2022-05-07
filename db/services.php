<?php

/**
 * @file
 */

include_once('variables.php');

parse_str($argv[2], $output);

$dbname = $output['DB_NAME'];
$host = $output['DB_HOST'];
$username = $output['DB_USER'];
$password = $output['DB_PASS'];
$db_prefix = $output['DB_PREFIX'];
$drupal_legacy = $output['DRUPAL_LEGACY'];
$drupal_path = $output['DRUPAL_PATH'];
$current = $output['CURRENT'];

if ($output['ACTION'] == 'clear_cache') {
    $conn = new mysqli($host, $username, $password, $dbname);

    $result = mysqli_query($conn, "show tables");
    while ($table = mysqli_fetch_array($result)) {
        if (strpos($db_prefix.$table[0], 'cache') === 0) {
            echo shell_exec('echo -e "' . $TS . $SCS . ' table cleared: ' . $WHITE . $table[0] . $NC . '"');
            mysqli_query($conn, "TRUNCATE TABLE `" . $db_prefix.$table[0] . "`");
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        }
    }

    $conn->close();
}

if ($output['ACTION'] == 'clear_cache_silent') {
    $conn = new mysqli($host, $username, $password, $dbname);

    $result = mysqli_query($conn, "show tables");
    while ($table = mysqli_fetch_array($result)) {
        if (strpos($db_prefix.$table[0], 'cache') === 0) {
            mysqli_query($conn, "TRUNCATE TABLE `" . $db_prefix.$table[0] . "`");
        }
    }

    $conn->close();
}

echo shell_exec('echo -ne "' . $TS . $TS. $TS. $TS . $TS . $TS .'\r"');
