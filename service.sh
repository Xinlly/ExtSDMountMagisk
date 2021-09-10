#!/system/bin/sh
# 请不要硬编码/magisk/modname/...;相反，请使用$MODDIR/...
# 这将使您的脚本兼容，即使Magisk以后改变挂载点
MODDIR=${0%/*}

# 该脚本将在设备开机后作为延迟服务启动

# 下面，你也可以添加一些自己的代码

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
	test test\
	Download Download\
	Download/Join Android/data/com.joaomgcd.join/sdcard/Join\
)


log(){
	echo "[${1}] $(date "+%Y/%m/%d %H:%M:%S") ${2}\t\t${3}" #>>${WorkingDirectory}/mount.log 2>&1
}

log "i" "[Start]" ""
mkRoot () {
	log "i" "[checking]" "${mountRoot}"
	if [[ ! -d ${mountRoot} ]]; then
		mkdir -p ${mountRoot}
		chown root:sdcard_rw ${mountRoot}
		touch ${mountRoot}/.nomedia
		chown root:sdcard_rw ${mountRoot}/.nomedia
		chmod 0775 ${mountRoot}/.nomedia
	fi
	log "i" "[checked]" "${mountRoot}"
	for runtime in ${runtimeSheet[@]}
	do
		runtimeLs=${runtime}/${mountRootName}
		if [[ ! -L ${runtimeLs} ]]; then
			ln -sf ${mountRoot} ${runtimeLs}
			log "i" "[linked]" "${mountRoot} ——→ ${runtimeLs}"
	  	fi
	done
}

mountRoot () {
	if mount |grep -q ${mountPoint}; then
		log "i" "[Umounting]" "${mountPoint}"
		su -M -c umount ${mountPoint}
		log "i" "[Umounted]" "${mountPoint}"
	fi
	log "i" "[checking]" "${mountPoint}"
	if [[ ! -d ${mountPoint} ]]; then
		log "i" "[making]" "${mountPoint}"
    mkdir -p ${mountPoint}
    log "i" "[made]" "${mountPoint}"
    chown root:sdcard_rw ${mountPoint}
  fi
    log "i" "[checked]" "${mountPoint}"
    if ! mount |grep -q ${mountPoint}; then
	  log "i" "[Mounting]" "${mountDevice} ——→ ${mountPoint}"
		su -M -c bindfs -u root -g 1015 -p 0775 ${mountDevice} ${mountPoint}
		log "i" "[Mounted]" "${mountDevice} ——→ ${mountPoint}"
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
			log "i" "[checking]" "${mountDirect}"
			if mount |grep -q ${mountDirect}; then
				log "i" "[Unmounting]" "${mountDirect}"
				su -M -c umount ${mountDirect}
				log "i" "[Unmounted]" "${mountDirect}"
			fi
			log "i" "[checked]" "${mountDirect}"
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
		log "i" "[checking]" "${mountSource}"
		if [[ ! -d ${mountSource} ]] && mount |grep -q ${mountPoint}; then
			log "i" "[making]" "${mountSource}"
	    mkdir -p ${mountSource}
	    log "i" "[made]" "${mountSource}"
    fi
    if [[ -d ${mountSource} ]]; then
    	chown root:everybody ${mountSource}
    	chmod 0775 ${mountSource}
    fi
    log "i" "[checked]" "${mountSource}"
		log "i" "[checking]" "${realDirect}"
		if [[ ! -d ${realDirect} ]]; then
			log "i" "[making]" "${realDirect}"
	    mkdir -p ${realDirect}
	    log "i" "[made]" "${realDirect}"
	    chown media_rw:media_rw ${realDirect}
    fi
    log "i" "[checked]" "${realDirect}"
		for runtime in ${runtimeSheet[@]}
		do
			mountDirect=${runtime}/emulated/${directForMedia}
			log "i" "[checking]" "${mountDirect}"
			if ! mount |grep -q ${mountDirect} && mount |grep -q ${mountPoint}; then
				log "i" "[Mounting]" "${mountSource} ——→ ${mountDirect}"
				su -M -c bindfs -u root -g 9997 -p 0775 ${mountSource} ${mountDirect}
				log "i" "[Mounted]" "${mountSource} ——→ ${mountDirect}"
			fi
			log "i" "[checked]" "${mountDirect}"
		done
		let "index+=2"
	done
}
sdUnbinder
mkRoot
mountRoot
sdBinder
log "i" "[Done]" ""