function bmi_initialize(bmimodel, config_file)
[config_file_dir, config_file_name, config_file_ext] = fileparts(config_file);
cd(config_file_dir);
calllib(bmimodel, 'initialize', [config_file_name, config_file_ext]);
end
