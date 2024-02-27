function mdf = simona2mdf_dis(S,mdf,name_mdf, varargin);

% simona2mdf_dis : gets all discharge point related information out of the parsed siminp (S)

% Start with the definition of discharge points

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

src = simona2mdf_src(S, 'nesthd_path', OPT.nesthd_path);

% If discharge points exist, write definition and retrieve time series

if ~isempty(src)
    mdf.filsrc = [name_mdf '.src'];
    delft3d_io_src('write',mdf.filsrc,src);
    mdf.filsrc = simona2mdf_rmpath(mdf.filsrc);

    disstruc   = simona2mdf_disstruc(S,src,mdf);
    mdf.fildis = [name_mdf '.dis'];
    delft3d_io_dis('write',mdf.fildis,disstruc);
    mdf.fildis = simona2mdf_rmpath(mdf.fildis);
end

end
