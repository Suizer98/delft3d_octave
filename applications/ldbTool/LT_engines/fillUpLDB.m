function varargout=fillUpLDB(Thresh_Dist, ldb,varargin)
% FILLUPLDB  insert points into polygon
%
% Returns a landboundary that contains more points so that 
% every point is seperated by at most a distance Thres_Dist.
%
% All original points are kept, only intermediate points are
% inserted.
%
% outLDB = fillUpLDB(Thresh_Dist,<ldb>);
% [x,y]  = fillUpLDB(Thresh_Dist,<ldb>);
%
% Thresh_Dist =   threshold distance
% ldb         =   the landboury, as 
%                 * filename or 
%                 * array ldb as read by the ldb=landboundary('read','landboundary')
%                 * struct with fields ldbCell, ldbBegin, ldbEnd
%                 * no 2nd argument launches GUI
%
% outLDB = fillUpLDB(Thresh_Dist,ldb,<ldbout>);
%
% ldbout      =   the landboundary filename to save to
%
% by G.J. de Boer, 2008
%
% See also: LANDBOUNDARY, THINOUTLDB, POLYJOIN, POLYSPLIT

% 2008, June, Gerben de Boer: Created, used THINOUTLDB as basis.

OPT.debug = 0;
OPT.disp  = 0;
outLDB    = [];

if nargin==0
   error('syntax: outLDB=fillUpLDB(Thresh_Dist, <ldb>);')
end

if nargin==1
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    ldb=landboundary('read');
end

if ischar(ldb)
    ldb=landboundary('read',ldb);
end

if isempty(ldb)
    return
end

if OPT.debug
   TMP = figure;
   setfig2screensize
   plot(ldb(:,1),ldb(:,2),'k')
   axis equal
end

if ~isstruct(ldb)

    %add nan to beginning and end if there are none
    if ~isnan(ldb(1,1))
        ldb=[nan nan;ldb];
    end
    if ~isnan(ldb(end,1))
        ldb=[ldb;nan nan];
    end
    
    %% See also POLYSPLIT of matlab mapping toolbox fo action below
    
    % nannen zoeken
    did=find(isnan(ldb(:,1)));
    if ~isempty(did)
        rid               = abs(did(1:end-1)-did(2:end));
        remid             = find(rid==1);
        ldb(did(remid),:) = [];
    end
    
    
    id=find(isnan(ldb(:,1)));
    
    % in moten hakken
    hW=waitbar(0,'Disassemble ldb into segments....');
    for ii=1:length(id)-1
        ldbCell{ii}=ldb(id(ii)+1:id(ii+1)-1,:);
        waitbar(ii/(length(id)-1),hW);
    end
    close(hW);
    
else

    ldbCell  = ldb.ldbCell;
    ldbBegin = ldb.ldbBegin;
    ldbEnd   = ldb.ldbEnd;

end

%% fill up (indikken)

for ii=1:length(ldbCell);

    for ip = 1:size(ldbCell{ii},1)-1

       if OPT.disp
       disp([num2str(ii),'/',num2str(length(ldbCell)),'   ',num2str(ip),'/',num2str(size(ldbCell{ii},1)-1)])
       end
    
       local.x     = [ldbCell{ii}(ip,1) ldbCell{ii}(ip+1,1)];
       local.y     = [ldbCell{ii}(ip,2) ldbCell{ii}(ip+1,2)];
       local.dx    = diff(local.x);
       local.dy    = diff(local.y);
       local.ds    = sqrt(local.dx.^2 + local.dy.^2);
       
       if ip==1
          xnew = [local.x(1)];
          ynew = [local.y(1)];
       end

       if local.ds > Thresh_Dist
       
          local.n2get = ceil(local.ds./Thresh_Dist) + 1; % number of intervals + 1;
          
          local.xnew = linspace(ldbCell{ii}(ip,1),ldbCell{ii}(ip+1,1),local.n2get);
          local.ynew = linspace(ldbCell{ii}(ip,2),ldbCell{ii}(ip+1,2),local.n2get);
          
          if OPT.debug
             hold on
             handle.p1 = plot(local.x,   local.y   ,'go');
             handle.p2 = plot(local.xnew,local.ynew,'r.');
             handle.t  = text(local.x(1),local.y(1),num2str(local.ds));
             pausedisp
             delete(handle.p1)
             delete(handle.p2)
             delete(handle.t )
          end
          
          xnew = [xnew local.xnew(2:end)];
          ynew = [ynew local.ynew(2:end)];
          
       else
       
          xnew = [xnew local.x(2:end)];
          ynew = [ynew local.y(2:end)];

       end
       
    end

    %size(ldbCell{ii})
    %size([xnew(:) ynew(:)])

    ldbCell{ii} = [xnew(:) ynew(:)];

end

if ~isstruct(ldb)

    %% See also POLYJOIN of matlab mapping toolbox fo action below

    %herbouwen ldb
    ldb = [nan nan];
    hW  = waitbar(0,'Please wait while building new ldb');
    for ii=1:length(ldbCell)
        if ~isempty(ldbCell{ii})
            ldb=[ldb; ldbCell{ii} ; nan nan];
        end
        waitbar(ii/length(ldbCell),hW);
    end
    close(hW);
    
    if nargout==1
       varargout = {ldb};
    elseif nargout==2
       varargout = {ldb(:,1),ldb(:,2)};
    end

   if nargin==3
      ldbnameout = varargin{1};
      landboundary('write',ldbnameout,ldb)
   end   

else

    if nargout==1
       outLDB.ldbCell  = ldbCell;
       outLDB.ldbBegin = ldbBegin;
       outLDB.ldbEnd   = ldbEnd;
       varargout       = {outLDB};
    elseif nargout==2
       error('Not implemented [x,y] output for isstruct(ldb)')
    end

end

%% EOF