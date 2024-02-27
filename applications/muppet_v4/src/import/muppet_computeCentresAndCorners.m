function dataset=muppet_computeCentresAndCorners(dataset)

% Determine cell centres/corners
switch dataset.type

    case{'scalar2dtz'}

        % Time stack

        dataset.xz=dataset.x;
        dataset.yz=dataset.y;
        dataset.zz=dataset.z;

    case{'scalar2dxy'}

        dataset.xz=dataset.x;
        dataset.yz=dataset.y;
        dataset.zz=dataset.z;
                
        if strcmpi(dataset.location,'z') || strcmpi(dataset.location,'u')

            % When data is stored in cell centres, load coordinates of cell corners (x and y)
            % and compute values z on cell corners (used for shading and contour plots)
            % When this is not possible (coordinates of cell corners are
            % not available), xz, yz and zz are empty
            % patch plots will (by definition) be shifted by half a grid cell
            
            % First try load the grid          
            xg=[];
            yg=[];

            % xg and yg must be the same size as x and y! In Delft3D it
            % includes the dummy row
            
            % xz, yz and zz must also be the same size!
            
            %% Grid
            if isfield(dataset.fid,'SubType')
                switch dataset.fid.SubType
                    case{'Delft3D-trim'}
                        grd=qpread(dataset.fid,'morphologic grid','griddata',dataset.m,dataset.n);
                        xg=grd.X;
                        yg=grd.Y;                        
                end
            end
            
            

            if ~isempty(xg)
                dataset.x=xg;
                dataset.y=yg;
                z(1,:,:)=dataset.zz(1:end-1,1:end-1);
                z(2,:,:)=dataset.zz(2:end,1:end-1);
                z(3,:,:)=dataset.zz(2:end,2:end);
                z(4,:,:)=dataset.zz(1:end-1,2:end);
                z=squeeze(nanmean(z,1));
                dataset.z=zeros(size(dataset.z));
                dataset.z(dataset.z==0)=NaN;
                dataset.z(1:end-1,1:end-1)=z;
                % Also shift zz, so that it will plot properly with pcolor
                % and shading flat
                zz=dataset.zz(2:end,2:end);
                dataset.zz=zeros(size(dataset.zz));
                dataset.zz(dataset.zz==0)=NaN;
                dataset.zz(1:end-1,1:end-1)=zz;
            end
                   
        else
            % When data is stored in cell corners, xz, yz and zz are empty
            % patch plots will (by definition) be shifted by half a grid cell
        end

    case{'scalar2dxz'}

        dataset.xz=dataset.x;
        dataset.yz=dataset.y;
        dataset.zz=dataset.z;

        if strcmpi(dataset.location,'z')

            % When data is stored in cell centres, load coordinates of cell corners (x and y)
            % and compute values z on cell corners (used for shading and contour plots)
            % When this is not possible (coordinates of cell corners are
            % not available), xz, yz and zz are empty
            % patch plots will (by definition) be shifted by half a grid cell
            
            % First try load the grid          
            xg=dataset.x;
            yg=dataset.y;

            % xg and yg must be the same size as x and y! In Delft3D it
            % includes the dummy row
            
            % xz, yz and zz must also be the same size!
            
            %% Grid
            if isfield(dataset.fid,'SubType')
                switch dataset.fid.SubType
                    case{'Delft3D-trim'}                        
                        m=dataset.m;
                        n=dataset.n;
                        if isempty(m)
                            m=0;
                        end
                        if isempty(n)
                            n=0;
                        end                        
                        grdh=qpread(dataset.fid,'hydrodynamic grid','griddata',dataset.timestep,m,n,0);
                        yg=squeeze(grdh.Z);
                        xg=repmat(xg(:,1),[1 size(yg,2)]);
                end
            end

            if ~isempty(xg)
                dataset.x=xg;
                dataset.y=yg;
                z0=dataset.z; % data in cell centres (both horizontal and vertical)

                % Compute data in horizontal cell centres and vertical cell
                % faces (used for contour plots and shades)
                z=[];
                z(1,:,:)=z0(:,1:end-1);
                z(2,:,:)=z0(:,2:end  );
                z=squeeze(nanmean(z,1));

                dataset.z=zeros(size(z,1),size(z,2)+2);
                dataset.z(dataset.z==0)=NaN;
                dataset.z(:,2:end-1)=z;
                % Copy data to top and bottom row
                dataset.z(:,1)=dataset.z(:,2);
                dataset.z(:,end)=dataset.z(:,end-1);                
                
                % And now the data on horizontal cell faces and vertical
                % cell centres (used for patches)
                z=[];
                z(1,:,:)=z0(1:end-1,:);
                z(2,:,:)=z0(2:end  ,:);
                z=squeeze(nanmean(z,1));

                dataset.zz=zeros(size(z,1)+1,size(z,2)+1);
                dataset.zz(dataset.zz==0)=NaN;
                dataset.zz(2:end,1:end-1)=z;
                
                % Cut off NaN rows (these give problems in contour maps)
                if sum(isnan(dataset.x(end,:)))>0
                    dataset.x=dataset.x(1:end-1,:);
                    dataset.y=dataset.y(1:end-1,:);
                    dataset.z=dataset.z(1:end-1,:);
                    dataset.zz=dataset.zz(1:end-1,:);
                end
                if sum(isnan(dataset.x(1,:)))>0
                    dataset.x=dataset.x(2:end,:);
                    dataset.y=dataset.y(2:end,:);
                    dataset.z=dataset.z(2:end,:);
                    dataset.zz=dataset.zz(2:end,:);
                end
            end
                   
        else
            % When data is stored in cell corners, xz, yz and zz are empty
            % patch plots will (by definition) be shifted by half a grid cell
        end        
        
    case{'scalar2duxy','vector2d2duxy'}
        % Read net
        if isempty(dataset.G)
            dataset.G = dflowfm.readNet(dataset.filename,'quiet',1);
            if ~isfield(dataset.G,'node')
                % try the old function
                dataset.G = dflowfm.readNetOld(dataset.filename,'quiet',1);
            end
        end
        
%     case{'vector2d2duxy'}
%         % Read cell circumference
%         if isempty(dataset.G)
%             dataset.G = dflowfm.readNet(dataset.filename,'quiet',1);
%         end
%         iok=0;
%         if isfield(dataset,'flowelemcontour_x')
%             if isempty(dataset.flowelemcontour_x)
%                 iok=1;
%             end
%         else
%             iok=1;
%         end
%         if iok
%             x1=nc_varget(dataset.filename,'FlowElemContour_x');
%             y1=nc_varget(dataset.filename,'FlowElemContour_y');
%             if size(x1,2)>=4
%                 x1=x1(:,1:4);
%                 y1=y1(:,1:4);
%             end
%             m1=size(x1,1);
%             for i=1:m1;
%                 if isnan(x1(i,4))
%                     x1(i,4)=x1(i,1);
%                     y1(i,4)=y1(i,1);
%                 end
%             end
%             dataset.flowelemcontour_x=x1;
%             dataset.flowelemcontour_y=y1;
%         end
end
