#!/bin/bash
## example source condaInit.sh install_env nvflare 3.8
## example source condaInit.sh use_env nvflare 3.8
if [ "$1" = "install_env" ]
then
	## 安裝 nvflare
	echo "install conda env"
	myENV="$2" #nvflare
	python_version="$3" #3.8
	myPackageHome=/work/$(whoami)/myenv
	conda deactivate && conda deactivate && conda deactivate && conda deactivate && conda deactivate
	module purge
	if [[ $(module avail miniconda3 | grep miniconda3) ]]; then
	 module load miniconda3
	else
	 module load pkg/Anaconda3
	fi
	rm -rf ${myPackageHome}/.package_${myENV}_nchc_conda
	rm -rf ${myPackageHome}/.package_${myENV}_nchc_pip
	export CONDA_PKGS_DIRS=${myPackageHome}/.package_${myENV}_nchc_conda/pkgs
	export CONDA_ENVS_DIRS=${myPackageHome}/.package_${myENV}_nchc_conda/envs
	export PYTHONUSERBASE=${myPackageHome}/.package_${myENV}_nchc_conda/envs/${myENV}
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/bin:$PATH
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/envs/{myENV}/bin:$PATH
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/envs/{myENV}/lib/python${python_version}/site-packages:$PATH
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/envs/{myENV}/lib/python${python_version}/site-packages/bin:$PATH
	conda create -n ${myENV} -y -c conda-forge mamba python=${python_version} ipykernel
	conda activate ${myPackageHome}/.package_${myENV}_nchc_conda/envs/${myENV}
	echo "use ipykerner:"
	echo "python -m ipykernel install --user --name ${myENV}  --display-name '${myENV}'"
	echo "install R"
	echo "conda install -y -c conda-forge r-essentials r-base r-irkernel"
	echo "use Rkerner:"
	echo "Rscript -e \"IRkernel::installspec(name = '${myENV}', displayname = '${myENV}')\"";

elif [ "$1" = "use_env" ]
then
	## 使用 nvflare
	myENV="$2" #nvflare
	python_version="$3" #3.8
	myPackageHome=/work/$(whoami)/myenv
	#conda deactivate && conda deactivate && conda deactivate && conda deactivate && conda deactivate
	module purge
	if [[ $(module avail miniconda3 | grep miniconda3) ]]; then
	 module load miniconda3
	else
	 module load pkg/Anaconda3
	fi
	export CONDA_PKGS_DIRS=${myPackageHome}/.package_${myENV}_nchc_conda/pkgs
	export CONDA_ENVS_DIRS=${myPackageHome}/.package_${myENV}_nchc_conda/envs
	export PYTHONUSERBASE=${myPackageHome}/.package_${myENV}_nchc_conda/envs/${myENV}
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/bin:$PATH
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/envs/{myENV}/bin:$PATH
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/envs/{myENV}/lib/python${python_version}/site-packages:$PATH
	export PATH=${myPackageHome}/.package_${myENV}_nchc_conda/envs/{myENV}/lib/python${python_version}/site-packages/bin:$PATH
	conda activate ${myPackageHome}/.package_${myENV}_nchc_conda/envs/${myENV}
	echo "use ipykerner:"
	echo "python -m ipykernel install --user --name ${myENV}  --display-name '${myENV}'"
	echo "install R"
	echo "conda install -y -c conda-forge r-essentials r-base r-irkernel"
	echo "use Rkerner:"
	echo "Rscript -e \"IRkernel::installspec(name = '${myENV}', displayname = '${myENV}')\"";    
else
    echo "use use_env or install_env"
fi
