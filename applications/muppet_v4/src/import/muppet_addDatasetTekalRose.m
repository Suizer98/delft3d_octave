function varargout=muppet_addDatasetTekalRose(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                parameter=[];
                if length(varargin)==3
                    parameter=varargin{ii+1};
                end
                dataset=read(dataset,parameter);
                varargout{1}=dataset;                
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
            case{'gettimes'}
                varargout{1}=[];
        end
    end
end

%%
function dataset=read(dataset,varargin)

try
    fid=tekal('open',dataset.filename,'loaddata');
catch
    disp([dataset.filename ' does not appear to be a valid tekal file!']);    
end

dataset.fid=fid;
[pathstr,name,ext]=fileparts(dataset.filename);
dataset.name=name;
% Blocks
nblocks=length(fid.Field);
dataset.nrblocks=nblocks;
for iblock=1:nblocks
    dataset.blocks{iblock}=fid.Field(iblock).Name;
end
if isempty(dataset.block)
    dataset.block=dataset.blocks{1};
end

% par=[];
% par=muppet_setDefaultParameterProperties(par);
% par.name='Area';
% par.size=[0 0 0 0 0];
% dataset.parameters(1).parameter=par;
% 
% par=[];
% par=muppet_setDefaultParameterProperties(par);
% par.name='Volume';
% par.size=[0 0 0 0 0];
% dataset.parameters(2).parameter=par;
% 
% par=[];
% par=muppet_setDefaultParameterProperties(par);
% par.name='Average';
% par.size=[0 0 0 0 0];
% dataset.parameters(3).parameter=par;

% x and y
dataset.selectcoordinates=0;

dataset.tekaltype='rose';

%%
function dataset=import(dataset)

fid=dataset.fid;

iblock=strmatch(lower(dataset.block),lower(dataset.blocks),'exact');

dataset.x=fid.Field(iblock).Data(:,1);
dataset.z=fid.Field(iblock).Data(:,2:end);
for ii=1:length(fid.Field(iblock).ColLabels)-1
    dataset.class{ii}=fid.Field(iblock).ColLabels{ii+1};
end

% switch fid.Field(iblock).DataTp
%     case{'annotation'}
%         switch lower(dataset.parameter)
%             case{'area'}
%                 dataset.z=fid.Field(iblock).Data{1}(:,2);
%             case{'volume'}
%                 dataset.z=fid.Field(iblock).Data{1}(:,3);
%             case{'average'}
%                 dataset.z=fid.Field(iblock).Data{1}(:,4);
%         end
%         dataset.average=fid.Field(iblock).Data{1}(:,4);
%     otherwise
%         switch lower(dataset.parameter)
%             case{'area'}
%                 dataset.z=fid.Field(iblock).Data(:,2);
%             case{'volume'}
%                 dataset.z=fid.Field(iblock).Data(:,3);
%             case{'average'}
%                 dataset.z=fid.Field(iblock).Data(:,4);
%         end
%         dataset.average=fid.Field(iblock).Data(:,4);
% end
% 
% dataset.x=[1e9 -1e9];
% dataset.y=[1e9 -1e9];
% 
% tekpol=tekal('read',dataset.polygonfile,'loaddata');
% for ipol=1:length(tekpol.Field)
%     dataset.polygon(ipol).name=tekpol.Field(ipol).Name;
%     dataset.polygon(ipol).x=tekpol.Field(ipol).Data(:,1);
%     dataset.polygon(ipol).y=tekpol.Field(ipol).Data(:,2);
%     dataset.x(1)=min(min(dataset.polygon(ipol).x),dataset.x(1));
%     dataset.x(2)=max(max(dataset.polygon(ipol).x),dataset.x(2));
%     dataset.y(1)=min(min(dataset.polygon(ipol).y),dataset.y(1));
%     dataset.y(2)=max(max(dataset.polygon(ipol).y),dataset.y(2));
% end

dataset.type='rose';
