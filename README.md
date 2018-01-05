# Sysctl and THP Test
Test setting Transparent Huge Pages to madvise and correctly set kernel memory settings so we don't need swap.

# Background

<h4>THP or Transparent Huge Pages</h4>

At some point, the linux kernel enabled THP or Transparent Huge Pages by default as a means to improve memory latency for systems and applications using large amounts of memory.  The theory was this would offload some work from the MMU and improve performance.  The unintended consequence was a greedy computation and offset that results in a slow memory leak within the page mapping in addition to memory IO lag spikes during defragmentation.  Many large memory applications suffer greatly with THP enabled by default.  The most common applications that suffer are Java, MongoDB, Postgres and MySQL.

<h4>Kernel Memory Tuning</h4>

You could spend a solid weak reading religious unscientific arguments about swap, or simply set the correct values in the kernel based on the amount of memory you have and then remove or reduce your swap to less than a few hundred MB.

If you must use swap, consider added zswap.enabled=1 to your grub config to reduce disk IO when swapping. This enables lzo or lz4 compression (depending on kernel version and settings) for contents that would be swapped out to disk.

TL;DR: The kernel waits too long to evacuate caches and also allows users to overcommit memory.  This results in race conditions that get the kernel or kernel modules wedged.  Let's fix that and end the insanity.

# Usage

Prior to running this script, run your applications through memory, CPU and disk performance tests at least a dozen times and note the results in your copy book.

Save this script, chmod 755 and execute it with no arguments or "test" to test settings.

Re-run the same tests at least a dozen times and note the results in your copy book.

Determine if the performance and stability of your system remained the same or improved.

If the performance and stability remained the same or improved, then either implement the settings in your configuration management and / or orchestration system, or run the script again with the argument "perm".

If the performance or stability of your system became worse, try to determine why using a scientific method such as gathering performance metrics of the hardware, operating system and applications.  Or simply reboot to clear the test settings.

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


