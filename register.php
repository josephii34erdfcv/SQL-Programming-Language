<?php
// --- secure connection to the database
require ("config.php");
$connection = pg_connect ("host=$DB_HOST dbname=$DB_DATABASE user=$DB_USER password=$DB_PASSWORD");

if (!$connection)
{
  echo "can't connect.";
  exit;
}

$match = "SELECT * FROM users WHERE email like '$_POST[emailsignup]'";
$match = pg_query($match);
$match = pg_fetch_array($match);
if ($match)
{
  echo "Email already exists.";
  exit;
}

$match = "SELECT * FROM users WHERE username like '$_POST[usernamesignup]'";
$match = pg_query($match);
$match = pg_fetch_array($match);
if ($match)
{
  echo "Username already exists.";
  exit;
}

$query = "INSERT INTO users (username, email, password)
VALUES ('$_POST[usernamesignup]', '$_POST[emailsignup]',
crypt('$_POST[passwordsignup]', gen_salt('md5')))";

$result = pg_query($query);

if (!$result)
{
  echo "can't insert value.";
  exit;
}
echo "done";

pg_close($connection);

?>