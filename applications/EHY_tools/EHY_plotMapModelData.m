function varargout = EHY_plotMapModelData(gridInfo,values,varargin)
%% varargout = EHY_plotMapModelData(gridInfo,values,varargin)
% Create top views using QuickPlot / d3d_qp functionalities (for
% 'DFM'-runs) or pcolor (for 'D3D'-runs)
%
% This function only plots the pcolor / patch part,
% so you can easily add your own colorbar, xlims, etc.
%
% gridInfo     :   struct (with fields face_nodes_x and face_nodes_x) obtained with:
%                  gridInfo = EHY_getGridInfo(filename,{'face_nodes_xy'});
% values        :   matrix: Data in net elements (cell centers)
%
% Example1: EHY_plotMapModelData
% Example2: EHY_plotMapModelData(gridInfo,values)
%             with gridInfo = EHY_getGridInfo(outputfile,{'face_nodes_xy'});
%                  Data     = EHY_getMapModelData(outputfile, ... );
%                  values    = Data.val(1,:);
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018
%
%% Settings
OPT.linestyle = 'none'; % other options: '-'
OPT.edgecolor = 'k';
OPT.facecolor = 'flat'; % 'flat' or 'interp'/'continuous shades'
OPT.linewidth = 0.5;
OPT.t = []; % time index, needed for plotting data along xy-trajectory
OPT.contour = []; % array with levels or number of lines (only for structured data)
OPT.contourtext = 'off';

% if pairs were given as input OPT
if ~isempty(varargin)
    if mod(length(varargin),2)==0
        OPT = setproperty(OPT,varargin);
    else
        error('Additional input arguments must be given in pairs.')
    end
end

if isempty(OPT.linestyle); OPT.linestyle='none'; end
if ~isnumeric(OPT.t); OPT.t = str2num(OPT.t); end

%% check input
if ~all([exist('gridInfo','var') exist('values','var')])
    % no input, start interactive script
    EHY_plotMapModelData_interactive
    return
end

%% structured or unstructured grid
if isstruct(gridInfo)
    if all(isfield(gridInfo,{'face_nodes_x','face_nodes_y'})) || all(isfield(gridInfo,{'face_nodes','Xcor','Ycor'}))
        modelType= 'dfm';
    elseif (isfield(gridInfo,'Xcor') && isfield(gridInfo,'Ycor')) || (isfield(gridInfo,'Xcen') && isfield(gridInfo,'Ycen'))
        modelType= 'd3d';
    else
        error('Something wrong with first input argument')
    end
else
    error('Something wrong with first input argument');
end

if isempty(values)
    error('No values to plot')
elseif size(values,1)==1
    values = squeeze(values);
end

%% check for unstructured grids (modelType = 'dfm')
if strcmp(modelType,'dfm') && strcmpi(OPT.facecolor,'flat')
    if size(gridInfo.face_nodes_x,2)~=numel(values)
        error('size(gridInfo.face_nodes_x,2) should be the same as  prod(size(values))')
    end
end

%% check for structured grids (modelType = 'd3d')
if strcmp(modelType,'d3d')
    
    if ~all(isfield(gridInfo,{'Xcor','Ycor'})) && all(isfield(gridInfo,{'Xcen','Ycen'}))
        if ~all(size(gridInfo.Xcen)==size(gridInfo.Ycen))
            error('size(gridInfo.Xcen) and size(gridInfo.Ycen) should be the same')
        end
        gridInfo.Xcor = center2corner(gridInfo.Xcen);
        gridInfo.Ycor = center2corner(gridInfo.Ycen);
    end
    
    if ndims(gridInfo.Ycor) - ndims(gridInfo.Xcor) == 1
        % probably data along xy-trajectory
        if isempty(OPT.t)
            error('You need to provide variable ''t'' to plot data along xy-trajectory');
        else
            % -> [cells,layers]
            gridInfo.Xcor = reshape(gridInfo.Xcor,length(gridInfo.Xcor),1);
            gridInfo.Xcor = repmat(gridInfo.Xcor,1,size(gridInfo.Ycor,3));
            gridInfo.Ycor = squeeze(gridInfo.Ycor(OPT.t,:,:));
            
            % add dummy values for plotting with pcolor
            for ii = 1:size(gridInfo.Ycor,1)
                gridInfo2.Xcor(2*ii-1,:) = gridInfo.Xcor(ii,:);
                gridInfo2.Xcor(2*ii  ,:) = gridInfo.Xcor(ii+1,:);
                gridInfo2.Ycor(2*ii-1,:) = gridInfo.Ycor(ii,:);
                gridInfo2.Ycor(2*ii  ,:) = gridInfo.Ycor(ii,:);
                values2(2*ii-1,:) = values(ii,:);
                values2(2*ii  ,:) = values(ii,:);
            end
            values2(end,:) = [];
            gridInfo = gridInfo2;
            values = values2;
        end
    end
    
    if ~all(size(gridInfo.Xcor)==size(gridInfo.Ycor))
        error('size(gridInfo.Xcor) and size(gridInfo.Ycor) should be the same')
    end
    
    if all(size(gridInfo.Xcor)-size(values) == [1 1])
        % this is needed for info in cell center, like Delft3d 4 output
        %but we need values without dummy's for 3D
        values_raw=values;
        values(end+1,:) = NaN;
        values(:,end+1) = NaN;
    elseif all(size(gridInfo.Xcor)-size(values) == [0 0])
        error('Are these xy-corners that you provided? Seems like xy-centers .. ')
    else
        error('size(gridInfo.Xcor/Ycor) should be one size bigger than size(values)')
    end
    
