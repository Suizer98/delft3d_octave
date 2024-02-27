function animateXBvar(XB,var,mode,movie,cax,thinning,gridstraight,alfa)
% Animate XBeach variable 
% animateXBvar(XB,var,mode,movie(optional),cax(optional),thinning(optional),gridstraight(optional),alfa(optional))
% 
% XB   = XBeach meta data from getdimensions or xb_getdimensions function
% var  = single output array read by readvar or cell array of 2 output arrays
% mode = type of plot required: in pcolor mode (1) (11, with contour lines), 
%        3D mode (2), quiver mode (3), surf (4) or sediment layers (5)
% movie = save to movie files: 0 (no), 1 (png), 2 (avi). Default 0
% cax   = color axis ([min max]) for figure, default auto
% thinning = thinning factor for quivers (n)
% gridstraight =  rotate grid to x-y plain  (0/1). Default = 0
% alfa = angle from east to x (required in case gridstraight == 1)
%
% example:
% XB = getdimensions(pwd);
% zs = readvar('zs.dat',XB,'2d');
% zb = readvar('zb.dat',XB,'2d');
% animateXBvar(XB,{zs zb},2);

if iscell(var)
    s=size(var{1});
else
    s=size(var);
end

if ndims(s)<3
    ts=XB.tsglobal;
elseif length(XB.tsglobal)==s(3)
    ts=XB.tsglobal;
elseif length(XB.tsmean)==s(3)
    ts=XB.tsmean;
else
    warning('length of var does not match length of output times');
end

if ~exist('movie','var')
    movie = 0;
end

if exist('gridstraight','var')
    if gridstraight
        [x,y]=grid2straight(XB.x,XB.y);
        gridstraight=1;
    else
        x=XB.x;
        y=XB.y;
        gridstraight=0;
    end
else
    x=XB.x;
    y=XB.y;
    gridstraight=0;
end




switch mode
    case 1
        p1=pcolor(x,y,var(:,:,1));     
        shading flat
        title({[num2str(ts(1)) ' s'];'Press any key to start'});
        if exist('cax','var')
            caxis(cax);
        end
        colorbar;
        pause

        for i=2:s(3)
            set(p1,'Cdata',var(:,:,i),'Zdata',var(:,:,i));
            title([num2str(ts(i)) ' s']);
            pause(.5);
        end
    case(11)
        var1=var{1};
        zb=var{2};
        p1=pcolor(x,y,var1(:,:,1));hold on;cc=caxis;     
        [c,h]=contour(x,y,zb(:,:,1),[-2 0 2],'k');hold off;caxis(cc);
        shading flat
        title({[num2str(ts(1)) ' s'];'Press any key to start'});
        if exist('cax','var')
            caxis(cax);
        end
        colorbar;
        pause
        for i=2:s(3)
            set(p1,'Cdata',var1(:,:,i));%,'Zdata',var1(:,:,i));
            set(h,'color','k');
            title([num2str(ts(i)) ' s']);
            pause(.5);
        end
    case 2
        var1=var{1};
        var2=var{2};
        if var1(1,1,1)<var2(1,1,1)
            zb=var1;
            zs=var2;
        else
            zb=var2;
            zs=var1;
        end
        opengl software
        zs(zs<=zb+0.05)=NaN;
        s1=surf(x,y,zb(:,:,1)); hold on
        C = del2(zs(:,:,1));
        s2=surf(x,y,zs(:,:,1),C);shading interp;hold off;view(-31,36);
        set(s2,'SpecularColorReflectance',0.9,'SpecularExponent',8,'SpecularStrength',0.6);
        set(s2,'facelighting','gouraud','AmbientStrength',1,'facealpha',0.6,'facecolor',[0 0.4 0.9]);
        set(s1,'facelighting','gouraud','AmbientStrength',0.8,'SpecularColorReflectance',0.6,'SpecularExponent',100,'SpecularStrength',0.2);
        light('position',[0 0 20]);
