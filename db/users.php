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
$drupal_legacy = $output['DRUPAL_LEGACY'];

/**
 * Tuncate table 'flood'.
 */
function clear_flood($host, $username, $password, $dbname, $TS, $SCS, $NC, $ERR, $RED) {
    $conn = new mysqli($host, $username, $password, $dbname);
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    $sql = "TRUNCATE TABLE `flood`";
    if ($conn->query($sql) === TRUE) {
        echo shell_exec('echo -e "' . $TS . $SCS . ' Flood clear successfully."');
    }
    else {
        echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' clear flood. ' . $conn->error . '"');
    }
    $sql = '';

    $conn->close();
}

if ($output['ACTION'] == 'admin_info') {
    if ($drupal_legacy == '7') {
        $conn = new mysqli($host, $username, $password, $dbname);
        $result = mysqli_query($conn, "SELECT name, mail, created, access, login FROM users WHERE uid = 1");
        $admin_info = mysqli_fetch_assoc($result);
        $conn->close();
    }
    else {
        $conn = new mysqli($host, $username, $password, $dbname);
        $result = mysqli_query($conn, "SELECT name, mail, created, access, login FROM users_field_data WHERE uid = 1");
        $admin_info = mysqli_fetch_assoc($result);
        $conn->close();
    }

    echo shell_exec('echo');
    echo shell_exec('echo -e "Root admin ' . $WHITE . 'login' . $NC . ':        ' . $admin_info['name'] . '"');
    echo shell_exec('echo -e "Root admin ' . $WHITE . 'email' . $NC . ':        ' . $admin_info['mail'] . '"');
    echo shell_exec('echo -e "Root admin ' . $WHITE . 'created' . $NC . ':      ' . date('Y.m.d H:i:s', ($admin_info['created'] + 3*60*60)) . ' MSK"');
    echo shell_exec('echo -e "Root admin ' . $WHITE . 'last access' . $NC . ':  ' . date('Y.m.d H:i:s', ($admin_info['access'] + 3*60*60)) . ' MSK"');
    echo shell_exec('echo -e "Root admin ' . $WHITE . 'last login' . $NC . ':   ' . date('Y.m.d H:i:s', ($admin_info['login'] + 3*60*60)) . ' MSK"');
    echo shell_exec('echo');
}

if ($output['ACTION'] == 'reset_admin') {
    if ($drupal_legacy == '7') {
        require_once $output['DRUPAL_PATH'] . '/includes/bootstrap.inc';
        require_once $output['DRUPAL_PATH'] . 'includes/password.inc';

        $hash = user_hash_password('admin');

        if (strlen($hash) > 5) {
            // echo shell_exec('echo -e "' . $TS . $SCS . ' HASH for password admin: ' . $WHITE . $hash . $NC . '"');

            $conn = new mysqli($host, $username, $password, $dbname);
            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }
            $sql = "UPDATE users SET pass='" . $hash . "' WHERE uid = 1";
            if ($conn->query($sql) === TRUE) {
                echo shell_exec('echo -e "' . $TS . $SCS . ' Database UDATED successfully for uid 1"');
            }
            else {
                echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' UPDATE database for uid = 1. ' . $conn->error . '"');
            }
            $sql = '';
    
            $conn->close();
            clear_flood($host, $username, $password, $dbname, $TS, $SCS, $NC, $ERR, $RED);
        }
        else {
            echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' HASH innvalid, try agan!"');
        }
    }
    else {
        $hash = shell_exec("php core/scripts/password-hash.sh 'admin'");
        $hash = explode('hash:', $hash);
        $hash = trim($hash[1]);
        if (strlen($hash) > 5) {
            // echo shell_exec('echo -e "' . $TS . $SCS . ' HASH for password admin: ' . $WHITE . $hash . $NC . '"');

            $conn = new mysqli($host, $username, $password, $dbname);
            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }
            $sql = "UPDATE users_field_data SET pass='" . $hash . "' WHERE uid = 1";
            if ($conn->query($sql) === TRUE) {
                echo shell_exec('echo -e "' . $TS . $SCS . ' Database UDATED successfully for uid 1."');
            }
            else {
                echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' UPDATE database for uid = 1. ' . $conn->error . '"');
                
            }
            $sql = "TRUNCATE TABLE `cache_entity`";
            if ($conn->query($sql) === TRUE) {
                echo shell_exec('echo -e "' . $TS . $SCS . ' Database clear cache_entity successfully."');
            }
            else {
                echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' clear cache_entity table. ' . $conn->error . '"');
            }
            $sql = '';
    
            $conn->close();
            clear_flood($host, $username, $password, $dbname, $TS, $SCS, $NC, $ERR, $RED);
        }
        else {
            echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' HASH innvalid, try agan!"');
        }
    }
}
