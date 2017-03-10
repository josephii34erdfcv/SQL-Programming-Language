<?php
// --- secure connection to the database
require ("config.php");
$connection = pg_connect ("host=$DB_HOST dbname=$DB_DATABASE user=$DB_USER password=$DB_PASSWORD");

header('location: welcome.html');
?>