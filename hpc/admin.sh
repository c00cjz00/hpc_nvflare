#!/bin/bash
## 1.先載入安裝環境 source condaInit.sh use_env nvflare 3.8
## 2. bash admin.sh lgn304 /home/c00cjz00/abc
## 3. stop -> ps aux | grep flare | awk '{print $2}' | xargs kill -9
### 啟動 server
### 請先編輯(answer="YES")  /work/c00cjz00/myenv/.package_nvflare_nchc_conda/envs/nvflare/lib/python3.8/site-packages/nvflare/lighter/poc.py
if [ -z "$1" ]
then
	echo "use saveDir in argv[1]"	
else
	server=$1
	dataDir=$2
	mkdir -p ${dataDir}
	#ps aux | grep flare | awk '{print $2}' | xargs kill -9
	cd ${dataDir}
	rm -rf ${dataDir}/nvflare_admin 
	mkdir -p ${dataDir}/nvflare_admin/workspaces
	cd ${dataDir}/nvflare_admin/workspaces
	poc -n 4
	workspace="poc_workspace"
	mv "poc" ${workspace}
	sed -i "s|8003|37003|g" ${dataDir}/nvflare_admin/workspaces/${workspace}/admin/startup/fl_admin.sh
	git clone https://github.com/NVIDIA/NVFlare.git

	mkdir -p ${dataDir}/nvflare_admin/workspaces/${workspace}/admin/transfer
	cp -rf NVFlare/examples/* ${dataDir}/nvflare_admin/workspaces/${workspace}/admin/transfer
	sleep 1
	${dataDir}/nvflare_admin/workspaces/${workspace}/admin/startup/fl_admin.sh ${server}
	# upload_app hello-pt
	# set_run_number 1
	# deploy_app hello-pt all
	# start_app all
	# shutdown client
	# shutdown server
fi




