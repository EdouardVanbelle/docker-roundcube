root@roundcube:/home/roundcube/plugins/newmail_notifier# cat config.inc.php.dist
<?php

// Enables basic notification
$config['newmail_notifier_basic'] = false;

// Enables sound notification
$config['newmail_notifier_sound'] = false;

// Enables desktop notification
$config['newmail_notifier_desktop'] = true;

// Desktop notification close timeout in seconds
$config['newmail_notifier_desktop_timeout'] = 10;

?>
