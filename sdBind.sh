#!/system/bin/sh
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

mkRoot () {
	#log "i" "[checking]" "${mountRoot}"
	if [[ ! -d ${mountRoot} ]]; then
		mkdir -p ${mountRoot} || log "e" "[mkdir]" "${mountRoot}"
		chown root:sdcard_rw ${mountRoot}
		touch ${mountRoot}/.nomedia
		chown root:sdcard_rw ${mountRoot}/.nomedia
		chmod 0775 ${mountRoot}/.nomedia
	fi
	#log "i" "[checked]" "${mountRoot}"
	for runtime in ${runtimeSheet[@]}
	do
		runtimeLs=${runtime}/${mountRootName}
		if [[ ! -L ${runtimeLs} ]]; then
			ln -sf ${mountRoot} ${runtimeLs} || log "e" "[linked]" "${mountRoot} ——→ ${runtimeLs}"
	  	fi
	done
}

mountRoot () {
	if mount |grep -q ${mountPoint}; then
		#log "i" "[Umounting]" "${mountPoint}"
		su -M -c umount ${mountPoint} || log "e" "[Umounted]" "${mountPoint}"
	fi
	#log "i" "[checking]" "${mountPoint}"
	if [[ ! -d ${mountPoint} ]]; then
		#log "i" "[making]" "${mountPoint}"
    mkdir -p ${mountPoint} || log "e" "[mkdir]" "${mountPoint}"
    chown root:sdcard_rw ${mountPoint}
  fi
    #log "i" "[checked]" "${mountPoint}"
    if ! mount |grep -q ${mountPoint}; then
	  #log "i" "[Mounting]" "${mountDevice} ——→ ${mountPoint}"
		su -M -c bindfs -u root -g 1015 -p 0775 ${mountDevice} ${mountPoint} || log "e" "[Mount]" "${mountDevice} ——→ ${mountPoint}"
	fi
}

sdUnbinder () {
	index=0
	while (( index<${#sdBindList[@]} ))
	do
		directForMedia=${profile}/${sdBindList[index+1]}
		for runtime in ${runtimeSheet[@]}
		do
			mountDirect=${runtime}/emulated/${directForMedia}
			#log "i" "[checking]" "${mountDirect}"
			if mount |grep -q ${mountDirect}; then
				#log "i" "[Unmounting]" "${mountDirect}"
				su -M -c umount ${mountDirect} || log "e" "[Unmounted]" "${mountDirect}"
			fi
			#log "i" "[checked]" "${mountDirect}"
		done
		let "index+=2"
	done
}

sdBinder () {
	index=0
	while (( index<${#sdBindList[@]} ))
	do
		mountSource=${mountPoint}/${sdBindList[index]}
		directForMedia=${profile}/${sdBindList[index+1]}
		realDirect=${DATA_MEDIA}/${directForMedia}
		#log "i" "[checking]" "${mountSource}"
		if [[ ! -d ${mountSource} ]] && mount |grep -q ${mountPoint}; then
			#log "i" "[making]" "${mountSource}"
	    mkdir -p ${mountSource} || log "e" "[made]" "${mountSource}"
    fi
    if [[ -d ${mountSource} ]]; then
    	chown root:everybody ${mountSource}
    	chmod 0775 ${mountSource}
    fi
    #log "i" "[checked]" "${mountSource}"
		#log "i" "[checking]" "${realDirect}"
		if [[ ! -d ${realDirect} ]]; then
			#log "i" "[making]" "${realDirect}"
	    mkdir -p ${realDirect} || log "e" "[made]" "${realDirect}"
	    chown media_rw:media_rw ${realDirect}
    fi
    #log "i" "[checked]" "${realDirect}"
		for runtime in ${runtimeSheet[@]}
		do
			mountDirect=${runtime}/emulated/${directForMedia}
			#log "i" "[checking]" "${mountDirect}"
			if ! mount |grep -q ${mountDirect} && mount |grep -q ${mountPoint}; then
				#log "i" "[Mounting]" "${mountSource} ——→ ${mountDirect}"
				su -M -c bindfs -u root -g 9997 -p 0775 ${mountSource} ${mountDirect} || log "e" "[Mounted]" "${mountSource} ——→ ${mountDirect}"
			fi
			#log "i" "[checked]" "${mountDirect}"
		done
		let "index+=2"
	done
}

log "i" "[Start]" ""
sdUnbinder
mkRoot
mountRoot
sdBinder
log "i" "[Done]" ""
exit 0