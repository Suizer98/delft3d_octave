function wrihyd_timeser(filename,bnd,nfs_inf,bndval,add_inf,varargin)

% wrihyd_timeser : writes hydrodynamic bc to a SIMONA time series file

%
% Set some general parameters
%
notims        = length(bndval);
kmax          = size(bndval(1).value,2)/2;
thick         = nfs_inf.thick;

OPT.ipnt      = NaN;
OPT           = setproperty(OPT,varargin);
bndNr         = OPT.ipnt;
type          = lower (bnd.DATA(bndNr).bndtype);

%% Switch orientation if overall model is dflowfm
if strcmpi(nfs_inf.from,'dfm') && ~strcmpi(type,'z')
    [bndval,thick] = nesthd_flipori(bndval,thick);
end

if isfield(add_inf,'profile')
    profile       = add_inf.profile;
else
    profile       = 'uniform';
end
%
% Open output file
%
if bndNr == 1; fid = fopen(filename,'w+'); else  fid = fopen(filename,'a'); end



nolay    = 1;
multilay = false;

if (strcmp(type,'c') || strcmp(type,'r')) && kmax > 1 && strcmp(profile,'3d-profile')
    
    
    %
    % Velocities or Riemann invariant per Layer
    %
    
    nolay = kmax;
    multilay = true;
end

%
% Set pointname
%
if isfield(bnd,'pntnr')
    pntname = ['P' num2str(bnd.pntnr(bndNr))];
else
    pntname  = ['P' num2str(bndNr,'%4.4i')];
end

for k = 1:nolay
    
    %
    % Write general information
    %
    
    Line = ['S : ',pntname,' TID=0.0 SERIES=''','regular',''''];
    
    if multilay
        Line = [Line ' Layer = ' num2str(k)];
    end
    fprintf(fid, '%s\n', Line);
    tstart = (nfs_inf.times( 1 ) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;
    dtmin  = (nfs_inf.times(2) - nfs_inf.times(1))*1440 ;
    tend   = tstart + (notims - 1)*dtmin;
    Line = ['Frame = ' num2str(tstart) ' ' num2str(dtmin) ' ' num2str(tend)];
    fprintf(fid, '%s\n', Line);
    Line = 'Values = ';
    fprintf(fid, '%s\n', Line);
    
    %
    % Write the series to file
    %
    
    for itim = 1: notims
        values(itim) =bndval(itim).value(1,k,1);
    end
    
    fprintf(fid,' %12.6f %12.6f %12.6f %12.6f %12.6f \n',values);
    if mod(notims,5) ~= 0; fprintf(fid,'\n');end
    
end

fclose (fid);

