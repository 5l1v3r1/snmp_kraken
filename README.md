snmp_kraken
===========

Downloads MIB of multiple SNMP-enabled devices.

Usage
-----

You can use `pull_data.sh` to invoke a single scan and `release.sh` to scan
many IP addresses at once.

Here's an example run of `pull_data.sh`:

    $ ./pull_data.sh 1.3.6.1.2.1.1.2 /tmp 1.2.3.4

This will write a pcap file and text files containing the output of `snmpwalk`
to /tmp.

If you want to scan several addresses in parallel, you need to put all IP
addresses in a text file and separate them by newlines.  Then, you can run
`release.sh`:

    $ ./release.sh /path/to/address_list 1.3.6.1.2.1.1

This will write the output of all `snmpwalk` instances to a randomly generated
directory in /tmp.

By default, `release.sh` runs 10 instances of `snmpwalk` at once.

Feedback
--------

Contact: Philipp Winter <phw@nymity.ch>  
OpenPGP fingerprint: `B369 E7A2 18FE CEAD EB96  8C73 CF70 89E3 D7FD C0D0`
