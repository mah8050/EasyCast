#!/bin/sh
DEVICE_IP="127.0.0.1"
export LD_LIBRARY_PATH=/am7x/:/am7x/lib/

CMD=$(echo "$QUERY_STRING" | sed -n 's/.*cmd=\([^&]*\).*/\1/p')
VAL=$(echo "$QUERY_STRING" | sed -n 's/.*val=\([^&]*\).*/\1/p')

echo "Content-type: text/plain"
echo ""

case "$CMD" in
  Play) /root/cast-control.sh play ;;
  Pause) /root/cast-control.sh pause ;;
  Stop) /root/cast-control.sh stop ;;
  volume)
    [ -n "$VAL" ] && {
      /root/cast-control.sh volume "$VAL"
      echo "$VAL" > /tmp/volume_state
    }
    ;;
  getVolume)
    [ -f /tmp/volume_state ] && cat /tmp/volume_state || echo "50"
    ;;
  getStatus)
    /root/cast-control.sh status
    ;;
  seek)
    [ -n "$VAL" ] && /root/cast-control.sh seek "$VAL"
    ;;
  *)
    echo "Error: unknown or missing command"
    ;;
esac