%         view(-29,56);
%         view(0,90);
        view(-17,60);
        colormap copper;
        if exist('cax','var')
            caxis(cax);
        else
            caxis([-1.5 1])
        end
        set(gcf,'Renderer','OpenGL');
        grid off
        axis off
        title({[num2str(ts(1)) ' s'];'Press any key to start'});
        pause(5);
        if movie == 1
            saveas(gcf,'fig1.png');
        elseif movie ==2
            F=avifile('overwash3.avi','compression','none','fps',3);
            ff=getframe;
            F = addframe(F,ff);
        end
        for i=2:s(3)
            C = del2(zs(:,:,i));
            set(s1,'Cdata',zb(:,:,i),'Zdata',zb(:,:,i));
            set(s2,'Cdata',C,'Zdata',zs(:,:,i));
            title([num2str((ts(i))/3600,'% 4.1f') ' hours']);
            pause(.1);
            if movie == 1
                saveas(gcf,['fig' num2str(i) '.png']);
            elseif movie == 2 
                ff=getframe;
                F = addframe(F,ff);
            end
        end
        
        if movie==2
            F=close(F);
        end

    case 3
        var1=var{1};
        var2=var{2};
        M=pyth(var1(:,:,1),var2(:,:,1));
        if gridstraight
            p1=pcolor(y',x',flipud(M'));
        else
            p1=pcolor(x,y,M);
        end
        shading flat
        title({[num2str(ts(1)) ' s'];'Press any key to start'});
        if exist('cax','var')
            caxis(cax);
        end
        colorbar;
        hold on
        if exist('thinning','var')
            th=thinning;
        else
            th=1;
        end
        if gridstraight
            vc=M.*sind(180-alfa).*var2(:,:,1)+M.*sind(90-alfa).*var1(:,:,1);
            uc=M.*cosd(180-alfa).*var2(:,:,1)+M.*cosd(90-alfa).*var1(:,:,1);
            q1=quiver(y(1:th:end,1:th:end)',x(1:th:end,1:th:end)',uc(1:th:end,1:th:end,1)',vc(1:th:end,1:th:end,1)','w');
        else
            q1=quiver(x(1:th:end,1:th:end),y(1:th:end,1:th:end),var1(1:th:end,1:th:end,1),var2(1:th:end,1:th:end,1),'w');
        end
        hold off
        pause
        for i=2:s(3)
            M=pyth(var1(:,:,i),var2(:,:,i));
            if gridstraight
                vc=M.*sind(180-alfa).*var2(:,:,i)+M.*sind(90-alfa).*var1(:,:,i);
                uc=M.*cosd(180-alfa).*var2(:,:,i)+M.*cosd(90-alfa).*var1(:,:,i);
                set(q1,'Udata',uc(1:th:end,1:th:end)','Vdata',vc(1:th:end,1:th:end)');
            else
                set(q1,'UData',var1(1:th:end,1:th:end,i),'Vdata',var2(1:th:end,1:th:end,i));
            end
            if gridstraight
                M=flipud(M');
                set(p1,'Cdata',M,'Zdata',M-100000);
            else
                set(p1,'Cdata',M,'Zdata',M-100000);
            end


            title([num2str(ts(i)) ' s']);
            pause(.5);
        end
    case 4
        if iscell (var)
            var=var{1};
        end
        xlims=120:XB.nx+1;
        ylims=1:XB.ny+1;
        s1=surf(XB.x(xlims,ylims),XB.y(xlims,ylims),var(xlims,ylims,1));
        shading flat;
        title({[num2str(ts(1)) ' s'];'Press any key to start'});
        pause;
        for i=1:s(3)
            set(s1,'Zdata',var(xlims,ylims,i),'Cdata',var(xlims,ylims,i));
            title([num2str(ts(i)) ' s']);
            pause(.5);
        end

    case 5
        if strcmpi(var,'oversize')
            fid1=fopen('graindistr.dat','r');
            fid2=fopen('zb.dat','r');
            graindist=zeros(XB.nx+1,XB.ny+1,XB.nd,1);
            zb=zeros(XB.nx+1,XB.ny+1,1);
            zb=fread(fid2,size(XB.x),'double');
            for ii=1:XB.ngd
                for iii=1:XB.nd
                    graindist(:,:,iii,ii,1)=fread(fid1,size(XB.x),'double');
                end
            end
            oversize=1;

        else
            var1=var{1};
            var2=var{2};
            if ndims(var1)==3
                zb=var1;
                graindist=var2;
            else
                zb=var2;
                graindist=var1;
            end
            oversize=0;
        end


        dzg = input('Enter dzg layer thickness (m): ');
        row = input('Enter cross sections rows: ');
        %         row=[1 2 3];
        con=[1:XB.nd];
        con=repmat(con,XB.nx+1,1);

        for ii=1:length(row)
            eval(['X' num2str(ii) '=repmat(XB.x(:,row(ii)),1,XB.nd);']);
            eval(['Y' num2str(ii) '=repmat(zb(:,row(ii),1),1,XB.nd);']);
            eval(['Yn' num2str(ii) '=Y' num2str(ii) '-con.*dzg;']);
            eval(['A' num2str(ii) '=zeros(XB.nx+1,XB.nd);']);
            eval(['A' num2str(ii) '(1:XB.nx+1,1:XB.nd)=graindist(:,row(ii),:,1,1);']);
        end
        if ~exist('cax','var')
            cax=[-1.5 1.5];
        end

        hold on

        for ii=1:length(row)
            eval(['p' num2str(ii) '=pcolor(X' num2str(ii) ',Yn' num2str(ii) ',A' num2str(ii) ');']);
            eval(['set(p' num2str(ii) ',''Zdata'',0*X' num2str(ii) '+ii*10);']);
        end
        shading interp;caxis(cax);colorbar;
        if length(row)>1
            view([0.9848    0.1736    0.0000   -0.5792
                -0.1405    0.7967    0.5878   -0.6220
                -0.1021    0.5789   -0.8090    8.8264
                0         0         0         1.0000]);
            view([ 0.9930    0.0359   -0.1125   -0.4582
                -0.0208    0.9910    0.1323   -0.5513
                -0.1162    0.1291   -0.9848    9.1462
                0         0         0         1.0000]);

        end
        title('Start');pause;

        for i=1:XB.nt;
            if oversize==1
                zb=fread(fid2,size(XB.x),'double');
                for ii=1:XB.ngd
                    for iii=1:XB.nd
                        graindist(:,:,iii,ii,1)=fread(fid1,size(XB.x),'double');
                    end
                end
                it=1;
            else
                it=i;
            end
            for ii=1:length(row)
                eval(['Y' num2str(ii) '=repmat(zb(:,row(ii),it),1,XB.nd);']);
                eval(['Yn' num2str(ii) '=Y' num2str(ii) '-con.*dzg;']);
                eval(['A' num2str(ii) '(1:XB.nx+1,1:XB.nd)=graindist(:,row(ii),:,1,it);']);
                eval(['set(p' num2str(ii) ',''Cdata'',A' num2str(ii) ',''Ydata'',Yn' num2str(ii) ');']);
            end

            %             Y=repmat(zb(:,row,i),1,XB.nd);
            %             Y2=Y-con.*dzg;
            %             A(1:XB.nx+1,1:XB.nd)=graindist(:,row,:,1,i);
            %             set(p1,'CData',A,'Ydata',Y2);
            title(num2str(i));
            pause(.5);
        end
end

end
