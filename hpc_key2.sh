#!/bin/bash
# 範例 bash hpc_key.sh , 完成後,即可以直接免用密碼上傳資料 scp demo.txt ${account}@${sftpServer}:~/demo.txt

########### CONFIG #############
# 先設定api key, project_name 
api_key=xxxxxxxxxxxxxxxxxxxxxxxx
container_name=ngc/nvidia/tensorrt-18.10-py2-v1
command="date > data2.txt"
########### CONFIG #############

# 1. 取得 project_name 之 project_id 11836
result=$(curl -s -X GET "https://apigateway.twcc.ai/api/v2/slurm-taichung-default/projects/" \
-H "accept: application/json" \
-H "X-API-HOST: slurm-taichung-default" \
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

# 4. 取得計算資源 ngc 群組, 代號 ngc_pid 2
result=$(curl -s -X GET "https://apigateway.twcc.ai/api/projects/" \
-H "accept: application/json" \
-H "X-API-HOST: harbor" \
-H "x-api-key: ${api_key}")
ngc_pid=$(echo $result | jq  -c  ".[]" | grep ngc |jq -r '.project_id')
    echo ngc_pid $ngc_pid

# 5. 取得計算資源 ngc/nvidia/ubuntu-v1 或  ngc/nvidia/tensorrt-18.10-py2-v1 代號, 這邊使用 ngc/nvidia/tensorrt-18.10-py2-v1 -> 6
#container_name=ngc/nvidia/clara-train-sdk-v4.0
result=$(curl -s -X GET "https://apigateway.twcc.ai:443/api/repositories?project_id=${ngc_pid}" \
-H "accept: application/json" \
-H "X-API-HOST: harbor" \
-H "x-api-key: ${api_key}")
container_pid=$(echo $result | jq  -c  ".[]" | grep ${container_name} |jq -r '.id')
echo container_pid: $container_pid

# 6. 取得可以用資源 1 GPU + 04 cores + 090GB memory id =135
resource_name="1 GPU + 04 cores + 090GB memory"
result=$(curl -s -X GET "https://apigateway.twcc.ai:443/api/v2/slurm-taichung-default/flavors/" \
-H "accept: application/json" \
-H "X-API-HOST: slurm-taichung-default" \
-H "x-api-key: ${api_key}")
resource_pid=$(echo $result | jq  -c  ".[]" | grep "${resource_name}" |jq -r '.id')
echo resource_pid: $resource_pid

# 7. 建立 HPC CCS
string="{\"name\":\"demobycjz15\",\"project\":${project_id},\"type\":\"SLURM:SINGULARITY\",\"steps\":[{\"stepname\":\"hpcstep1\",\"command\":\"${command}\",\"image\":\"${container_name}\",\"flavor\":${resource_pid},\"runs\":\"1\",\"volumes\":[{\"type\":\"HOSTPATH\",\"path\":\"/fs01\",\"mountPath\":\"/work/${account}\"},{\"type\":\"HOSTPATH\",\"path\":\"/fs02\",\"mountPath\":\"/home/${account}\"}]}]}"
result=$(curl -s -X POST "https://apigateway.twcc.ai:443/api/v2/slurm-taichung-default/jobs/" \
-H "accept: application/json" \
-H "X-API-HOST: slurm-taichung-default" \
-H "x-api-key: ${api_key}" \
-H "Content-Type: application/json" \
-d "${string}")
running_pid=$(echo $result | jq -r '.id')
echo running_pid $running_pid
sleep 5

# 8. 啟動 HPC CCS
curl -s -X POST "https://apigateway.twcc.ai:443/api/v2/slurm-taichung-default/jobs/${running_pid}/submit/" \
-H "accept: application/json" \
-H "X-API-HOST: slurm-taichung-default" \
-H "x-api-key: ${api_key}"
sleep 5

# 9. 等待工作結束
cmd="curl -s -X GET \"https://apigateway.twcc.ai:443/api/v2/slurm-taichung-default/jobs/?project=11836\" \
-H \"accept: application/json\" \
-H \"X-API-HOST: slurm-taichung-default\" \
-H \"x-api-key: ${api_key}\" \
| jq  '.[0]'"
echo $cmd

cmd="curl -s -X GET \"https://apigateway.twcc.ai:443/api/v2/slurm-taichung-default/jobs/${running_pid}/runs/\" \
-H \"accept: application/json\" \
-H \"X-API-HOST: slurm-taichung-default\" \
-H \"x-api-key: ${api_key}\" \
| jq  '.results[0].status'"
echo $cmd


# 10. 刪除 HPC CCS
#curl -s -X DELETE "https://apigateway.twcc.ai:443/api/v2/slurm-taichung-default/jobs/${running_pid}/" \
#-H "accept: application/json" \
#-H "X-API-HOST: slurm-taichung-default" \
#-H "x-api-key: ${api_key}"

#  sacct --starttime 2022-03-12 --format=User,JobID,Jobname,partition,state,time,start,end,elapsed,MaxRss,MaxVMSize,nnodes,ncpus,nodelist