end

%% plot figure
switch modelType
    case 'dfm'
        
        switch lower(OPT.facecolor)
            case 'flat'
                % don't plot NaN's (gives problems in older MATLAB versions)
                nanInd = isnan(values);
                values(nanInd) = [];
                gridInfo.face_nodes_x(:,nanInd) = [];
                gridInfo.face_nodes_y(:,nanInd) = [];
                if isfield(gridInfo,'Zcen') % use center bed level for 3D-plot ('tiles' plot / tegeltjes aanpak a la morphology)
                    gridInfo.face_nodes_z = repmat(reshape(gridInfo.Zcen,1,[]),size(gridInfo.face_nodes_x,1),1);
                end
                if isfield(gridInfo,'face_nodes_z')
                    gridInfo.face_nodes_z(:,nanInd) = [];
                end
                
                nnodes = size(gridInfo.face_nodes_x,1) - sum(isnan(gridInfo.face_nodes_x));
                unodes = unique(nnodes);
                unodes(unodes==0) = [];
                
                for i = 1:length(unodes)
                    nr = unodes(i);
                    poly_n = find(nnodes==nr);
                    npoly = length(poly_n);
                    tvertex = nr*npoly;
                    if isfield(gridInfo,'face_nodes_z') 
                        XYvertex = NaN(tvertex,3); % actually XYZvertex
                    else
                        XYvertex = NaN(tvertex,2);
                    end
                    Vpatch = NaN(npoly,1);
                    offset = 0;
                    for ip = 1:npoly
                        if isfield(gridInfo,'face_nodes_z') 
                            XYvertex(offset+(1:nr),:) = [gridInfo.face_nodes_x(1:nr,poly_n(ip)) gridInfo.face_nodes_y(1:nr,poly_n(ip)) gridInfo.face_nodes_z(1:nr,poly_n(ip))];
                        else
                            XYvertex(offset+(1:nr),:) = [gridInfo.face_nodes_x(1:nr,poly_n(ip)) gridInfo.face_nodes_y(1:nr,poly_n(ip))];
                        end
                        offset = offset+nr;
                        Vpatch(ip) = values(poly_n(ip));
                    end
                    
                    hPatch(i,1) = patch('vertices',XYvertex, ...
                        'faces',reshape(1:tvertex,[nr npoly])', ...
                        'facevertexcdata',Vpatch, ...
                        'marker','none',...
                        'edgecolor',OPT.edgecolor,...
                        'linestyle',OPT.linestyle,...
                        'faceColor','flat',...
                        'LineWidth',OPT.linewidth);
                end
                
            case {'interp','continuous shades'}
                if strcmpi(OPT.linestyle,'none')
                    OPT.edgecolor = 'none';
                end
                
                % use QUICKPLOT functionality to create dual grid
                data.FaceNodeConnect = gridInfo.face_nodes';
                data.X = gridInfo.Xcor;
                data.Y = gridInfo.Ycor;
                data = dual_ugrid(data,0);
                
                FaceNodeConnect = data.FaceNodeConnect;
                XY = [data.X data.Y];
                values = reshape(values,[],1);
                
                nNodes = sum(~isnan(FaceNodeConnect),2);
                uNodes = unique(nNodes);
                for i = length(uNodes):-1:1
                    I = nNodes == uNodes(i);
                    hPatch(i,1) = patch(...
                        'vertices',XY, ...
                        'faces',FaceNodeConnect(I,1:uNodes(i)), ...
                        'facevertexcdata',values, ...
                        'facecolor','interp', ...
                        'edgecolor',OPT.edgecolor);
                end
        end
        
        if nargout==1
            varargout{1}=hPatch;
        end
        
    case 'd3d'
        if isfield(gridInfo,'Zcen')==0 && isfield(gridInfo,'Zcor')==0 %2D
            hPcolor = pcolor(gridInfo.Xcor,gridInfo.Ycor,values);
            set(hPcolor,'linestyle',OPT.linestyle,'edgecolor',OPT.edgecolor,'facecolor',OPT.facecolor);
            if ~isempty(OPT.contour)
                [cCon,hCon] = contour(gridInfo.Xcor,gridInfo.Ycor,values,OPT.contour,'LineStyle','-',...
                    'LineColor',OPT.edgecolor,'LineWidth',OPT.linewidth,'ShowText',OPT.contourtext);
            else
                cCon = []; hCon = [];
            end

            if nargout==1
                varargout{1}=hPcolor;
            elseif nargout==3
                varargout{1}=hPcolor;
                varargout{2}=cCon;
                varargout{3}=hCon;
            end
        else %3D
            switch lower(OPT.facecolor)
                case 'flat'
                    values=values_raw(:);
                    
                    gridInfo.face_nodes_x=face_from_cor(gridInfo.Xcor);
                    gridInfo.face_nodes_y=face_from_cor(gridInfo.Ycor);
                    if isfield(gridInfo,'Zcor')
                        gridInfo.face_nodes_z=face_from_cor(gridInfo.Zcor);
                    else %zcen
                        gridInfo.face_nodes_z=repmat(reshape(gridInfo.Zcen,1,[]),size(gridInfo.face_nodes_x,1),1);
                    end
                    
                    %The code from here down is similar to the one in FM. It should be made a function! 
                    
                    % don't plot NaN's (gives problems in older MATLAB versions)
                    nanInd = isnan(values);
                    values(nanInd) = [];
                    gridInfo.face_nodes_x(:,nanInd) = [];
                    gridInfo.face_nodes_y(:,nanInd) = [];
                    gridInfo.face_nodes_z(:,nanInd) = [];

                    nnodes = size(gridInfo.face_nodes_x,1) - sum(isnan(gridInfo.face_nodes_x));
                    unodes = unique(nnodes);
                    unodes(unodes==0) = [];

                    for i = 1:length(unodes)
                        nr = unodes(i);
                        poly_n = find(nnodes==nr);
                        npoly = length(poly_n);
                        tvertex = nr*npoly;
                        if isfield(gridInfo,'face_nodes_z') 
                            XYvertex = NaN(tvertex,3); % actually XYZvertex
                        else
                            XYvertex = NaN(tvertex,2);
                        end
                        Vpatch = NaN(npoly,1);
                        offset = 0;
                        for ip = 1:npoly
