cdist-type__ssrq_nsd_server(7)
==============================

NAME
----
cdist-type__ssrq_nsd_server - TODO


DESCRIPTION
-----------
This space intentionally left blank.


REQUIRED PARAMETERS
-------------------
None.


OPTIONAL PARAMETERS
-------------------
state
    present to install nsd, absent to uninstall


BOOLEAN PARAMETERS
------------------
None.


EXAMPLES
--------

.. code-block:: sh

    # Install a NSD server with default settings
    __ssrq_nsd_server


BUGS
----
This type assumes that the main server config is located at
``/etc/nsd/nsd.conf`` on the target.
Furthermore, a sanely formatted `nsd.conf` file is assumed, i.e. only one
configuration option on a single line.


SEE ALSO
--------
:strong:`TODO`\ (7)


AUTHORS
-------
Dennis Camera <dennis.camera@ssrq-sds-fds.ch>


COPYING
-------
Copyright \(C) 2020 Dennis Camera. You can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
