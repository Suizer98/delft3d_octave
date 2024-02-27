function varargout=ddb_wldep(cmd,varargin)
% WLDEP read/write Delft3D field files (e.g. depth files)
%    WLDEP can be used to read and write Delft3D field
%    files used for depth and roughness data.
%
%    DEPTH=WLDEP('read',FILENAME,SIZE)
%    or
%    DEPTH=WLDEP('read',FILENAME,GRID)
%    where GRID was generated by WLGRID.
%
%    STRUCT=WLDEP(...,'multiple') to read multiple fields
%    from the file. The function returns a structure vector
%    with one field: Data.
%    [FLD1,FLD2,...]=WLDEP(...,'multiple') to read multiple
%    fields from the file. The function returns one field
%    to one output argument.
%
%    WLDEP('write',FILENAME,MATRIX)
%    or
%    WLDEP('write',FILENAME,STRUCT)
%    where STRUCT is a structure vector with one field: Data.
%

% (c) copyright, Delft Hydraulics, 2000
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
   if nargout>0,
      varargout=cell(1,nargout);
   end;
   return;
end;

switch cmd,
case 'read',
   if nargout>1, % automatically add 'multiple'
      if nargin==3, % cmd, filename, size
         varargin{3}='multiple';
      end;
   end;
   Dep=Local_depread(varargin{:});
   if isstruct(Dep),
      if length(Dep)<nargout,
         error('Too many output arguments.');
      end;
      if nargout==1
         varargout{1}=Dep;
      else
         for i=1:max(1,nargout),
            varargout{i}=Dep(i).Data;
         end;
      end
   elseif nargout>1,
      error('Too many output arguments.');
   else, % nargout<=1
      varargout={Dep};
   end;
case {'write','append'}
   Out=Local_depwrite(cmd,varargin{:});
   if nargout>0,
      varargout{1}=Out;
   end;
otherwise,
   error('Unknown command');
end;

function DP=Local_depread(filename,dimvar,option)
% DEPREAD reads depth information from a given filename
%    DEPTH=DEPREAD('FILENAME.DEP',SIZE)
%    or
%    DEPTH=DEPREAD('FILENAME.DEP',GRID)
%    where GRID was generated by GRDREAD.
%
%    ...,'multiple') to read multiple fields from the file.

DP=[];

if nargin<2,
   error('No size or grid specified.');
end;

if nargin<3,
   multiple=0;
else,
   multiple=strcmp(option,'multiple');
   if ~multiple,
      warning('Unknown option.');
   end;
end;

if strcmp(filename,'?'),
   [fname,fpath]=uigetfile('*.*','Select depth file');
   if ~ischar(fname),
      return;
   end;
   filename=[fpath,fname];
end;

fid=fopen(filename);
if fid<0,
   error(['Cannot open ',filename,'.']);
end;
if isstruct(dimvar), % new grid format G.X, G.Y, G.Enclosure
   dim=size(dimvar.X)+1;
elseif iscell(dimvar), % old grid format {X Y Enclosure}
   dim=size(dimvar{1})+1;
else
   dim=dimvar;
end;
i=1;
More=1;
while 1,
   %
   % Skip lines starting with *
   %
   line='*';
   cl=0;
   while ~isempty(line) && line(1)=='*'
      if cl>0
         DP(i).Comment{cl,1}=line;
      end
      cl=cl+1;
      currentpoint=ftell(fid);
      line=fgetl(fid);
   end
   fseek(fid,currentpoint,-1);
   %
   [DP(i).Data,NRead]=fscanf(fid,'%f',dim);
   if NRead==0 % accept bagger input files containing 'keyword' on the first line ...
      str=fscanf(fid,['''%[^' char(10) char(13) ''']%['']']);
      if ~isempty(str) && isequal(str(end),'''')
         [DP(i).Data,NRead]=fscanf(fid,'%f',dim);
         DP(i).Keyword=str(1:end-1);
      end
   end
   DP(i).Data=DP(i).Data;
   %
   % Read remainder of last line
   %
   Rem=fgetl(fid);
   if ~ischar(Rem)
      Rem='';
   else
      Rem=deblank(Rem);
   end
   if NRead<prod(dim) 
      if strcmp(Rem,'')
         Str=sprintf('Not enough data in the file for complete field %i (only %i out of %i values).',i,NRead,prod(dim));
         if i==1 % most probably wrong file format
            error(Str);
         else
            warning(Str);
         end
      else
         error(sprintf('Invalid string while reading data: %s',Rem));
      end
   end
   pos=ftell(fid);
   if isempty(fscanf(fid,'%f',1)),
      break; % no more data (at least not readable)
   elseif ~multiple,
      fprintf('More data in the file. Use ''multiple'' option to read all fields.\n');
      break; % don't read data although there seems to be more ...
   end;
   fseek(fid,pos,-1);
   i=i+1;
end;
fclose(fid);
if ~multiple,
   DP=DP.Data;
end;


function OK=Local_depwrite(cmd,filename,DP,varargin)
% DEPWRITE writes depth information to a given filename
%
% Usage: depwrite('filename',Matrix)
%
%    or: depwrite('filename',Struct)
%        where Struct is a structure vector with one field: Data
negate='y';
bndopt='9';

if nargin>3
    for i=1:nargin-3
        switch lower(varargin{i})
            case{'negate'}
                negate=varargin{i+1}(1);
            case{'bndopt'}
                bndopt=varargin{i+1}(1);
        end
    end
end

OK=0;
if isstruct(DP),
   % DP(1:N).Data=Matrix;
   fid=fopen(filename,'w');
   
   for i=1:length(DP),
      if isfield(DP,'Keyword') && ~isempty(DP(i).Keyword)
         fprintf(fid,'''%s''\n',DP(i).Keyword);
      end
      DP(i).Data=DP(i).Data;
      DP(i).Data(isnan(DP(i).Data))=-999;
      
      Frmt=repmat('%15.8f  ',[1 size(DP(i).Data,1)]);
      k=8*12;
      Frmt((k-1):k:length(Frmt))='\';
      Frmt(k:k:length(Frmt))='n';
      Frmt(end-1:end)='\n';
      fprintf(fid,Frmt,DP(i).Data);
   end;
   
   fclose(fid);
   
else
   % DP=Matrix;
   if DP(end,end)~=-999,
       switch lower(negate)
           case {'y'}
               DP=-DP;
       end;
       switch lower(bndopt)
           case {'9'}
               DP=[DP -999*ones(size(DP,1),1); ...
                   -999*ones(1,size(DP,2)+1)];
           case {'b'}
               DP=[DP DP(:,end); ...
                   DP(end,:) DP(end,end)];
       end
   end
   
   DP(isnan(DP))=-999;
   
   switch cmd,
   case{'write'}
      fid=fopen(filename,'w');
   case{'append'}
      fid=fopen(filename,'a');
   end
   
   Frmt=repmat('%15.8f  ',[1 size(DP,1)]);
   k=8*12;
   Frmt((k-1):k:length(Frmt))='\';
   Frmt(k:k:length(Frmt))='n';
   Frmt(end-1:end)='\n';
   fprintf(fid,Frmt,DP);
   
   fclose(fid);
end;
OK=1;
