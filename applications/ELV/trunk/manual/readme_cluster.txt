This file explains the procedure to run the cluster

*) prepare files
modify main_run_several
	create as many main_run_several files as partitions of runs you want
	in each file change the runid_serie and the which_runs

*) login in cluster
Start PuTTy
Specify settings:
	(settings are saved in session 'TUD')
	Host Name = hpc08.tudelft.net
	Port = 22
	Connection type = SSH
Open
login as: NetID

*) copy to k:\
copy the full folder of ELV to k:\ (use for instance the term 'tag' to define the branch)
	<d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V> to k:\ <k:\wat\vlm\sorted\V\tag> 
	In total commander use '| .svn\ test\' to  avoid copying the big test folder and svn files
copy the full folder of ELV to the cluster
	cp -rf /tudelft/vc/staff-group/citg/wat/vlm/sorted/V/tag tag	

*) run simulations
navigate to the source folder
	cd tag/source
load matlab
	module load matlab/2016b
run file
	matlab -r main_run_several

*) check status
qstat to check the status
queue_info (located in the <manual> folder of ELV) to have advanced information on the cluster use

*) copy resuts
	cp -rf tag /tudelft/vc/staff-group/citg/wat/vlm/sorted/V/tag_r

USEFULL COMMANDS

create a directory 
	mkdir
list files in a directory
	ls
check status of the cluster
	qstat
move to directory
	cd
stop all runs
	qselect -u victorchavarri | xargs qdel
erase all files in folder
	rm -rf /tudelft/vc/staff-group/citg/wat/vlm/sorted/V/
	rm -rf branch_V
change permission to file
	chmod -R 777 <filename>
read a log file	
	cat tag/runs/H_v1_2/001/log.txt
	cat tag/runs/H_v2/015/log.txt
	
paste
	Shift+Insert
	
	cat Matlab/ELV/ELV_170405/runs/Bimodal6/100/log.txt
	cat Matlab/ELV/ELV_170405/runs/Bimodal5/33/log.txt