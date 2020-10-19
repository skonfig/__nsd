cdist-type__ssrq_nsd_key(7)
===========================

NAME
----
cdist-type__ssrq_nsd_key - Manage TSIG keys in NSD


DESCRIPTION
-----------
This type can be used to manage TSIG keys for NLnet Labs' Name Server Daemon
(NSD).


REQUIRED PARAMETERS
-------------------
None.


OPTIONAL PARAMETERS
-------------------
algorithm
    The algorithm to use.

    One of: hmac-md5, hmac-sha1, hmac-sha224, hmac-sha256, hmac-sha384,
    hmac-sha512
state
    Whether the TSIG key should be present or absent.
    Either `present` or `absent`, defaults to `present`.
secret
    The secret value (not base64 encoded.)


BOOLEAN PARAMETERS
------------------
None.


EXAMPLES
--------

.. code-block:: sh

    # store a TSIG key for example.org (as per nsd.conf(5))
    __ssrq_nsd_key tsig.example.org. --algorithm hmac-md5 --secret aaaaaabbbbbbccccccdddddd

    # Generate and stoer a TSIG key for example.com
    __ssrq_nsd_key tsig.example.com. --algorithm hmac-md5

    # Delete a TSIG key
    __ssrq_nsd_key tsig.legacy.com. --state absent


SEE ALSO
--------
:strong:`nsd.conf`\ (5)


AUTHORS
-------
Dennis Camera <dennis.camera@ssrq-sds-fds.ch>


COPYING
-------
Copyright \(C) 2020 Dennis Camera. You can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
