function mdf = simona2mdf_obs(S,mdf,name_mdf, varargin);

% simona2mdf_obs : gets observation stations out of the parsed siminp tree

points    = [];
chkpoints = [];

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'POINTS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.POINTS')
    points       = siminp_struc.ParsedTree.MESH.POINTS;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'CHECKPOINTS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.CHECKPOINTS')
    chkpoints    = siminp_struc.ParsedTree.FLOW.CHECKPOINTS;
end

if isempty(points) || isempty(chkpoints)
    return
end

%
% Get station numbers
%

index = [];
stat{1} = 'LEVELSTATIONS';
stat{2} = 'CURRENTSTATIONS';

for ivar = 1: length(stat)
    if simona2mdf_fieldandvalue(chkpoints.(stat{ivar}),'')
        for istat = 1: length(chkpoints.(stat{ivar}).P)
            pntnr = simona2mdf_getpntnr(points.P,chkpoints.(stat{ivar}).P(istat));
            if ~isempty(pntnr)
               index(end + 1) = pntnr;
            else
                simona2mdf_message({['Output requested for P' num2str(chkpoints.(stat{ivar}).P(istat),'%4.4i')]; ...
                                    ' however, not defined as point. SKIPPED!'},'Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
            end
        end
    end
end

%
% Fill station struct
%

index = unique(index);

for istat = 1: length(index)
    sta.m(istat)     = points.P(index(istat)).M;
    sta.n(istat)     = points.P(index(istat)).N;
    if ~isempty (points.P(index(istat)).NAME)
        sta.namst{istat} = points.P(index(istat)).NAME;
    else
        sta.namst{istat} = ' ';
    end
end

%
% Write
%

mdf.filsta = [name_mdf '.obs'];
delft3d_io_obs('write',mdf.filsta,sta);
mdf.filsta = simona2mdf_rmpath(mdf.filsta);
