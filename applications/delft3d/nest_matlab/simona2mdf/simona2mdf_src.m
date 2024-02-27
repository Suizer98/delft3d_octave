function src=simona2mdf_src(S, varargin)

% simona2mdf_src : gets efinition of discahrge points out of siminp file

src = [];

%
% Parse Boundary data
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% get information out of struc
%

points  = [];
sources = [];

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'POINTS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.POINTS')
    points    = siminp_struc.ParsedTree.MESH.POINTS;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'DISCHARGE'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.DISCHARGES.SOURCE')
    sources   = siminp_struc.ParsedTree.FLOW.FORCINGS.DISCHARGES.SOURCE;
end

for isrc = 1: length(sources)
    for ipnt = 1: length(points.P)
        if points.P(ipnt).SEQNR == sources(isrc).P
            no_pnt = ipnt;
            break
        end
    end
    src(isrc).interpolation = 'Y';
    src(isrc).name          = points.P(no_pnt).NAME;
    src(isrc).m             = points.P(no_pnt).M;
    src(isrc).n             = points.P(no_pnt).N;
    if simona2mdf_fieldandvalue(sources(isrc),'LAYER')
        src(isrc).k = sources(isrc).LAYER;
    else
        src(isrc).k = 1;
    end
    src(isrc).type         = 'N';
    src(isrc).pntnr        = points.P(no_pnt).SEQNR;
end

