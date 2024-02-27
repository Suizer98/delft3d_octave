function [pos,tar]=flightpathspline(flightpath,times,dataaspectratio)

itar=0;
ipos=0;
iang=0;

for ip=1:length(flightpath.waypoint)    
    
    % Check type of view
    wp=flightpath.waypoint(ip).waypoint;
    
    if isfield(wp,'cameratargetx') || isfield(wp,'cameratargety') || isfield(wp,'cameratargetz')
        if ~isfield(wp,'cameratargetx') || ~isfield(wp,'cameratargety') || ~isfield(wp,'cameratargetz')
            error('Incomplete camera target information!');
        end
        itar=1;
        tar0(1)=str2double(wp.cameratargetx);
        tar0(2)=str2double(wp.cameratargety);
        tar0(3)=str2double(wp.cameratargetz);
    end

    if isfield(wp,'camerapositionx') || isfield(wp,'camerapositiony') || isfield(wp,'camerapositionz')
        if ~isfield(wp,'camerapositionx') || ~isfield(wp,'camerapositiony') || ~isfield(wp,'camerapositionz')
            error('Incomplete camera position information!');
        end
        ipos=1;
        pos0(1)=str2double(wp.camerapositionx);
        pos0(2)=str2double(wp.camerapositiony);
        pos0(3)=str2double(wp.camerapositionz);
    end

    if isfield(wp,'cameraazimuth') || isfield(wp,'cameraelevation') || isfield(wp,'cameradistance')
        if ~isfield(wp,'cameraazimuth') || ~isfield(wp,'cameraelevation') || ~isfield(wp,'cameradistance')
            error('Incomplete camera angle information!');
        end
        iang=1;
        ang0(1)=str2double(wp.cameraazimuth);
        ang0(2)=str2double(wp.cameraelevation);
        ang0(3)=str2double(wp.cameradistance);
    end
    
    if itar && ipos
        % No need to do anything
    elseif itar && iang
        pos0=cameraview('viewangle',ang0,'target',tar0,'dataaspectratio',dataaspectratio);
    elseif ipos && iang
        tar0=cameraview('viewangle',ang0,'position',pos0,'dataaspectratio',dataaspectratio);
    else
        error('Incomplete camera view information!');
    end
        
    t0(ip)=datenum(flightpath.waypoint(ip).waypoint.time,'yyyymmdd HHMMSS');    
    
    tarx0(ip)=tar0(1);
    tary0(ip)=tar0(2);
    tarz0(ip)=tar0(3);
    
    posx0(ip)=pos0(1);
    posy0(ip)=pos0(2);
    posz0(ip)=pos0(3);

end

tar(:,1)=spline(t0,tarx0,times)';
tar(:,2)=spline(t0,tary0,times)';
tar(:,3)=spline(t0,tarz0,times)';

pos(:,1)=spline(t0,posx0,times)';
pos(:,2)=spline(t0,posy0,times)';
pos(:,3)=spline(t0,posz0,times)';
