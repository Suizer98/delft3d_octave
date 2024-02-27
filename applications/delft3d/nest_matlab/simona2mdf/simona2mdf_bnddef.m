function bnd=simona2bnd_bnddef(S, varargin)

% simona2mdf_bnddef : gets boundary definition out of the siminp file

bnd = [];

%
% Parse Boundary data
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% get information out of struc
%

points   = [];
opendef  = [];
bnddef   = [];
harmonic = [];
vel_prof = [];

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'POINTS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.POINTS')
    points   = siminp_struc.ParsedTree.MESH.POINTS;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BOUNDARIES' 'OPENINGS'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BOUNDARIES.OPENINGS')
    opendef  = siminp_struc.ParsedTree.MESH.BOUNDARIES.OPENINGS;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'BOUNDARIES'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.BOUNDARIES')
    bnddef   = siminp_struc.ParsedTree.FLOW.FORCINGS.BOUNDARIES;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'HARMONIC'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.HARMONIC')
    harmonic = siminp_struc.ParsedTree.FLOW.FORCINGS.HARMONIC;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.PROBLEM.VELOCITY_PROFILE')
   vel_prof     = siminp_struc.ParsedTree.FLOW.PROBLEM.VELOCITY_PROFILE;
end

if isempty(points) || isempty(opendef) || isempty(bnddef)
    return
end

%
% cycle over all open boundaries
%

first     = true;
for iopen = 1: length(bnddef.B)

    %
    % Get the opening number of the boundary
    %

    OpenNr  = bnddef.B(iopen).OPEN;

    %
    % Find the correct opening
    %
    
    iline = [];
    for iline = 1: length(opendef.OPEN)
        if opendef.OPEN(iline).SEQNR == OpenNr
            iopennr = iline;
        end
    end

    bnd.DATA(iopen).name = opendef.OPEN(iopennr).LINE.NAME;
    ipoint(1)= opendef.OPEN(iopennr).LINE.P(1);
    ipoint(2)= opendef.OPEN(iopennr).LINE.P(2);

    %
    % find mn cordinates of boundary support points
    %

    for iside = 1: 2
        pntnr = simona2mdf_getpntnr(points.P,ipoint(iside));
        bnd.m(iopen,iside)     = points.P(pntnr).M;
        bnd.n(iopen,iside)     = points.P(pntnr).N;
        bnd.pntnr(iopen,iside) = ipoint(iside);
        if iside == 2 && bnddef.B(iopen).SAME
           bnd.pntnr(iopen,iside) = ipoint(1);
        end
    end

    bnd.DATA(iopen).mn(1) = bnd.m(iopen,1);
    bnd.DATA(iopen).mn(2) = bnd.n(iopen,1);
    bnd.DATA(iopen).mn(3) = bnd.m(iopen,2);
    bnd.DATA(iopen).mn(4) = bnd.n(iopen,2);

    %
    % Determine type of boundary
    %

    if strcmpi (deblank(bnddef.B(iopen).BTYPE),'wl')
        bnd.DATA(iopen).bndtype = 'Z';
        bnd.DATA(iopen).vert_profile = 'logarithmic';
    elseif strcmpi (deblank(bnddef.B(iopen).BTYPE),'vel')
        bnd.DATA(iopen).bndtype = 'C';
        if first
            prf = 'Uniform';
            first = false;
            %
            % Determine type of profile
            %
            if ~isempty(vel_prof)
                if vel_prof.BOUXDIM
                    prf = '3d-profile';
                end
                if vel_prof.LOG_BOUNDARI
                    prf = 'Logarithmic';
                end
            end
        end
        bnd.DATA(iopen).vert_profile = prf;
    elseif strcmpi (deblank(bnddef.B(iopen).BTYPE),'Riemann')
        bnd.DATA(iopen).bndtype = 'R';
    elseif strcmpi (deblank(bnddef.B(iopen).BTYPE),'Disch')
        bnd.DATA(iopen).bndtype = 'Q';
        bnd.DATA(iopen).vert_profile = 'logarithmic';
    elseif strcmpi (deblank(bnddef.B(iopen).BTYPE),'Disch-ad')
        bnd.DATA(iopen).bndtype = 'T';
        bnd.DATA(iopen).vert_profile = 'logarithmic';
    elseif strcmpi (deblank(bnddef.B(iopen).BTYPE),'QH')
        bnd.DATA(iopen).bndtype = 'X';
    end
    bnd.DATA(iopen).alfa = bnddef.B(iopen).REFL;

    %
    % Fill type of forcing
    %

    if strcmpi(deblank(bnddef.B(iopen).BDEF),'series')
        bnd.DATA(iopen).datatype = 'T';
    else
        %
        % Fourier (bch) or Harmonic (bca)
        % start by assuming harmonic
        %
        tide         = false;
        if ~isempty(harmonic)
            hpoints = harmonic.CONSTANTS.S;
            for ipnt = 1: length(hpoints)
                %
                % Harmonc forcing for side 1
                %
                if hpoints(ipnt).P == bnd.pntnr(iopen,1)
                    tide = true;
                    break
                end
            end
        end

        if tide
            bnd.DATA(iopen).datatype = 'A';
            bnd.DATA(iopen).labelA   = ['P' num2str(bnd.pntnr(iopen,1),'%4.4i')];
            bnd.DATA(iopen).labelB   = ['P' num2str(bnd.pntnr(iopen,2),'%4.4i')];
        else
            bnd.DATA(iopen).datatype = 'H';
        end
    end
    if strcmpi(bnd.DATA(iopen).bndtype,'X')
        bnd.DATA(iopen).bndtype  = 'Z';
        bnd.DATA(iopen).datatype = 'Q';
    end
end

