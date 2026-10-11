#!/bin/sh
# Turns off the macOS application firewall so a local dev server is reachable from
# other machines on the network.
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode off
