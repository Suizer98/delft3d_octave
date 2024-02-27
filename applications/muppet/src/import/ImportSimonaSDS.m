function DataProperties=ImportSimonaSDS(DataProperties,nr)

switch lower(DataProperties(nr).Parameter)
    case{'stations'}

        filename=[DataProperties(nr).PathName DataProperties(nr).FileName];

        DataProperties(nr).Type='Annotation';

        fid=qpfopen(filename);

        st=qpread(fid,'station','griddata');

        for i=1:length(st.X)

            DataProperties(nr).x(i)=st.X(i);
            DataProperties(nr).y(i)=st.Y(i);
            DataProperties(nr).z(i)=0;
            DataProperties(nr).Annotation{i}=st.Val{i};
            DataProperties(nr).Rotation(i)=0;
            DataProperties(nr).Curvature(i)=0;
        end

        DataProperties(i).TC='c';
    
    otherwise

        FileInfo=qpfopen([DataProperties(nr).PathName DataProperties(nr).FileName]);

        [DataFields,Dims,NVal]=qpread(FileInfo);
        DataProps=qpread(FileInfo);
        NrParameter=strmatch(DataProperties(nr).Parameter,DataFields,'exact');
        Dims=Dims(NrParameter,:);
        Size=qpread(FileInfo,DataFields{NrParameter},'size');

        switch(lower(DataProperties(nr).Parameter))
            case{'stations','depth grid','bed level'}
                Times=floor(now);
                DataProperties(nr).DateTime=floor(now);
            otherwise
                Times=qpread(FileInfo,DataProperties(nr).Parameter,'Times',0);
        end

        for i=1:length(DataProperties(nr).Parameter)
            if strcmpi(DataProperties(nr).Parameter,'roughness chezy c')
                NVal(i)=1;
            end
        end

        MorphTimes=[];

        if DataProperties(nr).DateTime>0
            if Size(1)>1
                ITime=find(Times>DataProperties(nr).DateTime-1.0e-6 & Times<DataProperties(nr).DateTime+1.0e-6);
            else
                ITime=1;
            end
        else
            ITime=0;
        end
        if ~isempty(ITime>1)
            ITime=ITime(1);
        end

        if DataProperties(nr).Block>0
            ITime=DataProperties(nr).Block;
            DataProperties(nr).DateTime=Times(ITime);
        end

        NrStation=0;
        Stations=qpread(FileInfo,DataProperties(nr).Parameter,'Stations');
        if ~isempty(Stations)
            NrStation=strmatch(DataProperties(nr).Station,Stations,'exact');
        end

        if DataProperties(nr).M1==0
            M1=1;
            M2=Size(3);
            MStep=1;
        elseif DataProperties(nr).M2>DataProperties(nr).M1
            M1=DataProperties(nr).M1;
            M2=DataProperties(nr).M2;
            MStep=DataProperties(nr).MStep;
        else
            M1=DataProperties(nr).M1;
            M2=DataProperties(nr).M2;
            MStep=1;
        end

        if DataProperties(nr).N1==0
            N1=1;
            N2=Size(4);
            NStep=1;
        elseif DataProperties(nr).N2>DataProperties(nr).N1
            N1=DataProperties(nr).N1;
            N2=DataProperties(nr).N2;
            NStep=DataProperties(nr).NStep;
        else
            N1=DataProperties(nr).N1;
            N2=DataProperties(nr).N2;
            NStep=1;
        end

        if isempty(M1)
            M1=0;
        end
        if isempty(M2)
            M2=0;
        end
        if isempty(N1)
            N1=0;
        end
        if isempty(N2)
            N2=0;
        end

        if DataProperties(nr).K1==0 && Size(5)>0
            K1=1;
            K2=Size(5);
        else
            K1=DataProperties(nr).K1;
            K2=DataProperties(nr).K2;
        end

        NrArg=0;

        if NrStation==0
            if Dims(1)>0
                NrArg=NrArg+1;Arg{NrArg}=ITime;
            end
            NrArg=NrArg+1;Arg{NrArg}=M1:M2;
            NrArg=NrArg+1;Arg{NrArg}=N1:N2;
            if Dims(5)>0
                NrArg=NrArg+1;Arg{NrArg}=K1:K2;
            end
        else
            NrArg=NrArg+1;Arg{NrArg}=ITime;
            NrArg=NrArg+1;Arg{NrArg}=NrStation;
            if Size(5)>1
                NrArg=NrArg+1;Arg{NrArg}=K1:K2;
            end
        end

        pars=qpread(FileInfo);
        for ii=1:length(pars)
            if strcmpi(pars(ii).Name,DataProperties(nr).Parameter);
                s=pars(ii);
            end
        end

        switch lower(DataProperties(nr).Component),
            case{'m-component','n-component'}
                s.MNK=2;
        end

        switch NrArg,
            case{1}
                Data=qpread(FileInfo,s,'griddata',Arg{1});
            case{2}
                Data=qpread(FileInfo,s,'griddata',Arg{1},Arg{2});
            case{3}
                Data=qpread(FileInfo,s,'griddata',Arg{1},Arg{2},Arg{3});
            case{4}
                Data=qpread(FileInfo,s,'griddata',Arg{1},Arg{2},Arg{3},Arg{4});
            case{5}
                Data=qpread(FileInfo,s,'griddata',Arg{1},Arg{2},Arg{3},Arg{4},Arg{5});
            case{6}
                Data=qpread(FileInfo,s,'griddata',Arg{1},Arg{2},Arg{3},Arg{4},Arg{5},Arg{6});
        end
       
        if DataProperties(nr).DateTime~=0% & M2>M1 & N2>N1
            Data.X=Data.X(1:MStep:end,1:NStep:end);
            Data.Y=Data.Y(1:MStep:end,1:NStep:end);
            if isfield(Data,'Z')
                Data.Z=Data.Z(1:MStep:end,1:NStep:end,:);
            end
            if isfield(Data,'Val')
                Data.Val=Data.Val(1:MStep:end,1:NStep:end,:);
            end
            if isfield(Data,'XComp')
                Data.XComp=Data.XComp(1:MStep:end,1:NStep:end,:);
            end
            if isfield(Data,'YComp')
                Data.YComp=Data.YComp(1:MStep:end,1:NStep:end,:);
            end
        end

        if isfield(Data,'Val')
            Val=Data.Val;
        else
            if NVal(NrParameter)>1
                switch lower(DataProperties(nr).Component),
                    case('magnitude')
                        Val=sqrt(Data.XComp.^2+Data.YComp.^2);
                    case('angle (radians)')
                        Val=mod(0.5*pi-atan2(Data.YComp,Data.XComp),2*pi);
                    case('angle (degrees)')
                        Val=mod(0.5*pi-atan2(Data.YComp,Data.XComp),2*pi)*180/pi;
                    case('m-component')
                        Val=Data.XComp;
                    case('n-component')
                        Val=Data.YComp;
                    case({'u-component','x-component'})
                        Val=Data.XComp;
                    case({'v-component','y-component'})
                        Val=Data.YComp;
                end
            end
        end

        x=0;
        y=0;
        z=0;
        zz=0;
        u=0;
        v=0;
        if DataProperties(nr).DateTime==0
            DataProperties(nr).Type='TimeSeries';
            if DataProperties(nr).T2>DataProperties(nr).T1
                x=Data.Time(DataProperties(nr).T1:DataProperties(nr).TStep:DataProperties(nr).T2);
                y=Val(DataProperties(nr).T1:DataProperties(nr).TStep:DataProperties(nr).T2);
            else
                x=Data.Time;
                y=Val;
            end
            
            if ndims(y)>2
                y=squeeze(y(:,:,K1));
            end
        else
            if M2>M1 && N2>N1
                % 2D
                if isfield(Data,'XDam')==0
                    x=Data.X;
                    y=Data.Y;
                else
                    DataProperties(nr).XDam=Data.XDam;
                    DataProperties(nr).YDam=Data.YDam;
                end
                if strcmp(DataProperties(nr).Component,'vector')
                    % Vector
                    DataProperties(nr).Type='2DVector';
                    u=Data.XComp;
                    v=Data.YComp;
                    z=sqrt(u.^2+v.^2);
                else
                    if NVal(NrParameter)>0
                        % Scalar
                        DataProperties(nr).Type='2DScalar';
                        if DataProps(NrParameter).UseGrid==2
                            a=1;
                        else
                            a=0;
                        end
                        if (a==1)
                            % Interpolate to cell corners
                            Grd=qpread(FileInfo,'depth grid','griddata',M1:M2,N1:N2);
                            x=squeeze(Grd.X(1:MStep:end,1:NStep:end));
                            y=squeeze(Grd.Y(1:MStep:end,1:NStep:end));

                            z0=squeeze(Val);
                            z1=z0(1:end-1,1:end-1);
                            z2=z0(2:end,1:end-1);
                            z3=z0(2:end,2:end);
                            z4=z0(1:end-1,2:end);
                            z1fin=isfinite(z1);
                            z2fin=isfinite(z2);
                            z3fin=isfinite(z3);
                            z4fin=isfinite(z4);
                            z1(isnan(z1))=-999;
                            z2(isnan(z2))=-999;
                            z3(isnan(z3))=-999;
                            z4(isnan(z4))=-999;
                            zfin=z1fin+z2fin+z3fin+z4fin;
                            z5=(z1.*z1fin+z2.*z2fin+z3.*z3fin+z4.*z4fin)./max(1e-6,zfin);
                            z5(zfin==0)=NaN;
                            z=zeros(size(z0));
                            z(z==0)=NaN;
                            z(1:end-1,1:end-1)=z5;
                            zz=z0;
                        else
                            z=Val;
                            zz=Val;
                        end
                    else
                        DataProperties(nr).Type='Grid';
                        x=Data.X;
                        y=Data.Y;
                        if isfield(Data,'XDam')
                            DataProperties(nr).XDam=Data.XDam;
                            DataProperties(nr).YDam=Data.YDam;
                        end
                    end
                end
            elseif ((M2>M1 && N2==N1) || (M2==M1 && N2>N1))
                % CrossSection

                switch(lower(DataProperties(nr).XCoordinate)),
                    case{'x'}
                        x=squeeze(Data.X);
                    case{'y'}
                        x=squeeze(Data.Y);
                    case{'pathdistance'}
                        x=pathdistance(squeeze(Data.X),squeeze(Data.Y));
                    case{'revpathdistance'}
                        x=pathdistance(squeeze(Data.X),squeeze(Data.Y));
                        x=x(end:-1:1);
                end

                if NVal(NrParameter)==0 && K1==1 && K2==2
                    % Grid line
                    x=squeeze(Data.X);
                    y=squeeze(Data.Y);
                    DataProperties(nr).Type='XYSeries';
                elseif K1==K2
                    % 2D
                    DataProperties(nr).Type='XYSeries';
                    y=Val;
                else
                    % 3D
                    if strcmp(DataProperties(nr).Component,'vector')
                        % Vector
                        DataProperties(nr).Type='3DCrossSectionVector';
                        y=Data.Z;
                        for i=2:size(squeeze(y),2);
                            x(:,i)=x(:,1);
                        end
                        x=squeeze(x);
                        y=squeeze(y);
                        u=Data.XComp;
                        v=Data.ZComp;

                    elseif NVal(NrParameter)>0
                        % Scalar
                        DataProperties(nr).Type='3DCrossSectionScalar';
                        switch FileInfo.SubType,
                            case{'Delft3D-trim','Delft3D-com'}
                                Grd=qpread(FileInfo,'hydrodynamic grid','griddata',ITime,M1:M2,N1:N2,K1:K2+1);
                                Grd.Z=Grd.Z(1:MStep:end,1:NStep:end,:);
                                %                     case{'Delft3D-waq-map'}
                                %                         Grd=qpread(FileInfo,'aggregated grid','griddata',M1:M2,N1:N2);
                                %                         Grd.Z=Grd.Z(1:MStep:end,1:NStep:end,:);
                        end
                        y=squeeze(Grd.Z);
                        for i=2:size(y,2);
                            x(:,i)=x(:,1);
                        end
                        z1=Val(:,1:end-1);
                        z2=Val(:,2:end);
                        z3=0.5*(z1+z2);
                        z=zeros(size(x));
                        z(z==0.0)=NaN;
                        z(:,2:end-1)=z3;
                        z(:,1)=z(:,2);
                        z(:,end)=z(:,end-1);
                        zz=Val;
                    else
                        % Grid
                        DataProperties(nr).Type='3DCrossSectionGrid';
                        x=Data.X;
                        y=Data.Z;
                        for i=2:size(y,2);
                            x(:,i)=x(:,1);
                        end
                    end
                end
            else
                % Profile
                DataProperties(nr).Type='XYSeries';
                x=Val;
                y=Data.Z;
            end
        end

        DataProperties(nr).x=squeeze(x);
        DataProperties(nr).y=squeeze(y);
        DataProperties(nr).z=squeeze(z);
        DataProperties(nr).zz=squeeze(zz);
        DataProperties(nr).u=squeeze(u);
        DataProperties(nr).v=squeeze(v);

        switch(lower(DataProperties(nr).Parameter))
            case{'stations','depth grid'}
                DataProperties(nr).DateTime=0;
        end
        
        if DataProperties(nr).DateTime==0 || Size(1)<2
            DataProperties(nr).TC='c';
        else
            DataProperties(nr).TC='t';
            DataProperties(nr).AvailableTimes=Times;
            DataProperties(nr).AvailableMorphTimes=MorphTimes;
        end

        clear x y z u v z0 z1 z2 z3 z4 z5 zfin z1fin z2fin z3fin z4fin Data

end
