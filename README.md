# Sysctl and THP Test
Test setting Transparent Huge Pages to madvise and correctly set kernel memory settings so we don't need swap.

# Background

<h4>THP or Transparent Huge Pages</h4>

At some point, the linux kernel enabled THP or Transparent Huge Pages by default as a means to improve memory latency for systems and applications using large amounts of memory.  The theory was this would offload some work from the MMU and improve performance.  The unintended consequence was a greedy computation and offset that results in a slow memory leak within the page mapping in addition to memory IO lag spikes during defragmentation.  Many large memory applications suffer greatly with THP enabled by default.  The most common applications that suffer are Java, MongoDB, Postgres and MySQL.

<h4>Kernel Memory Tuning</h4>

You could spend a solid weak reading religious unscientific arguments about swap, or simply set the correct values in the kernel based on the amount of memory you have and then remove or reduce your swap to less than a few hundred MB.

If you must use swap, consider added zswap.enabled=1 to your grub config to reduce disk IO when swapping. This enables lzo or lz4 compression (depending on kernel version and settings) for contents that would be swapped out to disk.

Also, if you must use swap, then make sure <a href="https://github.com/ohdns/loopback_crypt_swap">it is encrypted</a>.

TL;DR: The kernel waits too long to evacuate caches and also allows users to overcommit memory.  This results in race conditions that get the kernel or kernel modules wedged.  Let's fix that and end the insanity.

# Usage

Prior to running this script, run your applications through memory, CPU and disk performance tests at least a dozen times and note the results in your copy book.

Save this script, chmod 755 and execute it with no arguments or the argument "test" to test settings.

Re-run the same tests <b>at least</b> a dozen times and note the results in your copy book.

Determine if the performance and stability of your system remained the same or improved.

If the performance and stability remained the same or improved, then either implement the settings in your configuration management and / or orchestration system, or run the script again with the argument "perm".

If the performance or stability of your system became worse, try to determine why using a scientific method such as gathering performance metrics of the hardware, operating system and applications.  Useful tools would be perf, strace and sysdig.  Or simply reboot to clear the test settings.

After documenting the load testing of your hardware, operating system and applications and finding the right kernel memory settings for your system, the next step would be to confine your applications memory and CPU usage inside of cgroups so that a incorrectly configured and / or memory leaking service can not bring the system down.  Configuring cgroups is outside the scope of this repo.  There are a myriad of examples of how to set CGroup limits in your systemd service unit definition file.

___

# Notational Conventions

<p>The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "
OPTIONAL" in this document are to be interpreted as described in <b>RFC-2119</b>.</p>
<br />
<p>The key words "MUST (BUT WE KNOW YOU WON'T)", "SHOULD CONSIDER", and "REALLY SHOULD NOT" are to be interpreted as descr
ibed in <b>RFC-6919</b>.</p>

___


# Assumptions:

It is assumed that your system reads /etc/sysctl.conf for kernel settings.

This is for testing the correct kernel settings on 64 bit linux distributions.  This script is not meant to be used in a production environment.  It is for testing only.  After you have done extensive scientific testing and documented your results, then consider propagating your settings to your performance / DDoS testing environment, then your staging environment and then finally your production environment.

It is assumed that you have set the out of memory behavior in /etc/sysctl.conf to the desired setting.  Read up on vm.panic_on_oom.  Ephemeral services and systems may benefit from setting this to 2 so that a system will completely self heal if people or leaky code manage to overcommit memory.  Databases and file servers should be set to 0.  Hadoop and gluster bricks should be set to 2.  Development and performance servers should be set to 2.


___

License: MIT

Future License (when github adds it): WTFPL  see http://www.wtfpl.net/txt/copying/

___


<br />
 https://blog.nelhage.com/post/transparent-hugepages/    
<br />
 https://access.redhat.com/solutions/46111
<br />
 https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/s-memory-tunables
<br />
 https://tobert.github.io/tldr/cassandra-java-huge-pages.html
<br />
 https://alexandrnikitin.github.io/blog/transparent-hugepages-measuring-the-performance-impact/
<br />
 https://www.perforce.com/blog/tales-field-taming-transparent-huge-pages-linux
<br />
 https://blogs.oracle.com/linux/performance-issues-with-transparent-huge-pages-thp
<br />
 https://fritshoogland.wordpress.com/2017/07/25/linux-memory-usage/
<br />
 https://discuss.aerospike.com/t/tuning-kernel-memory-for-performance/4195
<br />
 https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html-single/performance_tuning_guide/index
<br />


___

<p><b><br />Disclaimer: This software repository contains scripts that are for educational purposes only. The creator of this script assumes no liability for anything at all.  Use at your own peril.  Use of this script in a revenue or SLA impacting enviornment without following scientific proccess and approved change control may result in financial lossses.</b>
<br /><br /></p>


___


