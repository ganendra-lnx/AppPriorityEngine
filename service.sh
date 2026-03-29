#!/system/bin/sh

MODDIR=${0%/*}

log_tag="AppPriorityEngine"

# daftar app target (bisa kamu tambah)
TARGET_APPS="
com.mobile.legends
com.tencent.ig
com.dts.freefireth
com.activision.callofduty.shooter
"

# fungsi boost
boost_app() {
  APP=$1
  PID=$(pidof $APP)

  if [ ! -z "$PID" ]; then
    # naikkan prioritas CPU
    renice -10 $PID 2>/dev/null

    # set governor performa (kalau support)
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      echo performance > $gov 2>/dev/null
    done

    log -t $log_tag "Boosting $APP (PID: $PID)"
  fi
}

# fungsi normalisasi
normalize_cpu() {
  for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil > $gov 2>/dev/null
  done
}

while true; do

  CURRENT_APP=$(dumpsys window | grep mCurrentFocus)

  FOUND=0

  for APP in $TARGET_APPS; do
    echo "$CURRENT_APP" | grep -q "$APP"
    if [ $? -eq 0 ]; then
      boost_app $APP
      FOUND=1
    fi
  done

  if [ $FOUND -eq 0 ]; then
    normalize_cpu
  fi

  sleep 5
done