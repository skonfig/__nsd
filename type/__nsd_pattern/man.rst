cdist-type__nsd_pattern(7)
==========================

NAME
----
cdist-type__nsd_pattern - Define NSD patterns


DESCRIPTION
-----------
This type allows to define NSD patterns.
Patterns are required for `cdist-type__nsd_zone`\ (7).


REQUIRED PARAMETERS
-------------------
None.


OPTIONAL PARAMETERS
-------------------
allow-notify
    ``<ip-spec> <key-name | NOKEY | BLOCKED>``

    .. pull-quote::
        Access control list. The listed (primary) address is allowed to send
        notifies to this (secondary) server. Notifies from unlisted or
        specifically BLOCKED addresses are discarded. If ``NOKEY`` is given no
        TSIG signature is required``.  ``BLOCKED`` supersedes other entries,
        other entries are scanned for a match in the order of the statements.

        The ``ip-spec`` is either a plain IP address (IPv4 or IPv6), or can be a
        subnet of the form ``1.2.3.4/24``, or masked like
        ``1.2.3.4&255.255.255.0`` or a range of the form ``1.2.3.4-1.2.3.25``.
        A port number can be added using a suffix of @number, for exam- ple
        ``1.2.3.4@5300`` or ``1.2.3.4/24@5300`` for port 5300.  Note the ip-spec
        ranges do not use spaces around the ``/``, ``&``, ``@`` and ``-``
        symbols.

        -- `nsd.conf`\ (5)

notify
    ``<ip-address> <key-name | NOKEY>``

    .. pull-quote::
        Access control list. The listed address (a secondary) is notified of
        updates to this zone. A port number can be added using a suffix of
        @number, for example ``1.2.3.4@5300``. The specified key is used to sign
        the notify.  Only on secondary configurations will NSD be able to detect
        zone updates (as it gets notified itself, or refreshes after a time).

        -- `nsd.conf`\ (5)

notify-retry
    .. pull-quote::
        This option should be accompanied by notify. It sets the number of
        retries when sending notifies.

        -- `nsd.conf`\ (5)

outgoing-interface
    ``<ip-address>``

    .. pull-quote:::
        Access control list. The listed address is used to request AXFR|IXFR (in
        case of a secondary) or used to send notifies (in case of a primary).

        The ``ip-address`` is a plain IP address (IPv4 or IPv6).  A port number can
        be added using a suffix of @number, for example ``1.2.3.4@5300``.

provide-xfr
    ``<ip-spec> <key-name | NOKEY | BLOCKED>``

    .. pull-quote::
        Access control list. The listed address (a secondary) is allowed to
        request AXFR from this server. Zone data will be provided to the
        address. The specified key is used during AXFR. For unlisted or
        ``BLOCKED`` addresses no data is provided, requests are discarded.
        ``BLOCKED`` supersedes other entries, other entries are scanned for a
        match in the order of the statements.  NSD provides AXFR for its
        secondaries, but IXFR is not implemented (IXFR is implemented for
        request-xfr, but not for provide-xfr).

        The ``ip-spec`` is either a plain IP address (IPv4 or IPv6), or can be a
        subnet of the form ``1.2.3.4/24``, or masked like
        ``1.2.3.4&255.255.255.0`` or a range of the form ``1.2.3.4-1.2.3.25``.
        A port number can be added using a suffix of @number, for exam- ple
        ``1.2.3.4@5300`` or ``1.2.3.4/24@5300`` for port 5300.  Note the
        ``ip-spec`` ranges do not use spaces around the ``/``, ``&``, ``@`` and
        ``-`` symbols.

        -- `nsd.conf`\ (5)


request-xfr
    ``[AXFR|UDP] <ip-address> <key-name | NOKEY>``

    .. pull-quote::

        Access control list. The listed address (the master) is queried for
        AXFR/IXFR on update. A port number can be added using a suffix of
        @number, for example ``1.2.3.4@5300``. The specified key is used during
        AXFR/IXFR.

        If the AXFR option is given, the server will not be contacted with IXFR
        queries but only AXFR requests will be made to the server.  This allows
        an NSD secondary to have a master server that runs NSD. If the AXFR
        option is left out then both IXFR and AXFR requests are made to the
        master server.

        If the UDP option is given, the secondary will use UDP to transmit the
        IXFR requests. You should deploy TSIG when allowing UDP transport, to
        authenticate notifies and zone transfers. Otherwise, NSD is more
        vulnerable for Kaminsky-style attacks. If the UDP option is left out
        then IXFR will be transmitted using TCP.

        -- `nsd.conf`\ (5)

state
    Whether the pattern should be ``present`` or ``absent`` in NSD's
    configuration.
    Defaults to ``present``.

zonefile
    .. pull-quote::
        The file containing the zone information. If this  attribute  is
        present  it  is used to read and write the zone contents. If the
        attribute is absent it prevents writing out of the zone.

    for more information regarding acceptable values, refer tosd.conf\ (5).

zonestats
    .. pull-quote::
        When compiled with ``--enable-zone-stats`` NSD can collect statistics
        per zone.  This name gives the group where statistics are added to.  The
        groups are output from nsd-control stats and stats_noreset.  Default is
        ``""``.  You can use ``"%s"`` to use the name of the zone to track its
        statistics.  If not compiled in, the option can be given but is ignored.

        -- `nsd.conf`\ (5)


extra-option
    Arguments will be included in the ``pattern:`` config block verbatim.


BOOLEAN PARAMETERS
------------------
disallow-axfr-fallback
    .. pull-quote::
        This option should be accompanied by request-xfr. It disallows NSD (as
        secondary) to fallback to AXFR if the primary name server does not
        support IXFR. Default is yes

        -- `nsd.conf`\ (5)

multi-master-check
    .. pull-quote::
        If enabled, checks all masters for the last version.  It uses the
        higher version of all the configured masters.  Useful if you have
        multiple masters that have different version numbers served.

        -- `nsd.conf`\ (5)


EXAMPLES
--------

.. code-block:: sh

    # A "generic" primary zone
    __nsd_pattern master --zonefile /etc/nsd/%s.zone


SEE ALSO
--------
:strong:`nsd.conf`\ (5)


AUTHORS
-------
Dennis Camera <dennis.camera--@--ssrq-sds-fds.ch>


COPYING
-------
Copyright \(C) 2020 Dennis Camera. You can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
