function [boundary,forcingfiles]=delft3dfm_read_ext_file(filename)

boundary=[];
forcingfiles=[];

ifrc=0;

fid=fopen(filename);

A = textscan(fid,'%s','delimiter','\n');
A=A{1};
frewind(fid);
nlines=length(A);

% Find forcings
jf=strmatch('[boundary]',lower(A));
nbnd=length(jf);

for ibnd=1:nbnd
    
    i1=jf(ibnd)   + 1;
    if ibnd<nbnd
        i2=jf(ibnd+1) - 1;
    else
        i2=nlines;
    end
    
    for ii=i1:i2
        
        if ~isempty(A{ii})
            
            f=textscan(A{ii},'%s','delimiter','=');
            f=f{1};
            
            if length(f)==2
                % Keyword value pair
                switch deblank2(lower(f{1}))
                    case{'quantity'}
                        boundary(ibnd).quantity=f{2};
                    case{'locationfile'}
                        boundary(ibnd).locationfile=f{2};
                    case{'forcingfile'}
                        boundary(ibnd).forcingfile=f{2};
                end
            else
                % Empty line
            end
        end
        
    end

    if ifrc>0
        iex=strmatch(lower(boundary(ibnd).forcingfile),lower(forcingfiles),'exact');
        if isempty(iex)
            ifrc=ifrc+1;
            forcingfiles{ifrc}=boundary(ibnd).forcingfile;
        end
    else
        ifrc=1;
        forcingfiles{ifrc}=boundary(ibnd).forcingfile;
    end
    
end

fclose(fid);

