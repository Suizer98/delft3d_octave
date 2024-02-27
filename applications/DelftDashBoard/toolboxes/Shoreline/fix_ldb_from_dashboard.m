function pol=fix_ldb_from_dashboard(varargin)

% fixes and closes polygons exported by Dashboard Shoreline Toolbox

polin=[];
fin=[];
fout=[];
xy=[];
minarea=0;
cstype='geographic';
iclose=1;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch varargin{ii}
            case{'polygon'}
                polin=varargin{ii+1};
            case{'xy'}
                polxy=varargin{ii+1};
            case{'filename_in'}
                fin=varargin{ii+1};
            case{'filename_out'}
                fout=varargin{ii+1};
            case{'cstype'}
                cstype=varargin{ii+1};
            case{'minarea'}
                minarea=varargin{ii+1};
            case{'close'}
                iclose=varargin{ii+1};
        end
    end
end

if ~isempty(fin)
    s=tekal('read',fin,'loaddata');
    npol=0;
    npli=0;
    for j=1:length(s.Field)
        x=s.Field(j).Data(:,1);
        y=s.Field(j).Data(:,2);
        if x(1)==x(end) && y(1)==y(end)
            % Closed polygon
            npol=npol+1;
            pol(npol).x=x;
            pol(npol).y=y;
        else
            npli=npli+1;
            pli(npli).x=x;
            pli(npli).y=y;
        end
    end
elseif ~isempty(polin)
    for j=1:length(polin)
        x=polin(j).x;
        y=polin(j).y;
        if x(1)==x(end) && y(1)==y(end)
            % Closed polygon
            npol=npol+1;
            pol(npol).x=x;
            pol(npol).y=y;
        else
            npli=npli+1;
            pli(npli).x=x;
            pli(npli).y=y;
        end
    end
elseif ~isempty(polxy)
    newpol=1;
    ip=0;
    npol=0;
    for ii=1:size(polxy,1)
        if newpol
            if ~isnan(polxy(ii,1))
                newpol=0;
                npol=npol+1;
                ip=1;
                pol0(npol).x(ip,1)=polxy(ii,1);
                pol0(npol).y(ip,1)=polxy(ii,2);
            end
        else
            if ~isnan(polxy(ii,1))
                
                ip=ip+1;

                pol0(npol).x(ip,1)=polxy(ii,1);
                pol0(npol).y(ip,1)=polxy(ii,2);
            else
                newpol=1;
            end
        end
    end
    npol=0;
    npli=0;
    for j=1:length(pol0)
        x=pol0(j).x;
        y=pol0(j).y;
        if length(x)>2
        if x(1)==x(end) && y(1)==y(end)
            % Closed polygon
            npol=npol+1;
            pol(npol).x=x;
            pol(npol).y=y;
        else
            % Polyline
            npli=npli+1;
            pli(npli).x=x;
            pli(npli).y=y;
        end
        end
    end
else
    error('Please specify input file name, polygon structure or polygon matrix');
end

