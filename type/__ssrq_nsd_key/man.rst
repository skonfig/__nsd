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
    The algorithm to use for the TSIG key.

    One of: hmac-md5, hmac-sha1, hmac-sha224, hmac-sha256, hmac-sha384,
    hmac-sha512

    Please note that some options might not be available on some systems.

    This parameter is required if ``--state`` is ``present``.
    If ``--state`` is ``absent`` this parameter is ignored.
state
    Whether the TSIG key should be present or absent.
    Either `present` or `absent`, defaults to `present`.
secret
    The secret value (a base64-encoded binary secret; length must be a multiple
    of 4.)

    TSIG secrets can be generated e.g. by using BIND's ``tsig-keygen``:
    .. code-block:: sh

        tsig-keygen -a hmac-sha256 tsig.example.com

    This parameter is required if ``--state`` is ``present``.
    If ``--state`` is ``absent`` this parameter is ignored.



BOOLEAN PARAMETERS
------------------
None.


EXAMPLES
--------

.. code-block:: sh

    # store a TSIG key for example.org (as per nsd.conf(5))
    __ssrq_nsd_key tsig.example.org. --algorithm hmac-sha256 --secret aaaaaabbbbbbccccccdddddd

    # Delete a TSIG key
    __ssrq_nsd_key tsig.legacy.com. --state absent


SEE ALSO
--------
:strong:`nsd.conf`\ (5)


AUTHORS
-------
Dennis Camera <dennis.camera--@--ssrq-sds-fds.ch>


COPYING
-------
Copyright \(C) 2020-2021 Dennis Camera. You can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
