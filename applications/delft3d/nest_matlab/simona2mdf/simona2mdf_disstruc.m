function disstruc = simona2mdf_disstruc(S,src,mdf)

% simona2mdf_disstruc : gets time-series for discharge points out of the siminp file

disstruc = [];

nesthd_dir = getenv_np('nesthd_path');

%
% get information out of struc
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'DISCHARGES'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.DISCHARGES.SOURCE')
    sources   = siminp_struc.ParsedTree.FLOW.FORCINGS.DISCHARGES.SOURCE;
end

for isrc = 1: length(src)
    for iisrc = 1: length(sources)
        if src(isrc).pntnr == sources(iisrc).P
            no_src = iisrc;
            break
        end
    end
    disstruc.data(isrc).Name          = ['discharge : ' num2str(isrc)];
    disstruc.data(isrc).Contents      = 'regular';
    disstruc.data(isrc).Location      = src(isrc).name;
    disstruc.data(isrc).TimeFunction  = 'non-equidistant';
    disstruc.data(isrc).ReferenceTime = [mdf.itdate(1:4) mdf.itdate(6:7) mdf.itdate(9:10)];
    disstruc.data(isrc).Interpolation = 'linear';
    [times,values]                    = simona2mdf_getseries(sources(no_src));
    disstruc.data(isrc).datenum       = datenum(mdf.itdate,'yyyy-mm-dd') + times/1440.;
    disstruc.data(isrc).Q             = values;
end
