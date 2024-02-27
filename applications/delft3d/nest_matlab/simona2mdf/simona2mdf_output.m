function mdf = simona2mdf_output(S,mdf, varargin)

% simona2mdf_output : gets output tmes from the siminp tree

OPT.nesthd_path = getenv_np('nesthd_path');
OPT             = setproperty(OPT,varargin{1:end});


% Maps
siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'SDSOUTPUT' 'MAPS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.SDSOUTPUT.MAPS')
    output       = siminp_struc.ParsedTree.SDSOUTPUT.MAPS;
else
    return
end

if ~isempty(output)
    mdf.flmap(1) = output.TFMAPS;
    mdf.flmap(2) = output.TIMAPS;
    mdf.flmap(3) = output.TLMAPS;
end
% Histories
siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'SDSOUTPUT' 'HIST'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.SDSOUTPUT.HISTORIES')
    output       = siminp_struc.ParsedTree.SDSOUTPUT.HISTORIES;
else
    return
end

if ~isempty(output)
    mdf.flhis(1) = mdf.tstart;
    mdf.flhis(2) = output.TIHISTORIES;
    mdf.flhis(3) = mdf.tstop;
end
% Restart
siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'SDSOUTPUT' 'RESTART'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.SDSOUTPUT.RESTART')
    output       = siminp_struc.ParsedTree.SDSOUTPUT.RESTART;
else
    return
end
if ~isempty(output)
    mdf.flrst = output.TIRESTART;
end

