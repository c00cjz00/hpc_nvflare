#!/bin/bash
# 範例 bash hpc_key.sh , 完成後,即可以直接免用密碼上傳資料 scp demo.txt ${account}@${sftpServer}:~/demo.txt

########### CONFIG #############
# 先設定api key, 請先將 authorized_keys 放置一網路空間 (例如github), 並修改下方authorized_keys位置, 系統會用 curl 下載至你開立的容器內, 以達到免用密碼上傳資料
api_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
project_name=GOV108019
authorized_keys=https://raw.githubusercontent.com/c00cjz00/hpc_nvflare/main/cjz_id_rsa.pub.txt
########### CONFIG #############

# 1. 取得 project_name 之 project_id 11833
result=$(curl -s -X GET "https://apigateway.twcc.ai/api/v2/k8s-taichung-default/projects/" \
-H "accept: application/json" \
-H "X-API-HOST: k8s-taichung-default" \
-H "x-api-key: ${api_key}")
project_id=$(echo $result[0] | jq  -c  ".[]" | grep ${project_name} |jq -r '.id')
echo project_id: $project_id

# 2. 取得 account  c00cjz00
result=$(curl -s -X GET "https://apigateway.twcc.ai:443/api/v2/users/?project=${project_id}" \
-H "accept: application/json" \
-H "X-API-HOST: goc" \
-H "x-api-key: ${api_key}")
account=$(echo $result[0] | jq  -c  ".[]" | grep username |jq -r '.username')
echo account: $account

## 3. 進行指令確認遠端機器是否有 /home/${account}/.ssh/authorized_keys 存在
#sftpServer=xdata1.twcc.ai
sftpServer=t3-x1.nchc.org.tw

touch demo.txt && string=$(scp demo.txt ${account}@${sftpServer}:~/demo.txt 2>&1)

if [[ $string == *"Permission denied"* ]]; then
	# 4. 取得計算資源 ngc 群組, 代號 ngc_pid 2
	result=$(curl -s -X GET "https://apigateway.twcc.ai/api/projects/" \
	-H "accept: application/json" \
	-H "X-API-HOST: harbor" \
	-H "x-api-key: ${api_key}")
	ngc_pid=$(echo $result | jq  -c  ".[]" | grep ngc |jq -r '.project_id')
    echo ngc_pid $ngc_pid
	
	# 5. 取得計算資源 ngc/nvidia/ubuntu-v1 或  ngc/nvidia/tensorrt-18.10-py2-v1 代號, 這邊使用 ngc/nvidia/tensorrt-18.10-py2-v1 -> 6
	container_name=ngc/nvidia/tensorrt-18.10-py2-v1
	result=$(curl -s -X GET "https://apigateway.twcc.ai:443/api/repositories?project_id=${ngc_pid}" \
	-H "accept: application/json" \
	-H "X-API-HOST: harbor" \
	-H "x-api-key: ${api_key}")
	container_pid=$(echo $result | jq  -c  ".[]" | grep ${container_name} |jq -r '.id')
	echo container_pid: $container_pid

	# 6. 取得可以用資源	 1 GPU + 04 cores + 090GB memory id =135
	resource_name="1 GPU + 04 cores + 090GB memory"
	result=$(curl -s -X GET "https://apigateway.twcc.ai:443/api/v2/k8s-taichung-default/flavors/" \
	-H "accept: application/json" \
	-H "X-API-HOST: k8s-taichung-default" \
	-H "x-api-key: ${api_key}")
	resource_pid=$(echo $result | jq  -c  ".[]" | grep "${resource_name}" |jq -r '.id')
	echo resource_pid: $resource_pid

	# 7. 建立 HPC CCS
	string="{\"name\":\"demobycjz\",\"project\":${project_id},\"type\":\"KUBERNETES:DOCKER\",\"steps\":[{\"stepname\":\"demobycjz\",\"dependency_policy\":\"AFTEROK\",\"command\":\"curl -k ${authorized_keys} -o /home/${account}/.ssh/authorized_keys\",\"image\":\"${container_name}\",\"flavor\":${resource_pid},\"runs\":\"1\",\"volumes\":[{\"type\":\"HOSTPATH\",\"path\":\"/fs01\",\"mountPath\":\"/work/${account}\"},{\"type\":\"HOSTPATH\",\"path\":\"/fs02\",\"mountPath\":\"/home/${account}\"}]}]}"
	result=$(curl -s -X POST "https://apigateway.twcc.ai:443/api/v2/k8s-taichung-default/jobs/" \
	-H "accept: application/json" \
	-H "X-API-HOST: k8s-taichung-default" \
	-H "x-api-key: ${api_key}" \
	-H "Content-Type: application/json" \
	-d "${string}")
	running_pid=$(echo $result | jq -r '.id')
	echo running_pid $running_pid
	sleep 5
	
	# 8. 啟動 HPC CCS
	curl -s -X POST "https://apigateway.twcc.ai:443/api/v2/k8s-taichung-default/jobs/${running_pid}/submit/" \
	-H "accept: application/json" \
	-H "X-API-HOST: k8s-taichung-default" \
	-H "x-api-key: ${api_key}"
	sleep 5

	# 9. 刪除 HPC CCS
	curl -s -X DELETE "https://apigateway.twcc.ai:443/api/v2/k8s-taichung-default/jobs/${running_pid}/" \
	-H "accept: application/json" \
	-H "X-API-HOST: k8s-taichung-default" \
	-H "x-api-key: ${api_key}"
else
	echo "完成 /home/${account}/.ssh/authorized_keys 上傳作業"
fi
