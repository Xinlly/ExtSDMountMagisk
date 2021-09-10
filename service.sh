#!/system/bin/sh

MODDIR=${0%/*}
runtimeR=/mnt/runtime/read
runtimeW=/mnt/runtime/write
runtimeD=/mnt/runtime/default
runtimeSheet=(${runtimeR} ${runtimeW} ${runtimeD})
DATA_MEDIA=/data/media
profile=0
mountDevice=/dev/block/mmcblk1p1
mountRootName=ExtSD
mountRoot=/data/adb/${mountRootName}
mountPoint=${mountRoot}/${profile}

log(){
	echo "[${1}] $(date "+%Y/%m/%d %H:%M:%S") ${2}\t\t${3}" >>${mountRoot}/ExtSDMount.log 2>&1
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

mkRoot
mountRoot

log "i" "[Done]" ""