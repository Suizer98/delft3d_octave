function dataset=muppet_copyToDataStructure(dataset,d)

% Determines x coordinate (if necessary)
% Copies data from structure d to dataset structure

%% Plot component
% Compute y value for cross sections
plotcoordinate=[];

switch dataset.plane
    case{'xv','xz','tx'}
        switch(lower(dataset.plotcoordinate))
            case{'xcoordinate'}
                if size(d.X,1)>1 && size(d.X,2)>1
                    % Matrix
                    x=squeeze(nanmean(d.X,2));
                else
                    % Vector
                    x=squeeze(d.X);
                end
            case{'ycoordinate'}
                if size(d.X,1)>1 && size(d.X,2)>1
                    % Matrix
                    x=squeeze(nanmean(d.Y,2));
                else
                    x=squeeze(d.Y);
                end
            case{'pathdistance'}
                if size(d.X,1)>1 && size(d.X,2)>1
                    % Matrix
                    xp=squeeze(nanmean(d.X,2));
                    yp=squeeze(nanmean(d.Y,2));
                else
                    % Vector
                    xp=squeeze(d.X);
                    yp=squeeze(d.Y);
                end
                x=pathdistance(xp,yp,dataset.coordinatesystem.type);
            case{'revpathdistance'}
                if size(d.X,1)>1 && size(d.X,2)>1
                    % Matrix
                    xp=squeeze(nanmean(d.X,2));
                    yp=squeeze(nanmean(d.Y,2));
                else
                    % Vector
                    xp=squeeze(d.X);
                    yp=squeeze(d.Y);
                end
                x=pathdistance(xp,yp,dataset.coordinatesystem.type);
                x=x(end:-1:1);
        end
        plotcoordinate=x;
end

% Set empty values
dataset.x=[];
dataset.x=[];
dataset.y=[];
dataset.z=[];
dataset.xz=[];
dataset.yz=[];
dataset.zz=[];
dataset.u=[];
dataset.v=[];
dataset.w=[];

% 7 planes
% 4 quantities (or more)
% 3 dimensions

switch dataset.plane
    
    case{'xy'}
        % map (top view)
        dataset.x=d.X;
        dataset.y=d.Y;
        if isfield(d,'XUnits')
            switch d.XUnits
                case{'deg'}
                    dataset.coordinatesystem.name='WGS 84';
                    dataset.coordinatesystem.type='geographic';
            end
        end
        switch dataset.quantity
            case{'scalar','boolean'}
                dataset.z=d.Val;
            case{'grid'}
                dataset.xdam=d.XDam;
                dataset.ydam=d.YDam;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'tidalellipse'}
                dataset.uamplitude=d.UAmplitude;
                dataset.vamplitude=d.VAmplitude;
                dataset.uphase=d.UPhase;
                dataset.vphase=d.VPhase;
        end
    
    case{'vz'}
        % profile
        dataset.x=d.Val;
        dataset.y=d.Z;
        switch dataset.quantity
            case{'scalar'}
                dataset.x=d.Val;
                dataset.y=d.Z;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    
    case{'xv'}
        % cross-section 1d
        dataset.x=plotcoordinate;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    
    case{'xz'}
        % cross-section 2d
        dataset.x0=plotcoordinate;
        dataset.y=d.Z;
        dataset.x=zeros(size(dataset.y));
        for ii=1:size(dataset.y,2)
            dataset.x(:,ii)=plotcoordinate;
        end
        switch dataset.quantity
            case{'scalar'}
                dataset.z=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end

    case{'tv'}
        % time series
        dataset.x=d.Time;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end

    case{'tx'}
        % time stack (horizontal)
        [dataset.x,dataset.y]=meshgrid(d.Time,plotcoordinate);
        switch dataset.quantity
            case{'scalar'}
                dataset.z=d.Val';
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end

    case{'tz'}
        % time stack (vertical)
        t=d.Time;
        if size(t,1)>1 && size(t,2)>1
            % Matrix
            t=squeeze(t(:,1));
        end
        [dataset.y,dataset.x]=meshgrid(squeeze(d.Z(1,:)),t);
        dataset.y=d.Z;
        switch dataset.quantity
            case{'scalar'}
                dataset.z=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
        

end
