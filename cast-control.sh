#!/bin/sh
# cast-control.sh - control EzCast device

DEVICE_IP="127.0.0.1"
DEBUG=0   # set to 1 if you want to see raw SOAP replies

send_soap() {
    SERVICE="$1"
    ACTION="$2"
    BODY="$3"

    if [ "$DEBUG" -eq 1 ]; then
        # Show SOAP reply for debugging
        curl -s -X POST http://$DEVICE_IP:60099/$SERVICE/control \
            -H "Content-Type: text/xml; charset=utf-8" \
            -H "SOAPAction: \"urn:schemas-upnp-org:service:$SERVICE:1#$ACTION\"" \
            -d "$BODY"
    else
        # Hide SOAP reply
        curl -s -X POST http://$DEVICE_IP:60099/$SERVICE/control \
            -H "Content-Type: text/xml; charset=utf-8" \
            -H "SOAPAction: \"urn:schemas-upnp-org:service:$SERVICE:1#$ACTION\"" \
            -d "$BODY" > /dev/null 2>&1
    fi
}

play() {
    send_soap "AVTransport" "Play" "<?xml version='1.0'?>
<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
  <s:Body>
    <u:Play xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>
      <InstanceID>0</InstanceID>
      <Speed>1</Speed>
    </u:Play>
  </s:Body>
</s:Envelope>"
    echo "OK: Play executed"
}

pause() {
    send_soap "AVTransport" "Pause" "<?xml version='1.0'?>
<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
  <s:Body>
    <u:Pause xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>
      <InstanceID>0</InstanceID>
    </u:Pause>
  </s:Body>
</s:Envelope>"
    echo "OK: Pause executed"
}

stop() {
    send_soap "AVTransport" "Stop" "<?xml version='1.0'?>
<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
  <s:Body>
    <u:Stop xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>
      <InstanceID>0</InstanceID>
    </u:Stop>
  </s:Body>
</s:Envelope>"
    echo "OK: Stop executed"
}

set_volume() {
    VOL="$1"
    [ -z "$VOL" ] && echo "Usage: $0 volume <0-100>" && exit 1

    send_soap "RenderingControl" "SetVolume" "<?xml version='1.0'?>
<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
  <s:Body>
    <u:SetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>
      <InstanceID>0</InstanceID>
      <Channel>Master</Channel>
      <DesiredVolume>$VOL</DesiredVolume>
    </u:SetVolume>
  </s:Body>
</s:Envelope>"
    echo "OK: Volume set to $VOL"
}



status() {
    REPLY=$(curl -s -X POST http://$DEVICE_IP:60099/AVTransport/control \
        -H "Content-Type: text/xml; charset=utf-8" \
        -H "SOAPAction: \"urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo\"" \
        -d "<?xml version='1.0'?>
<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
  <s:Body>
    <u:GetPositionInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>
      <InstanceID>0</InstanceID>
    </u:GetPositionInfo>
  </s:Body>
</s:Envelope>")

    # Extract with basic sed (no extended regex)
    TRACK=$(echo "$REPLY" | sed -n 's/.*<dc:title>\(.*\)<\/dc:title>.*/\1/p')
    POS=$(echo "$REPLY" | sed -n 's/.*<RelTime>\(.*\)<\/RelTime>.*/\1/p')
    DUR=$(echo "$REPLY" | sed -n 's/.*<TrackDuration>\(.*\)<\/TrackDuration>.*/\1/p')

    [ -z "$TRACK" ] && TRACK="(unknown)"
    [ -z "$POS" ] && POS="0:00:00"
    [ -z "$DUR" ] && DUR="0:00:00"

    # Get play state with GetTransportInfo
    STATE_REPLY=$(curl -s -X POST http://$DEVICE_IP:60099/AVTransport/control \
        -H "Content-Type: text/xml; charset=utf-8" \
        -H "SOAPAction: \"urn:schemas-upnp-org:service:AVTransport:1#GetTransportInfo\"" \
        -d "<?xml version='1.0'?>
<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
  <s:Body>
    <u:GetTransportInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>
      <InstanceID>0</InstanceID>
    </u:GetTransportInfo>
  </s:Body>
</s:Envelope>")

    STATE=$(echo "$STATE_REPLY" | sed -n 's/.*<CurrentTransportState>\(.*\)<\/CurrentTransportState>.*/\1/p')
    [ -z "$STATE" ] && STATE="UNKNOWN"

    echo "$STATE | $TRACK | $POS / $DUR"
}
seek() {
    TIME="$1"
    [ -z "$TIME" ] && echo "Usage: $0 seek HH:MM:SS" && exit 1

    send_soap "AVTransport" "Seek" "<?xml version='1.0'?>
<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
  <s:Body>
    <u:Seek xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>
      <InstanceID>0</InstanceID>
      <Unit>REL_TIME</Unit>
      <Target>$TIME</Target>
    </u:Seek>
  </s:Body>
</s:Envelope>"
    echo "OK: Seek to $TIME"
}


# Main argument dispatch
CMD="$1"
ARG="$2"
case "$CMD" in
    play) play ;;
    pause) pause ;;
    stop) stop ;;
    volume) set_volume "$ARG" ;;
    seek) seek "$ARG" ;;
    status) status ;;
    *) echo "Usage: $0 {play|pause|stop|volume <0-100>|seek <HH:MM:SS>|status}" ;;
esac