%                             if isfield(gridInfo,'face_nodes_z') 
                                XYvertex(offset+(1:nr),:) = [gridInfo.face_nodes_x(1:nr,poly_n(ip)) gridInfo.face_nodes_y(1:nr,poly_n(ip)) gridInfo.face_nodes_z(1:nr,poly_n(ip))];
%                             else
%                                 XYvertex(offset+(1:nr),:) = [gridInfo.face_nodes_x(1:nr,poly_n(ip)) gridInfo.face_nodes_y(1:nr,poly_n(ip))];
%                             end
                            offset = offset+nr;
                            Vpatch(ip) = values(poly_n(ip));
                        end

                        hPatch(i,1) = patch('vertices',XYvertex, ...
                            'faces',reshape(1:tvertex,[nr npoly])', ...
                            'facevertexcdata',Vpatch, ...
                            'marker','none',...
                            'edgecolor',OPT.edgecolor,...
                            'linestyle',OPT.linestyle,...
                            'faceColor','flat',...
                            'LineWidth',OPT.linewidth);
                    end %i
                otherwise
                    error('This needs to be implemented')
            end %switch
        end %2D,3D
end

end %function

%%
%% FUNCTION
%%


function [face_nodes]=face_from_cor(cor)

npmx=size(cor,2);
npmy=size(cor,1);

nel=(npmx-1)*(npmy-1);
nnel=4;

face_nodes=NaN(nel,nnel);

x_m=cor(:);

c1=0;
idx_vert=reshape(1:1:npmx*npmy,npmy,npmx);

for kx=1:npmx-1
    for ky=1:npmy-1
        idx_xl=idx_vert(ky,kx);
        idx_xu=idx_vert(ky,kx+1);
        idx_yl=idx_vert(ky+1,kx);
        idx_yu=idx_vert(ky+1,kx+1);
        c1=c1+1;
        face_nodes(c1,:)=x_m([idx_xl,idx_xu,idx_yu,idx_yl]);
    end %ky
end %kx

face_nodes=face_nodes';
end %function