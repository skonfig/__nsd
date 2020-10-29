cdist-type__ssrq_nsd_server(7)
==============================

NAME
----
cdist-type__ssrq_nsd_server - Install and manage configuration of an NSD server


DESCRIPTION
-----------

This type can be used to install the NSD server daemon and manage it's server
configuration (in ``/etc/nsd/nsd.conf`` that is).

Distribution default values will be kept in the config file, unless a parameter
to this type explicitly overwrites the value to something else.
Also note that removing a singleton optional parameter later on will not restore
the distribution default, but simply leave the config as it is.
Removing a multiple optional parameter will remove that value from the config.


REQUIRED PARAMETERS
-------------------
None.


OPTIONAL PARAMETERS
-------------------
database
    Specifies the file that is used to store the compiled zone information.
    If set to an empty value then no database is used.

    This uses less memory but zone updates are not (immediately) spooled to
    disk.
interface
    Specifies an interface for NSD to listen on:
    ``<ip4 or ip6>[@port] [servers] [bindtodevice] [setfib]``

    Can be used multiple times listen on more than one interface.

    For more information, please refer to :strong:`nsd.conf`\ (5).
port
    The port NSD should answer queries on.
rc-interface
    An interface for NSD to listen on for remote control:
    ``<ip4 or ip6 or filename>``

    Can be used multiple times to bind on multiple interfaces.

    If an absolute path is used, a UNIX local named pipe is created (and key and
    cert files are not needed, use directory permissions).
rc-port
    The port number the remote control service should listen on.
state
    ``present`` to install NSD, ``absent`` to uninstall.
    Defaults to ``present``.
zonesdir
    The directory on the target in which zonefiles are stored.
    The NSD daemon will `chdir`\ (2) there.


BOOLEAN PARAMETERS
------------------
hide-identity
    Configure NSD to not answer ``HOSTNAME.BIND`` and ``ID.SERVER`` ``CHAOS``
    class queries.
hide-version
    Configure NSD to not answer ``VERSION.BIND`` and ``VERSION.SERVER``
    ``CHAOS`` class queries.
refuse-any
    Configure NSD to refuse ``ANY`` type queries.
no-ipv4
    Do not listen on IPv4 port.
no-ipv6
    Do not listen on IPv6 port.
no-remote-control
    Disable remote control with nsd-control(8) completely.

    NB: Enabling this option will break the other __ssrq_nsd_* types.*


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
:strong:`nsd`\ (8), :strong:`nsd.conf`\ (5)


AUTHORS
-------
Dennis Camera <dennis.camera@ssrq-sds-fds.ch>


COPYING
-------
Copyright \(C) 2020 Dennis Camera. You can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
