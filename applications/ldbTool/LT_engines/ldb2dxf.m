function ldb2dxf(varargin)

%LDB2DXF converter
%
% LDB2DXF
%
% Optional: LDB2DXF('LDBFile.ldb','DXFFile.dxf');
% or:       LDB2DXF(ldb);
%           with ldb a nx2 matrix.
    
a=which('dxf.m');

if isempty(a)
    wlsettings;
end

if nargin==0
    [x,y]=landboundary('read');
    
    [name,pat]=uiputfile('*.dxf','Save DXF-file');
    if name==0
        return
    end
    
    figure
    h=plot(x,y);
    dxf('save',gca,[pat name]);
    return
end

if nargin==2
        [x,y]=landboundary('read',varargin{1});
    
  
    figure
    h=plot(x,y);
    dxf('save',gca,varargin{2});
    return
end

if nargin==1
    ldb=varargin{1};
    [nam, pat]=uiputfile('*.dxf','Export to dxf-file');
    hTemp=figure;
    h=plot(ldb(:,1),ldb(:,2));
    dxf('save',gca,[pat nam]);
    close(hTemp);
    return
end

    