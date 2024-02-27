%do_runs

% Do run
%run_ELV(fullfile(folder_run,'input.mat'));  

% Assume we start fro the correct result folder
try
	folder_run = pwd; cd ../../..
	folder_main = pwd;

	addpath(fullfile(folder_main, 'main'), fullfile(folder_main, 'auxiliary'));
	run_ELV(fullfile(folder_run,'input.mat'))
	exit;
catch
	exit;
end
