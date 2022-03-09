#!/bin/bash
## 1.先載入安裝環境 source condaInit.sh use_env nvflare 3.8
## 2. bash server.sh /home/c00cjz00/abc
## 3. stop -> ps aux | grep flare | awk '{print $2}' | xargs kill -9
### 啟動 server
### 請先編輯(answer="YES")  /work/c00cjz00/myenv/.package_nvflare_nchc_conda/envs/nvflare/lib/python3.8/site-packages/nvflare/lighter/poc.py
if [ -z "$1" ]
then
	echo "use saveDir in argv[1]"	
else
	server=$(hostname -s)
	dataDir=$1
	mkdir -p ${dataDir}
	#ps aux | grep flare | awk '{print $2}' | xargs kill -9
	cd ${dataDir}
	rm -rf ${dataDir}/nvflare_server 
	mkdir -p ${dataDir}/nvflare_server/workspaces
	cd ${dataDir}/nvflare_server/workspaces
	poc -n 4
	workspace="poc_workspace"
	mv "poc" ${workspace}
	sed -i "s|8002|37002|g" ${dataDir}/nvflare_server/workspaces/${workspace}/server/startup/fed_server.json
	sed -i "s|8003|37003|g" ${dataDir}/nvflare_server/workspaces/${workspace}/server/startup/fed_server.json
	sed -i "s|localhost|${server}|g" ${dataDir}/nvflare_server/workspaces/${workspace}/server/startup/fed_server.json
	export CUDA_VISIBLE_DEVICES=0
	mkdir -p ${dataDir}/nvflare_server/workspaces/${workspace}/server/transfer
	sleep 1
	${dataDir}/nvflare_server/workspaces/${workspace}/server/startup/sub_start.sh ${server} &
	pid=$!
	echo "PID: ${pid}"
	sleep 1
fi