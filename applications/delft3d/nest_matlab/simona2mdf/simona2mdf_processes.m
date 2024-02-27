function mdf = simona2mdf_processes (S,mdf,name_mdf, varargin)

% simona2mdf_processes : gets proces information out of the parsed siminp tree

warning = false;
warntext{1} = 'SIMINP2MDF Processes Warning:';
warntext{2} = '';

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% Check for salinity
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT' 'PROBLEM'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM')
    if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM.SALINITY')
        mdf.sub1(1:1) = 'S';
    else
        warning = true;
        warntext{end+1} = 'Conversion of TRANSPORT (other than Salinity) not implemented yet';
    end
end

%
% Check for temperature
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'HEATMODEL'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.HEATMODEL')
   warning = true;
   warntext{end+1} = 'Conversion of Temperature not implemented yet';
end

%
% Check for wind
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'GENERAL' 'SPACE_VAR_WIND'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.GENERAL.SPACE_VAR_WIND')
   warning = true;
   warntext{end+1} = 'Conversion of WIND (space varying) not implemented yet';
else
    siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'GENERAL' 'WIND'});
    if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.GENERAL.WIND')
       mdf.sub1(3) = 'w';
    end
end


%
% Writes the warning
%
warntext{end+1} = '';

if warning
   simona2mdf_message(warntext,'Window','SIMONA2MDF Warning','Close',true,'n_sec',10,'nesthd_path', OPT.nesthd_path);
end
