function mdf = simona2mdf_crs(S,mdf,name_mdf, varargin);

% simona2mdf_crs : gets cross sections out of the parsed siminp tree

curves    = [];
chkpoints = [];
points    = [];

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.CURVES')
   curves       = siminp_struc.ParsedTree.MESH.CURVES;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'CHECKPOINTS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.CHECKPOINTS');
    chkpoints    = siminp_struc.ParsedTree.FLOW.CHECKPOINTS;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'POINTS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.POINTS')
    points       = siminp_struc.ParsedTree.MESH.POINTS;
end

if isempty(curves) || isempty(chkpoints) || isempty(points)
    return
end

%
% Get curve numbers
%

index = [];
stat{1} = 'USECTIONS';
stat{2} = 'VSECTIONS';

for ivar = 1: length(stat)
    if simona2mdf_fieldandvalue(chkpoints.(stat{ivar}),'')
        for istat = 1: length(chkpoints.(stat{ivar}).C)
            pntnr = simona2mdf_getpntnr(curves.C,chkpoints.(stat{ivar}).C(istat));
            if ~isempty(pntnr)
                index(end + 1) = simona2mdf_getpntnr(curves.C,chkpoints.(stat{ivar}).C(istat));
            else
                simona2mdf_message({['Output requested for C' num2str(chkpoints.(stat{ivar}).C(istat),'%4.4i')]; ...
                                    ' However, not defined as CURVE. SKIPPED!'},'Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
            end
        end
    end
end

%
% Find support points of the curves
%

index = unique(index);

if ~isempty(index)
    for icrs = 1: length(index)
        crs = curves.C(index(icrs)).LINE;
        for iside = 1: 2
            pntnr = simona2mdf_getpntnr(points.P,crs.P(iside));
            if ~isempty(pntnr)
                cross.m(icrs,iside)   =  points.P(pntnr).M;
                cross.n(icrs,iside)   =  points.P(pntnr).N;
                if ~isempty(crs.NAME)
                    cross.DATA(icrs).name = crs.NAME;
                else
                    cross.DATA(icrs).name = ' ';
                end
            else
                simona2mdf_message({['Output requested for P' num2str(chkpoints.(stat{ivar}).P(istat),'%4.4i')]; ...
                                    ' However, not defined as POINT. NaN written to crs file!'},'Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
                cross.m(icrs,iside)   =  NaN;
                cross.n(icrs,iside)   =  NaN;
                cross.DATA(icrs).name = crs.NAME;
            end
        end
    end

    %
    % Write
    %

    mdf.filcrs = [name_mdf '.crs'];
    delft3d_io_crs('write',mdf.filcrs,cross);
    mdf.filcrs = simona2mdf_rmpath(mdf.filcrs);
end
