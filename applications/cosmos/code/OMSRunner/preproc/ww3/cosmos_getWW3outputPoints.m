function [rid,names,x,y]=cosmos_getWW3outputPoints(hm,m)

model=hm.models(m);

rid=[];
x=[];
y=[];

%% Observation points
imod=0;
ip=0;
if model.nrStations>0
    imod=1;
    rid{imod}=model.runid;
    names{imod}=model.name;
    for i=1:model.nrStations
        ip=ip+1;
        x{imod}(ip)=model.stations(i).location(1);
        y{imod}(ip)=model.stations(i).location(2);
    end
end

%% Nesting points

n=length(model.nestedWaveModels);

for j=1:n
    i=model.nestedWaveModels(j);

    % A model is nested in this WAVEWATCH III model

    if ~strcmpi(hm.models(i).type,'ww3') && hm.models(i).priority>0

        % And it's not a WAVEWATCH III model

        locfile=[hm.models(i).datafolder 'nesting' filesep model.name '.loc'];

        if ~exist(locfile,'file') && strcmpi(hm.models(i).type,'delft3dflowwave') 
            % Find boundary points nested grid
            grdname=[hm.models(i).datafolder 'input' filesep hm.models(i).name '_swn.grd'];
            [xg,yg,enc]=wlgrid('read',grdname);
            nstep=10;
            [xb,yb]=getGridOuterCoordinates(xg,yg,nstep);

            x0=model.xOri;
            y0=model.yOri;
            nx=model.nX;
            ny=model.nY;
            dx=model.dX;
            dy=model.dY;

            depname=[model.datafolder 'input' filesep model.name '.bot'];
            
            if ~strcmpi(hm.models(i).coordinateSystem,model.coordinateSystem) || ~strcmpi(hm.models(i).coordinateSystemType,model.coordinateSystemType)
                [xb,yb]=convertCoordinates(xb,yb,'persistent','CS1.name',hm.models(i).coordinateSystem,'CS1.type',hm.models(i).coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            end
        
            [xb,yb]=checkNestDepthsWW3(depname,x0,y0,nx,ny,dx,dy,xb,yb);
            
            xb(xb>180)=xb(xb>180)-360;
            
            d=[xb yb];
            % Check for points on land
            save(locfile,'d','-ascii');
        end

        pnts=load(locfile);
        np=size(pnts,1);

%         if ~strcmpi(hm.models(i).coordinateSystem,model.coordinateSystem) || ~strcmpi(hm.models(i).coordinateSystemType,model.coordinateSystemType)
%             % Convert coordinates
%             xx=pnts(:,1);
%             yy=pnts(:,2);
%             [xx,yy]=ConvertCoordinates(xx,yy,'persistent','CS1.name',hm.models(i).coordinateSystem,'CS1.type',hm.models(i).coordinateSystemType,'CS2.name',model.coordinateSystem,'CS2.type',model.coordinateSystemType);
%             pnts(:,1)=xx;
%             pnts(:,2)=yy;
%         end

        imod=imod+1;
        rid{imod}=hm.models(i).runid;
        names{imod}=hm.models(i).name;

        ip=0;
        for k=1:np
            ip=ip+1;
            x{imod}(ip)=pnts(k,1);
            y{imod}(ip)=pnts(k,2);
        end
    end

end
