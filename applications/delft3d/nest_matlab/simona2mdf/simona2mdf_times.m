function mdf = simona2mdf_times (S,mdf,name_mdf, varargin);

% simona2mdf_times : gets thimes out of the parsed siminp tree

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM'});

times = siminp_struc.ParsedTree.FLOW.PROBLEM.TIMEFRAME;

itdate     = datenum(times.DATE);
mdf.itdate = datestr(itdate,'yyyy-mm-dd');
mdf.tstart = times.TSTART;
mdf.tstop  = times.TSTOP;

mdf.dt     = siminp_struc.ParsedTree.FLOW.PROBLEM.METHODVARIABLES.TSTEP;

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.PROBLEM.SMOOTHING.TLSMOOTH')
   mdf.tlfsmo = siminp_struc.ParsedTree.FLOW.PROBLEM.SMOOTHING.TLSMOOTH;
end
