#!/bin/bash
## 1. 先載入安裝環境 source condaInit.sh use_env nvflare 3.8
## 2. bash site-1.sh lgn304 site-1 /home/c00cjz00/abc 
## 3. stop = ps aux | grep site-1 | awk '{print $2}' | xargs kill -9
### 啟動 site
### 請先編輯(answer="YES")  /work/c00cjz00/myenv/.package_nvflare_nchc_conda/envs/nvflare/lib/python3.8/site-packages/nvflare/lighter/poc.py
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
	echo "use saveDir in argv[1]"	
else
	server=$1
	siteName=$2	
	dataDir=$3
	mkdir -p ${dataDir}
	#echo "ps aux | grep ${siteName} | awk '{print $2}' | xargs kill -9"
	cd ${dataDir}

	rm -rf ${dataDir}/nvflare_${siteName}
	mkdir -p ${dataDir}/nvflare_${siteName}/workspaces
	cd ${dataDir}/nvflare_${siteName}/workspaces
	poc -n 4
	workspace="poc_workspace"
	mv "poc" ${workspace}
	sed -i "s|8002|37002|g" ${dataDir}/nvflare_${siteName}/workspaces/${workspace}/${siteName}/startup/fed_client.json
	sed -i "s|localhost|${server}|g" ${dataDir}/nvflare_${siteName}/workspaces/${workspace}/${siteName}/startup/fed_client.json
	mkdir -p ${dataDir}/nvflare_${siteName}/workspaces/${workspace}/${siteName}/transfer
	sleep 1
	${dataDir}/nvflare_${siteName}/workspaces/${workspace}/${siteName}/startup/sub_start.sh ${siteName} $server &
	pid=$!
	sleep 1
fi
