<?php

    if($conn)
    {
        consoleLog('disconnect database');
        mysqli_close($conn);
    }
    else
    {
        consoleLog('database not connected. No need to disconnect.');
    }

?>

