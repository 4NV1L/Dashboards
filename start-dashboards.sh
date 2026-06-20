#!/bin/bash
# Dual-monitor dashboard kiosk launcher (file:// rotator, no web server)
export DISPLAY=:0

DIR="/home/berrypi/dashboards/Dashboards"     # folder holding the .html dashboards + rotator.html
M2_OFFSET=2560                                 # x-position of the 2nd monitor = width of monitor 1 (check with: xrandr)

# Chromium binary name differs by Pi OS version
CHROME="$(command -v chromium-browser || command -v chromium)"

FLAGS="--kiosk --noerrdialogs --disable-session-crashed-bubble --disable-infobars \
--allow-file-access-from-files --autoplay-policy=no-user-gesture-required \
--check-for-update-interval=31536000 --disable-features=Translate"

# keep the screen awake
xset s off; xset -dpms; xset s noblank

launch() {
  "$CHROME" $FLAGS --user-data-dir=/tmp/kiosk1 --window-position=0,0 \
    "file://$DIR/rotator.html?start=0" >/dev/null 2>&1 &
  PID1=$!
  "$CHROME" $FLAGS --user-data-dir=/tmp/kiosk2 --window-position=${M2_OFFSET},0 \
    "file://$DIR/rotator.html?start=3" >/dev/null 2>&1 &
  PID2=$!
}

launch

# watchdog: if either window dies, restart both
while true; do
  sleep 30
  if ! kill -0 "$PID1" 2>/dev/null || ! kill -0 "$PID2" 2>/dev/null; then
    pkill -f "user-data-dir=/tmp/kiosk" 2>/dev/null
    sleep 2
    launch
  fi
done
