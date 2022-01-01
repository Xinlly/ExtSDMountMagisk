#!/system/bin/sh

WorkDir=${0%/*}
logFile=/data/adb/00Sev/sdBind/log/sdBind.log
runtimeR=/mnt/runtime/read
runtimeW=/mnt/runtime/write
runtimeD=/mnt/runtime/default
runtimeSheet=(${runtimeR} ${runtimeW} ${runtimeD})
DATA_MEDIA=/data/media
profile=0
#mountDevice=/dev/block/mmcblk1p1
mountDevice=/data/adb/00Sev/emulated/0
mountRootName=expandSev
mountRoot=/mnt/${mountRootName}
mountPoint=${mountRoot}/${profile}
sdBindListTemp=(source direct)
sdBindList=(\
	Backup Backup\
	Documents Documents\
	Download Download\
	Music Music\
	#Download/Join Android/data/com.joaomgcd.join/sdcard/Join\
	#00Real/Music/Netease netease/cloudmusic/Music\
	Pictures Pictures\
	Pictures/JDImage Android/data/com.jingdong.app.mall/sdcard/Pictures/JDImage\
	DCIM DCIM\
	SwiftBackup SwiftBackup\
)


log(){
	echo "[${1}] $(date "+%Y/%m/%d %H:%M:%S") ${2}\t\t${3}" >>${logFile} 2>&1
}
