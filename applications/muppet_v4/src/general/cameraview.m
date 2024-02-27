function varargout=cameraview(varargin)

tar=[];
pos=[];
ang=[];
dasp=[1 1 1];

for ii=1:length(varargin)
    if ischar(lower(varargin{ii}))
        switch lower(varargin{ii})
            case{'target'}
                tar=varargin{ii+1};
            case{'position'}
                pos=varargin{ii+1};
            case{'viewangle'}
                ang=varargin{ii+1};
            case{'dataaspectratio'}
                dasp=varargin{ii+1};                
        end
    end
end

if isempty(tar)    
    % Position and angle given
    dx=ang(3)*cos(pi*ang(2)/180)*cos(pi*ang(1)/180)*dasp(1);
    dy=ang(3)*cos(pi*ang(2)/180)*sin(pi*ang(1)/180)*dasp(2);
    dz=ang(3)*sin(pi*ang(2)/180)*dasp(3);    
    tar(1)=pos(1)-dx;
    tar(2)=pos(2)-dy;
    tar(3)=pos(3)-dz;    
    varargout{1}=tar;    
elseif isempty(pos)    
    % Target and angle given
    dx=ang(3)*cos(pi*ang(2)/180)*cos(pi*ang(1)/180)*dasp(1);
    dy=ang(3)*cos(pi*ang(2)/180)*sin(pi*ang(1)/180)*dasp(2);
    dz=ang(3)*sin(pi*ang(2)/180)*dasp(3);    
    pos(1)=tar(1)+dx;
    pos(2)=tar(2)+dy;
    pos(3)=tar(3)+dz;    
    varargout{1}=pos;
else
    % Target and position given
    dx=(pos(1)-tar(1))/dasp(1);
    dy=(pos(2)-tar(2))/dasp(2);
    dz=(pos(3)-tar(3))/dasp(3);
    az=180*atan2(dy,dx)/pi;
    hordst=sqrt(dx^2+dy^2);
    el=atan2(dz,hordst)*180/pi;
    dst=sqrt(dx^2 + dy^2 + dz^2);
    varargout{1}=[az el dst];
end
