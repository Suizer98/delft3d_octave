function [MDAdata,Y1NEW]=computeORTHOcrossing(MDAdata,LDB,shiftCOAST)
% Computes cross-shore distance to MDA reference line
% 
% INPUT:
%   MDAdata         Structure with 'reference line' points
%                    .X  x-coordinate [Nx1]
%                    .Y  y-coordinate [Nx1]
%   LDB             Array with x,y positions of shoreline ([Nx2])
%   shiftCOAST=0    Computes cross-shore positions (Y1) along MDA coastline, using minimum coastline position Y1min (if multiple data points in front of X,Y position) & No extrapolation
%   shiftCOAST=1    Computes cross-shore positions (Y1) along MDA coastline, using minimum coastline position Y1min (if multiple data points in front of X,Y position) & With extrapolation
%   shiftCOAST=2    Computes cross-shore positions (Y1) along MDA coastline, using maximum coastline position Y1max (if multiple data points in front of X,Y position) & No extrapolation
%   shiftCOAST=3    Computes cross-shore positions (Y1) along MDA coastline, using maximum coastline position Y1max (if multiple data points in front of X,Y position) & With extrapolation
%
% By B.J.A. Huisman (Deltares, 2017)
if nargin<3
    shiftCOAST=1;
end

    % GET DISTANCE ALONGSHORE
    MDAdataREF=MDAdata;
    dx=diff(MDAdata.X);dx=[dx(1);(dx(1:end-1)+dx(2:end))/2;dx(end)];dx(dx==0)=1e-6;
    dy=diff(MDAdata.Y);dy=[dy(1);(dy(1:end-1)+dy(2:end))/2;dy(end)];dy(dy==0)=1e-6;
    dx2=diff(LDB(:,1));dx2(dx2==0)=1e-6;%dx2=[dx2(1);(dx2(1:end-1)+dx2(2:end))/2;dx2(end)];
    dy2=diff(LDB(:,2));dy2(dy2==0)=1e-6;%dy2=[dy2(1);(dy2(1:end-1)+dy2(2:end))/2;dy2(end)];
    dist=(dx2.^2+dy2.^2).^0.5;
    
    % GET ID'S
    dist1=((MDAdata.X-LDB(1,1)).^2 + (MDAdata.Y-LDB(1,2)).^2).^0.5;
    dist2=((MDAdata.X-LDB(end,1)).^2 + (MDAdata.Y-LDB(end,2)).^2).^0.5;
    id1=find(dist1==min(dist1),1);
    id2=find(dist2==min(dist2),1);
    
    %% COMPUTE Y1 DISTANCES (FOR PART COVERED BY LDB)
    Y1REF=MDAdataREF.Y1;
    Y1NEW=nan(size(MDAdata.X));
    MDAdata.Y1=Y1NEW;
    MDAdata.XREFcoast=nan(size(MDAdata.X));
    MDAdata.YREFcoast=nan(size(MDAdata.X));
    for xx1=1:length(dx)
        RC1 = [-dx(xx1)/dy(xx1)];
        X1 = MDAdata.X(xx1);
        Y1 = MDAdata.Y(xx1);
        for xx2=1:size(LDB,1)-1
            RC2 = [dy2(xx2)/dx2(xx2)];
            X2 = LDB(xx2,1); X2mid=mean(LDB(xx2:xx2+1,1));
            Y2 = LDB(xx2,2); Y2mid=mean(LDB(xx2:xx2+1,2));
            
            x = ((Y2-RC2*X2)-(Y1-RC1*X1)) /(RC1-RC2);
            y = RC1 * x + (Y1-RC1*X1);
            
            dist2=((X2mid-x(1)).^2+(Y2mid-y(1)).^2).^0.5;
            if dist2<=dist(xx2)/2
                Y1NEW2 = ((X1-x).^2 + (Y1-y).^2).^0.5;
                MDAdata.XREFcoast(xx1) = x(1);
                MDAdata.YREFcoast(xx1) = y(1);
                if ~isnan(MDAdata.Y1(xx1)) && shiftCOAST<=1
                    MDAdata.Y1(xx1) = min([MDAdata.Y1(xx1);Y1NEW2(:)]);
                    Y1NEW(xx1) = MDAdata.Y1(xx1);
                elseif ~isnan(MDAdata.Y1(xx1)) && (shiftCOAST==2 || shiftCOAST==3)
                    MDAdata.Y1(xx1) = max([MDAdata.Y1(xx1);Y1NEW2(:)]);
                    Y1NEW(xx1) = MDAdata.Y1(xx1);
                elseif ~isnan(MDAdata.Y1(xx1)) && shiftCOAST>=4
                    MDAdata.Y1(xx1) = mean([MDAdata.Y1(xx1);Y1NEW2(:)]);
                    Y1NEW(xx1) = MDAdata.Y1(xx1);
                else
                    MDAdata.Y1(xx1) = Y1NEW2;
                    Y1NEW(xx1) = MDAdata.Y1(xx1);
                end
            end
        end
    end

    %% GET COASTLINE POSITION FOR REST OF THE COAST
    % shift rest of coast with DY at boundaries of region with LDB
    if shiftCOAST==1 || shiftCOAST==3  || shiftCOAST==5 
    DY = interpNANs(Y1NEW-Y1REF);
    for xx1=1:length(dx)
        if isnan(Y1NEW(xx1))
            Y1NEW(xx1) = Y1REF(xx1)+DY(xx1);
            MDAdata.Y1(xx1) = Y1NEW(xx1);
        end
    end
    end
    
%     %% GET MINIMUM COASTLINE POSITION (FOR PART COVERED BY LDB)
%     for xx1=1:length(dx)
%         if ~isnan(Y1NEW(xx1)) 
%         MDAdata.Y1(xx1) = min(MDAdataREF.Y1(xx1),MDAdata.Y1(xx1));
%         end
%     end
end