% Now merge the polylines
for ipli=1:npli
    
    if ~isempty(pli(ipli).x)
        
        while 1
            
            iatt=0; % No pli's attached to this pli yet
            
            for j=1:npli
                
                if ipli~=j % Don't attach to itself
                    
                    if ~isempty(pli(j).x)
                        
                        % Find pli that attaches to the beginning of this pli
                        ind1=find(pli(j).x==pli(ipli).x(1) & pli(j).y==pli(ipli).y(1));
                        % Find pli that attaches to the end of this pli
                        ind2=find(pli(j).x==pli(ipli).x(end) & pli(j).y==pli(ipli).y(end));
                        
                        if ~isempty(ind1) && ~isempty(ind2)
                            % Attached to both sides
                            if ind1<ind2
                                pli(j).x=flipud(pli(j).x(ind1+1:ind2));
                                pli(j).y=flipud(pli(j).y(ind1+1:ind2));
                                pli(ipli).x=[pli(j).x;pli(ipli).x];
                                pli(ipli).y=[pli(j).y;pli(ipli).y];
                            else
                                pli(j).x=pli(j).x(ind2+1:ind1);
                                pli(j).y=pli(j).y(ind2+1:ind1);
                                pli(ipli).x=[pli(ipli).x;pli(j).x];
                                pli(ipli).y=[pli(ipli).y;pli(j).y];
                            end
                            pli(j).x=[];
                            pli(j).y=[];
                            iatt=1;
                        elseif ~isempty(ind1)
                            % Only attached to the beginning
                            if ind1==1
                                pli(j).x=flipud(pli(j).x);
                                pli(j).y=flipud(pli(j).y);
                                pli(j).x=pli(j).x(1:end-1);
                                pli(j).x=pli(j).y(1:end-1);
                                pli(ipli).x=[pli(j).x;pli(ipli).x];
                                pli(ipli).y=[pli(j).y;pli(ipli).y];
                            elseif ind1==length(pli(j).x)
                                pli(ipli).x=[pli(j).x(1:end-1);pli(ipli).x];
                                pli(ipli).y=[pli(j).y(1:end-1);pli(ipli).y];
                            else
                                if pli(j).x(ind1-1)==pli(ipli).x(2) && pli(j).y(ind1-1)==pli(ipli).y(2)
                                    pli(j).x=flipud(pli(j).x(ind1+1:end));
                                    pli(j).y=flipud(pli(j).y(ind1+1:end));
                                    pli(ipli).x=[pli(j).x;pli(ipli).x];
                                    pli(ipli).y=[pli(j).y;pli(ipli).y];
                                else
                                    pli(j).x=pli(j).x(1:ind1-1);
                                    pli(j).y=pli(j).y(1:ind1-1);
                                    pli(ipli).x=[pli(j).x;pli(ipli).x];
                                    pli(ipli).y=[pli(j).y;pli(ipli).y];
                                end
                            end
                            pli(j).x=[];
                            pli(j).y=[];
                            iatt=1;
                        elseif ~isempty(ind2)
                            % Only attached to the end
                            if ind2==1
                                pli(ipli).x=[pli(ipli).x;pli(j).x(2:end)];
                                pli(ipli).y=[pli(ipli).y;pli(j).y(2:end)];
                            elseif ind2==length(pli(j).x)
                                pli(j).x=flipud(pli(j).x);
                                pli(j).y=flipud(pli(j).y);
                                pli(ipli).x=[pli(ipli).x;pli(j).x(2:end)];
                                pli(ipli).y=[pli(ipli).y;pli(j).y(2:end)];
                            else
                                if pli(j).x(ind2-1)==pli(ipli).x(end-1) && pli(j).y(ind2-1)==pli(ipli).y(end-1)
                                    pli(ipli).x=[pli(ipli).x;pli(j).x(2:end)];
                                    pli(ipli).y=[pli(ipli).y;pli(j).y(2:end)];
                                else
                                    pli(j).x=pli(j).x(1:ind2-1);
                                    pli(j).y=pli(j).y(1:ind2-1);
                                    pli(j).x=flipud(pli(j).x);
                                    pli(j).y=flipud(pli(j).y);
                                    pli(ipli).x=[pli(ipli).x;pli(j).x];
                                    pli(ipli).y=[pli(ipli).y;pli(j).y];
                                end
                            end
                            pli(j).x=[];
                            pli(j).y=[];
                            iatt=1;
                        else
                            % Not attached
                            continue
                        end
                    end
                end
            end
            if iatt==0
                break
            end
        end % while
    end
end

% Merge new polygons with original structure
for ipli=1:npli
    if ~isempty(pli(ipli).x)
        npol=npol+1;
        pol(npol).x=pli(ipli).x;
        pol(npol).y=pli(ipli).y;
    end
end

% Close polygons
if iclose
    for ipol=1:npol
        if pol(ipol).x(1)~=pol(ipol).x(end) || pol(ipol).y(1)~=pol(ipol).y(end)
            pol(ipol).x(end+1)=pol(ipol).x(1);
            pol(ipol).y(end+1)=pol(ipol).y(1);
        end        
    end
end
    
% Check if area of polygon exceeds minimum area
if minarea>0
    npol=0;
    pol0=pol;
    pol=[];
    for ipol=1:length(pol0)
        x=pol0(ipol).x;
        y=pol0(ipol).y;
        if x(1)==x(end) && y(1)==y(end)
            % Polygon is closed
            if strcmpi(cstype(1:3),'geo')
                x=x*cos(y(1)*pi/180)*111111;
                y=y*111111;
            end
            %
            ar=polyarea(x,y);
            if ar>minarea
                npol=npol+1;
                pol(npol).x=pol0(ipol).x;
                pol(npol).y=pol0(ipol).y;
            end
        else
            % Not a close polygon
            npol=npol+1;
            pol(npol).x=pol0(ipol).x;
            pol(npol).y=pol0(ipol).y;            
        end
    end
end

% And save output
if ~isempty(fout)
    fid=fopen(fout,'wt');
    if strcmpi(cstype(1:3),'geo')
        fmt='%12.7f %12.7f\n';
    else
        fmt='%12.1f %12.1f\n';
    end
    for ipol=1:npol
        fprintf(fid,'%s\n',['BL' num2str(ipol,'%0.5i')]);
        fprintf(fid,'%i %i\n',length(pol(ipol).x),2);
        xy=[pol(ipol).x pol(ipol).y];
        xy=xy';
        fprintf(fid,fmt,xy);
    end
    fclose(fid);
end
