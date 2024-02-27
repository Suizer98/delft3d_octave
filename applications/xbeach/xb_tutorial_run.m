%% 2. Running your model
%
% This tutorial shows how you can run an XBeach model using the XBeach
% Toolbox, once you have a full model setup. Running a model can be done
% locally or remotely using either a specific XBeach executable or the
% latest executable from TeamCity (see <http://build.deltares.nl>)

%% Running your model locally
%
% To run an XBeach model setup, you can supply the XBeach structure
% containing the model to the _xb_run_ function. This function writes the
% model to disk, downloads the latest XBeach executable for your operating
% system and needs from TeamCity and forks a process that runs the model.
% The function returns another XBeach structure containing information on
% the model run like process id and location.

% setup dummy model
xbm = xb_generate_model;

% run dummy model
xbr = xb_run(xbm);

%%
% In the way described above, the model is ran in the current directory
% with the latest executable from TeamCity on a single node with DAT output
% only. These options can be changed as follows:

% running the model in a different location
xbr = xb_run(xbm, 'path', 'path_to_model/');

% running the model with a different executable
xbr = xb_run(xbm, 'binary', 'xbeach.exe');

% running the model on multiple cores (not yet implemented)
xbr = xb_run(xbm, 'nodes', 4);

% running the model with netcdf output
xbr = xb_run(xbm, 'netcdf', true);

%%
% The _xbr_ variable containing information on the model run can be used to
% read the model output once the model has finished running. The variable
% can also be used to monitor whether the model has finished already or
% not.

% check if model is still running
if xb_check_run(xbr)
    finished = false;
else
    finished = true;
end

% display a message once the model is finished
xb_check_run(xbr, 'repeat', true);

%% Running your model remotely
%
% Large XBeach models may be too time consuming to run locally on your own
% desktop. Cluster computing is a solution to this problem. Via SSH XBeach
% model runs can be started on a remote cluster on multiple nodes. To
% accomodate this procedure, the _xb_run_remote_ function is developed. It
% works similar to the _xb_run_ function except it needs a username and
% password to log on to the cluster.

% run a dummy model remotely
xbr = xb_run_remote(xbm, 'ssh_user', 'user', 'ssh_pass', 'pass');

% you can also ask the function to prompt for a username and password
xbr = xb_run_remote(xbm, 'ssh_prompt', true);

%%
% The same options as for the _xb_run_ function are available for the
% _xb_run_remote_ function, except for the _path_ option, which is called
% _path_local_ to distinguish from the option _path_remote_. The former
% contains the path to the model on disk seen from the local computer,
% while the latter contains the same path seen from the cluster computer.
% By default, the models are ran on the cluster computer called _h4_ via
% the home directory of the current user:

% default settings for xb_run_remote
xbr = xb_run_remote(xbm, 'ssh_host', 'h4', 'path_local', 'u:\', 'path_remote', '~/');

%%
% The status of the remote run can be monitored in the same way as a local
% run:

xb_check_run(xbr, 'repeat', true);
