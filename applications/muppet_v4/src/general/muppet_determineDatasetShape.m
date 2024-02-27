function dataset=muppet_determineDatasetShape(dataset,timestep,istation,m,n,k)

sz=dataset.size;
quantity=dataset.quantity;

% % Determines shape matrix of selected dataset
% 
% shpmat=[0 0 0 0 0];
% % Time
% if sz(1)>0
%     if isempty(timestep) || length(timestep)>1
%         % Multiple time steps
%         shpmat(1)=2;
%     else
%         % One time step
%         shpmat(1)=1;
%     end
% end
% % Stations
% if sz(2)>0
%     if isempty(istation) || length(istation)>1
%         shpmat(2)=2;
%     else
%         shpmat(2)=1;
%     end
% end
% % M
% if sz(3)>0
%     if isempty(m) || length(m)>1
%         shpmat(3)=2;
%     else
%         shpmat(3)=1;
%     end
% end
% % N
% if sz(4)>0
%     if isempty(n) || length(n)>1
%         shpmat(4)=2;
%     else
%         shpmat(4)=1;
%     end
% end
% % K
% if sz(5)>0
%     if isempty(k) || length(k)>1
%         shpmat(5)=2;
%     else
%         shpmat(5)=1;
%     end
% end

% Determines shape of required dataset
if sz(2)>0
    % Data from station
    if length(timestep)>1
        % Time varying
        if length(k)>1
%            shp='timestack';
            plane='tz';
            ndim=2;
        elseif length(m)>1 || length(n)>1
%            shp='timestack';
            plane='tx';
            ndim=2;
        else
            switch quantity
                case{'location'}
                    %            shp='track';
                    plane='xy';
                    ndim=1;
                otherwise
                    %            shp='timeseries';
                    plane='tv';
                    ndim=1;
            end
        end
    else
        switch quantity
            case{'location'}
                %            shp='location';
                plane='xy';
                ndim=1;
            otherwise
                %        shp='profile';
                plane='vz';
                ndim=1;
        end
        
    end
else
    % Data from matrix
    if length(timestep)>1
        % Time-varying
        if length(m)>1
            if sz(4)==0
                %            shp='track';
                plane='xy';
                ndim=1;
            else
%            shp='timestack';
                plane='tx';
                ndim=2;
            end
        elseif length(n)>1
%            shp='timestack';
            plane='tx';
            ndim=2;
        elseif length(k)>1
%            shp='timestack';
            plane='tz';
            ndim=2;
        elseif sz(3)==0 && sz(4)==0
            switch quantity
                case{'location'}
                    %            shp='location';
                    plane='xy';
                    ndim=1;
                otherwise
                    %        shp='profile';
                    plane='tv';
                    ndim=1;
            end
        else
%            shp='timeseries';
            plane='tv';
            ndim=1;
        end
    else
        % Constant
        if length(m)>1
            if dataset.unstructuredgrid
                % Data on unstructured grid
                if length(k)>1
                    plane='xz';
                    ndim=2;
                else
                    switch quantity
                        case{'scalar'}
                            plane='xy';
                            ndim=2;
                        case{'location'}
                            %                         shp='crosssection1d';
                            plane='xy';
                            ndim=2;
                        case{'vector2d'}
                            plane='xy';
                            ndim=2;
                    end
                end
            else
                if length(n)>1
                    %                shp='map';
                    plane='xy';
                    ndim=2;
                elseif length(k)>1
                    %                shp='crosssection2d';
                    plane='xz';
                    ndim=2;
                else
                    switch quantity
                        case{'location'}
                            plane='xy';
                            ndim=1;
                        otherwise
                            plane='xv';
                            ndim=1;
                    end
                end
            end
        elseif length(n)>1
            if length(k)>1
                plane='xz';
                ndim=2;
            else
                switch quantity
%                    case{'location','scalar'}
                    case{'location'}
                        plane='xy';
%                        plane='xv';
                        ndim=1;
                    otherwise
                        plane='xv';
                        ndim=1;
                end
            end
        else
            if length(k)>1
                % Profile
                plane='vz';
                ndim=1;
            else
                switch quantity
                    case{'location','scalar','xy','vector2d'}
                        plane='xy';
                        ndim=1;
                end
            end
        end
    end
end

dataset.plane=plane;
dataset.ndim=ndim;
