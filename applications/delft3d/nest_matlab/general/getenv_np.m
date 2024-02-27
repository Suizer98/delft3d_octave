function nesthd_path = getenv_np(name_env)

% getenv_np: gets the nesthd_path, either from the environment variables
%            in case of an executable file or from the location of nesthd.m
%            in case of running from the matlab command prompt

if isdeployed
     nesthd_path = getenv(name_env);
else
     [nesthd_path,~,~] = fileparts(which ('nesthd'));
end
