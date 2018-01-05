# Sysctl and THP Test
Test setting Transparent Huge Pages to madvise and correctly set kernel memory settings so we don't need swap.

# Usage

Prior to running this script, run your applications through memory, CPU and disk performance tests at least a dozen times and note the results in your copy book.

Save this script, chmod 755 and execute it with no arguments or "test" to test settings.

Re-run the same tests at least a dozen times and note the results in your copy book.

Determine if the performance and stability of your system improved.

If the performance and stability improved, then either implement the settings in your configuration management and / or orchestration system, or run the script again with the argument "perm".

___

# Notational Conventions

<p>The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "
OPTIONAL" in this document are to be interpreted as described in <b>RFC-2119</b>.</p>
<br />
<p>The key words "MUST (BUT WE KNOW YOU WON'T)", "SHOULD CONSIDER", and "REALLY SHOULD NOT" are to be interpreted as descr
ibed in <b>RFC-6919</b>.</p>

___

# Known Issues and Limitations / TO-DO's:

This is for testing the correct kernel settings on 64 bit linux distributions.

# Assumptions:

It is assumed that your system reads /etc/sysctl.conf for kernel settings.


___

License: MIT

Future License (when github adds it): WTFPL  see http://www.wtfpl.net/txt/copying/

___

<p><b><br />Disclaimer: This software repository contains scripts that are for educational purposes only. The creator of this script assumes no liability for anything at all. Use at your own peril.</b>
<br /><br />


___


