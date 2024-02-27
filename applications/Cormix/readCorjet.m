function out = readCorjet(fileInp)
%  Reads the contents of a corjet (mixzone) outputfile and return the contents in a structure
%  (First attampt, not fully completed yet)

%% Initialise
out.Raw     = {};
out.Ambiant = [];
out.Data    = [];

%% Open outputfile, read line iand but in raw as textstrings
fid = fopen(fileInp);
while ~feof(fid)
    tline          = fgetl(fid);
    out.Raw{end+1} = tline;
end
fclose(fid);

%  Remove '|' chararacter for easy reading of series later
for i_line = 1: length(out.Raw) out.Raw{i_line} = strrep(out.Raw{i_line},'|',' '); end

%% Get the ambiant conditions
no_lines = length(out.Raw);
for i_line = 1: no_lines
    if ~isempty(strfind(out.Raw{i_line},'LEV='))
        separator = strfind(out.Raw{i_line},'=');
        lev_no    = sscanf(out.Raw{i_line}(separator(1) + 1:end),'%i');
        out.Ambiant(lev_no).Z    = sscanf(out.Raw{i_line}(separator(2) + 1:end),'%f');
        out.Ambiant(lev_no).RhoA = sscanf(out.Raw{i_line}(separator(3) + 1:end),'%f');
        out.Ambiant(lev_no).UA   = sscanf(out.Raw{i_line}(separator(4) + 1:end),'%f');
        out.Ambiant(lev_no).TAU  = sscanf(out.Raw{i_line}(separator(5) + 1:end),'%f');
    end
end

%% Get the discharge conditions
param_dis = {'D0' 'H0' 'RHO0' 'U0' 'THETA0' 'SIGMA0'};
for i_line = 1:no_lines
    for i_param = 1: length(param_dis)
       index = strfind(out.Raw{i_line},param_dis{i_param});
       if ~isempty(index)
           out.Dis.(param_dis{i_param}) = sscanf(out.Raw{i_line}(index + length(param_dis{i_param}) + 1:end),'%f');
       end
    end
end

%% Finally, read the track (not very elegant)
for i_line = 1: no_lines
    try
        values = sscanf(out.Raw{i_line},'%f');
        out.Data(end+1,1:11) = values;
    end
end







