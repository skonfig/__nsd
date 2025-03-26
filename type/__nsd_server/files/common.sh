# shellcheck disable=SC2034
#
# 2023 Dennis Camera (dennis.camera at riiengineering.ch)
#
# This file is part of the skonfig set __nsd.
#
# This set is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This set is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this set. If not, see <http://www.gnu.org/licenses/>.
#

CONF_BASE_DIR='/etc/nsd'
nsd_conf="${CONF_BASE_DIR}/nsd.conf"

os=$(cat "${__global:?}/explorer/os")

case ${os}
in
	(debian|devuan)
		package_name=nsd
		;;
	(*)
		: "${__type:?}"  # make shellcheck happy
		printf 'Your operating system (%s) is currently not supported by this type (%s)\n' "${os}" "${__type##*/}" >&2
		printf 'Please contribute an implementation for it if you can.\n' >&2
		exit 1
		;;
esac
