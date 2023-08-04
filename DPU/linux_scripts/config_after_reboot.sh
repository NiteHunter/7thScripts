#!/bin/sh

echo ------- Config after reboot -------

echo Tx Timestamp:
ethtool --set-priv-flags p0 tx_port_ts on
ethtool --set-priv-flags p1 tx_port_ts on

echo -------  END -------