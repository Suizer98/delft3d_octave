function frc=delft3dfm_read_bc_file(filename)

frc=[];

fid=fopen(filename);

A = textscan(fid,'%s','delimiter','\n');
A=A{1};
frewind(fid);
nlines=length(A);

% Find forcings
jf=strmatch('[forcing]',lower(A));
nfrc=length(jf);

for ifrc=1:nfrc
    
    frc(ifrc).forcing_file=filename;
    
    i1=jf(ifrc)   + 1;
    if ifrc<nfrc
        i2=jf(ifrc+1) - 1;
    else
        i2=nlines;
    end
    
    iq=0;
    icmp=0;
    ihar=0;
    itim=0;
    
    for ii=i1:i2
        
        if ~isempty(A{ii})
            
            f=textscan(A{ii},'%s','delimiter','=');
            f=f{1};
            
            if length(f)==2
                % Keyword value pair
                switch deblank2(lower(f{1}))
                    case{'name'}
                        frc(ifrc).name=f{2};
                    case{'function'}
                        frc(ifrc).function=f{2};
                    case{'time-interpolation'}
                        frc(ifrc).time_interpolation=f{2};
                    case{'quantity'}
                        iq=iq+1;
                        frc(ifrc).quantity(iq).name=f{2};
                    case{'unit'}
                        frc(ifrc).quantity(iq).unit=f{2};
                end
            elseif length(f)==1
                % Data
                switch lower(frc(ifrc).function)
                    case{'astronomic'}
                        icmp=icmp+1;
                        c=textscan(f{1},'%s%f%f');
                        frc(ifrc).astronomic_component.name{icmp}=c{1}{1};
                        frc(ifrc).astronomic_component.amplitude(icmp)=c{2};
                        frc(ifrc).astronomic_component.phase(icmp)=c{3};
                    case{'harmonic'}
                        ihar=ihar+1;
                        c=textscan(f{1},'%f%f%f');
                        frc(ifrc).harmonic_component.frequency(icmp)=c{1};
                        frc(ifrc).harmonic_component.amplitude(icmp)=c{2};
                        frc(ifrc).harmonic_component.phase(icmp)=c{3};
                    case{'timeseries'}
                        frewind(fid);b=textscan(fid,'%f%f','headerlines',ii-1);
                        unit=frc(ifrc).quantity(1).unit;
                        fff=textscan(unit,'%s','delimiter',' ');
                        dtstr=[fff{1}{3} ' ' fff{1}{4}];
                        dtnum=datenum(dtstr);
                        tunit=fff{1}{1};
                        switch lower(tunit)
                            case{'seconds'}
                                fac=24*60*60;
                            case{'minutes'}
                                fac=24*60;
                            case{'hours'}
                                fac=24;
                            case{'days'}
                                fac=1;
                        end
                        frc(ifrc).time_series.time=dtnum+b{1}/fac;
                        frc(ifrc).time_series.value=b{2};
                        break
                end
            else
                % Empty line
            end
        end
        
    end
    
    v=textscan(frc(ifrc).quantity(2).name,'%s','delimiter',' ');
    frc(ifrc).type=v{1}{1};
    
end

fclose(fid);

