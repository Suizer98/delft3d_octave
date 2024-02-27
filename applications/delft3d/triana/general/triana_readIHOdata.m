function s = triana_readIHOdata(s);

stats = ncread(s.meas.file,'stations');
Y = ncread(s.meas.file,'lat');
X = ncread(s.meas.file,'lon');
A = ncread(s.meas.file,'amplitude');
G = ncread(s.meas.file,'phase');
Cmp = char2cell(ncread(s.meas.file,'components'));

% convert locations of IHO data
if s.model.epsg ~= 4326
    [X Y] =convertCoordinates(X,Y,'CS1.code',4326,'CS2.code',s.model.epsg);
end

if isfield(s.model,'epsgTranslation')
    X = X+s.model.epsgTranslation(1);
    Y = Y+s.model.epsgTranslation(2);
end
   

if isfield(s.meas,'data')    
   startID = length(s.meas.data)+1;
   if size(s.meas.data,2)>1
       s.meas.data = s.meas.data';
   end
else    
   startID = 1 ;
end

for ss = startID:length(stats)
    s.meas.data(ss,1).name = stats(ss,:);
    s.meas.data(ss,1).X = X(ss,:)';
    s.meas.data(ss,1).Y= Y(ss,:)';
    s.meas.data(ss,1).A = A(ss,:);
    s.meas.data(ss,1).G = G(ss,:)';
    s.meas.data(ss,1).Cmp = Cmp;
end
