#!/bin/sh

echo "=================================================="
echo "Rsync version info"
echo "=================================================="
if ! [ -x "$(command -v rsync)" ]; then
  echo 'Error: rsync is not installed.' >&2
else
  rsync --version
fi
echo

echo "=================================================="
echo "Rclone version info"
echo "=================================================="
if ! [ -x "$(command -v rclone)" ]; then
  echo 'Error: rclone is not installed.' >&2
else
  rclone --version
fi
echo

echo "=================================================="
echo "Restic version info"
echo "=================================================="
if ! [ -x "$(command -v restic)" ]; then
  echo 'Error: restic is not installed.' >&2
else
  restic version
fi
echo

echo "=================================================="
echo "iperf3 version info"
echo "=================================================="
if ! [ -x "$(command -v iperf3)" ]; then
  echo 'Error: iperf3 is not installed.' >&2
else
  iperf3 --version
fi
echo

echo "=================================================="
echo "ssh version info"
echo "=================================================="
if ! [ -x "$(command -v ssh)" ]; then
  echo 'Error: ssh is not installed.' >&2
else
  ssh -V
fi
echo
