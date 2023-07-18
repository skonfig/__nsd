cdist-type__nsd_zone(7)
=======================

NAME
----
cdist-type__nsd_zone - Manage NSD zones


DESCRIPTION
-----------
This type allows you to manage which zones are hosted by the NSD server running
on the target and what pattern they should be based on.

This type uses :strong:`nsd-control`\ (8) to manage zones dynamically.


OPTIONAL PARAMETERS
-------------------
pattern
   The pattern determines the options for the new zone.
   This parameter is required if ``--state present``.

   The given pattern must already exist when this object is executed.
source
   Copy this zonefile from the host running cdist to the target.
   If source is ``-`` (dash), the contents of stdin are used.

   If not supplied, no zonefile will be created (for slave zones).
state
   One of:

   ``present``
      the zone is hosted by the target
   ``absent``
      the zone is not hosted by the target

   Defaults to: ``present``
zonefile
   Where to store the zonefile.

   Defaults to: ``/etc/nsd/%s.zone``


EXAMPLES
--------

.. code-block:: sh

   # Create a pattern master and a zone using to it.
   __nsd_pattern master
   require=__nsd_pattern/master \
   __nsd_zone example.com \
      --pattern master \
      --source "${__files:?}/zones/example.com.zone"


SEE ALSO
--------
* :strong:`cdist-type__nsd_pattern`\ (7)
* :strong:`nsd-control`\ (8)


AUTHORS
-------
* Dennis Camera <dennis.camera--@--riiengineering.ch>


COPYING
-------
Copyright \(C) 2020,2023 Dennis Camera.
You can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.
