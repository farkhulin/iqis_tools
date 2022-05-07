<?php

/**
 * @file
 */

include_once('variables.php');

parse_str($argv[2], $output);

$excluded_tables = explode(',', $output['EXCLUDED_TABLES']);
array_shift($excluded_tables);

if ($output['ACTION'] == 'custom_restore') {
    $dbname = $output['DB_NAME'];
    $host = $output['DB_HOST'];
    $username = $output['DB_USER'];
    $password = $output['DB_PASS'];
    $dump_file = $output['FILE'];

    echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");

    if ($output['TYPE'] == 'full') {
        $conn = new mysqli($host, $username, $password);
        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        } 
         
        // DROP database.
        $sql = "DROP DATABASE " . $dbname . "";
        if ($conn->query($sql) === TRUE) {
            echo shell_exec('echo -e "' . $TS . $SCS . ' Database DROP successfully."');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        } else {
            echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' DROP database. ' . $conn->error . '"');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        }

        // CREATE database.
        $sql = "CREATE DATABASE " . $dbname . "";
        if ($conn->query($sql) === TRUE) {
            echo shell_exec('echo -e "' . $TS . $SCS . ' Database CREATED successfully."');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        } else {
            echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' CREATE database. ' . $conn->error . '"');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        }

        $conn->close();

        // RESTORE database.
        $conn = new mysqli($host, $username, $password, $dbname); 

        $sql = '';
 
        $lines = gzopen($dump_file, 'r');
     
        while ($line = fgets($lines)) {
            //skip comments
            if (substr($line, 0, 2) == '--' || $line == '') {
                continue;
            }
     
            $sql .= $line;
            if (substr(trim($line), -1, 1) == ';') {
                $query = $conn->query($sql);
                if (!$query) {
                    echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' RECOVER database. ' . $conn->error . '"');
                    echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
                }
                $sql = '';
            }
        }
         
        $conn->close();
    }

    if ($output['TYPE'] == 'structure') {
        $conn = new mysqli($host, $username, $password);
        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        } 
         
        // DROP database.
        $sql = "DROP DATABASE " . $dbname . "";
        if ($conn->query($sql) === TRUE) {
            echo shell_exec('echo -e "' . $TS . $SCS . ' Database DROP successfully."');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        } else {
            echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' DROP database. ' . $conn->error . '"');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        }

        // CREATE database.
        $sql = "CREATE DATABASE " . $dbname . "";
        if ($conn->query($sql) === TRUE) {
            echo shell_exec('echo -e "' . $TS . $SCS . ' Database CREATED successfully."');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        } else {
            echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' CREATE database. ' . $conn->error . '"');
            echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
        }

        $conn->close();

        // RESTORE ONLY STRUCTURE database.
        $conn = new mysqli($host, $username, $password, $dbname); 

        $sql = '';
 
        $lines = gzopen($dump_file, 'r');
     
        while ($line = fgets($lines)) {
            //skip comments
            if (substr($line, 0, 2) == '--' || $line == '') {
                continue;
            }
     
            $sql .= $line;
            if (substr(trim($line), -1, 1) == ';') {
                $query = $conn->query($sql);
                if (!$query) {
                    echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' RECOVER database. ' . $conn->error . '"');
                    echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
                }
                $sql = '';
            }
        }
         
        $conn->close();
    }
    
    if ($output['TYPE'] == 'content') {
        $conn = new mysqli($host, $username, $password, $dbname);

        $result = mysqli_query($conn, "show tables");
        while ($table = mysqli_fetch_array($result)) {
            if (in_array($table[0], $excluded_tables)) {
                echo shell_exec('echo -e "' . $TS . $SCS . ' ' . $WHITE . $table[0] . $NC . ' - was excluded from cleaning"');
                echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
            }
            else {
                mysqli_query($conn, "TRUNCATE TABLE `" . $table[0] . "`");
            }
        }

        $conn->close();

        // RESTORE ONLY CONTENT database.
        $conn = new mysqli($host, $username, $password, $dbname); 

        $sql = '';
 
        $lines = gzopen($dump_file, 'r');
     
        while ($line = fgets($lines)) {
            //skip comments
            if (substr($line, 0, 2) == '--' || $line == '') {
                continue;
            }
     
            $sql .= $line;
            if (substr(trim($line), -1, 1) == ';') {
                $query = $conn->query($sql);
                if (!$query) {
                    echo shell_exec('echo -e "' . $TS . $ERR . ' ' . $RED . 'Error' . $NC . ' RECOVER database. ' . $conn->error . '"');
                    echo shell_exec("echo -en '" . $TS .$WAITING_MESSAGE . "\r'");
                }
                $sql = '';
            }
        }
         
        $conn->close();
    }

    echo shell_exec('echo -ne "' . $TS . $TS. $TS. $TS . $TS . $TS .'\r"');
}
