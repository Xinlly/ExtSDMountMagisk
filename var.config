WorkDir=${0%/*}
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
logFile=${mountRoot}/ExtSDMount.log

log(){
	logStr="${1} $(date "+%Y/%m/%d %H:%M:%S") ${2}\t${3}"
	[ -d ${mountRoot} ] && echo ${logStr} >> ${logFile} 2>&1 || echo  "[w] Can not find the logFlie: ${logFile}!" 2>&1
}