function ECO=read_eco_input(fname)

ECO=struct;
fid=fopen(fname,'r');
k=0;
nrSpecies = 0;
while ~feof(fid)
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        if(findstr(tx0,'*'))
            nm = findstr(lower(tx0),'* species name');
            if ~isempty(nm)
                nrSpecies = nrSpecies+1;
                id1 = findstr(tx0(min(15,length(tx0)):end),':');
                id2 = find(~isspace(tx0(min(15,length(tx0)):end))==1);
                id3 = setdiff(id2,id1);
                if ~isempty(id3)
                    ECO(nrSpecies).name = deblank(tx0(id3(1)+14:end));
                else
                    ECO(nrSpecies).name = ['species ',num2str(nrSpecies)];
                end
            end
        else
            v0=strread(tx0,'%s','delimiter','=');
            if ~isempty(str2num(v0{1})) && length(v0)==1                   % if in the input file, there is only a number in a row,
                                                                           % this part will function.         
                n=n+1;
                val=getfield(ECO,deblank(ActiveField));
                val(n)=str2num(v0{1});
                ECO(nrSpecies).(deblank(ActiveField)) = val;
            elseif isempty(str2num(v0{1})) && length(v0)==1                % if in the input file, there is only a number in a row,
                                                                           % this part will function.   
            else
                if length(v0)==2
                    if ~isempty(str2num(v0{2}))
                        %ECO(nrSpecies)=setfield(ECO(nrSpecies),v0{1},str2num(v0{2}));
                        ECO(nrSpecies).(deblank(v0{1})) = str2num(v0{2});
                    end
                end
            end
        end
    end
end
fclose(fid);
