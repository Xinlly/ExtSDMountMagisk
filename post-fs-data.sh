#!/system/bin/sh
mountDevice=/dev/block/mmcblk1p1
sdExtDevice=/dev/block/mmcblk1p2
mountRoot=/data/adb/00Sev/emulated/0
sdExtDir=/data/sdext2
logDir=/data/adb/00Sev/sdBind/log
logFile=/data/adb/00Sev/sdBind/log/sdBind.log

log(){
	echo "[${1}] $(date "+%Y/%m/%d %H:%M:%S") ${2}\t\t${3}" >>${logFile} 2>&1
}

if [[ ! -d ${logDir} ]]; then
	mkdir -p ${logDir} || echo "logFail" >> /adb/sdbind.log 2>&1
fi

cat /dev/null > ${logFile} || echo "logFail" >> /adb/sdbind.log 2>&1

if [[ ! -d ${mountRoot} ]]; then
	mkdir -p ${mountRoot} || log "e" "[mkdir]" "${mountRoot}"
fi
if [[ ! -d ${sdExtDir} ]]; then
	mkdir -p ${sdExtDir} || log "e" "[mkdir]" "${sdExtDir}"
fi

#sdcard
mount -t ext4 -w ${mountDevice} ${mountRoot}
#第二分区
mount -t ext4 -w ${sdExtDevice} ${sdExtDir}