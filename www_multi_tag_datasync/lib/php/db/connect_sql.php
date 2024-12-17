<?php

    $SQL_HOST= '59.127.63.9';
    $SQL_HOSTNAME = 'multi_tag_datasync';
    $SQL_PASSWORD = 'multi_tag_datasync';
    $SQL_DB_NAME = "www_multi_tag_datasync";
    $SQL_PORT = 8650;

    $conn = new mysqli($SQL_HOST, $SQL_HOSTNAME, $SQL_PASSWORD, $SQL_DB_NAME, $SQL_PORT);

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

?>

