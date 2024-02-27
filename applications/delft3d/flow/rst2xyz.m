
function rst2xyz(pathRST,pathMDF)

%% reading mdf, grd, dep and dry
flowDir = fileparts(pathMDF);
mdfDATA = delft3d_io_mdf('read',pathMDF);
nol = length(mdfDATA.keywords.thick);
constituents = checkConstituents(mdfDATA);
nof = length(constituents);
grd = wlgrid('read',[flowDir,filesep,mdfDATA.keywords.filcco]);
grd.Xcor = center2corner(grd.X);
grd.Ycor = center2corner(grd.Y);
dep = wldep('read',[flowDir,filesep,mdfDATA.keywords.fildep],grd);

% read dry points
if isfield(mdfDATA.keywords,'fildry') && ~strcmpi(mdfDATA.keywords.fildry,'')
    ID_dummy = reshape([1:size(grd.Xcor,1)*size(grd.Xcor,2)],size(grd.Xcor,1),size(grd.Ycor,2));
    dry = delft3d_io_dry('read',[flowDir,filesep,mdfDATA.keywords.fildry]);
    for dd = 1:length(dry.m)
        ID_dryPoints(dd,1) = ID_dummy(dry.m(dd),dry.n(dd));
    end
else
    ID_dryPoints = [];
end

%% deriving output directory
[outputDir,rstName,rstExt]= fileparts(pathRST);

%% Reading restartfile and replacing 0 with NaN
[rst.all{1:nof*nol+2*nol+1}]=trirst('read',pathRST,grd);

%% finding ghost cells (always value = 0)
for ii = 1:length(rst(1).all)
    ID_0(:,:,ii) = rst.all{ii}==0;
end
ID_ghost = find(min(ID_0,[],3)==1);
ID_NaN = unique([ID_dryPoints;ID_ghost]);

%% processing wl field: All WL equal to the bed to NaN
ID_dry = unique([ID_NaN;find((rst.all{1,1}+dep)<0.1)]);
rst.all{1,1}(ID_dry) = NaN;

%% looping through fields

for ii = 1:length(rst(1).all)        %different variables
    
    if ii == 1
        variable_name = 'Waterlevel';
        layer = 1;
    elseif ii > 1 && ii < 2+nol
        variable_name = 'Uvel';
        layer =ii-1;
    elseif ii > 1+nol && ii < 2+nol*2
        variable_name = 'Vvel';
        layer =ii-(1+nol);
    else
        variable_name = constituents(ceil((ii-2*nol-1)/nol)).name;
        layer =ii-(1+nol*(2+ceil((ii-2*nol-1)/nol)-1));
    end
    
    rst(1,1).all{ii}(ID_NaN) = NaN;
    
    if ii >1
        if layer == 1
            DA_var = zeros(size(grd.Xcor));
        end
        DA_var = DA_var+rst(1,1).all{ii}*mdfDATA.keywords.thick(layer);
    end
    
    xyzData = [grd.Xcor(:) grd.Ycor(:) rst(1,1).all{ii}(:)];
    IDnoNaN = find(~isnan(sum(xyzData,2)));
    
    % write .xyz file
    fid = fopen([outputDir,filesep,rstName,rstExt,'_',variable_name,'_L',num2str(layer,'%02i'),'.xyz'],'w');
    fprintf(fid,[repmat('%16.7e',1,size(xyzData(IDnoNaN,:),2)) '\n'],xyzData(IDnoNaN,:)');
    fclose(fid);
    
    % write figure
    figure
    axis equal
    pcolorcorcen(grd.Xcor,grd.Ycor,rst(1,1).all{ii})
    title([variable_name,', layer ',num2str(layer)])
    grid on
    hC = colorbar
    set(get(hC,'YLabel'),'String',variable_name)
    print(gcf,'-dpng','-r300',[outputDir,filesep,rstName,rstExt,'_',variable_name,'_L',num2str(layer,'%02i'),'.png'])
    close all
    
    % write DA data
    if nol > 1 & layer == nol
        xyzData = [grd.Xcor(:) grd.Ycor(:) DA_var(:)r];
        IDnoNaN = find(~isnan(sum(xyzData,2)));
        % write .xyz file
        fid = fopen([outputDir,filesep,rstName,rstExt,'_',variable_name,'_DA.xyz'],'w');
        fprintf(fid,[repmat('%16.7e',1,size(xyzData(IDnoNaN,:),2)) '\n'],xyzData(IDnoNaN,:)');
        fclose(fid);
        
        % write figure
        figure
        axis equal
        pcolorcorcen(grd.Xcor,grd.Ycor,rst(1,1).all{ii})
        title([variable_name,', Depth-averaged'])
        grid on
        hC = colorbar
        set(get(hC,'YLabel'),'String',variable_name)
        print(gcf,'-dpng','-r300',[outputDir,filesep,rstName,rstExt,'_',variable_name,'_DA.png'])
        close all
    end
end
end

function constituents=checkConstituents(mdfDATA)

constituents=[];

if isempty(findstr(mdfDATA.keywords.sub1,'T'))==0 && isempty(findstr(mdfDATA.keywords.sub1,'S'))==0
    constituents(2).name='Temperature';
    constituents(1).name='Salinity';
elseif isempty(findstr(mdfDATA.keywords.sub1,'T'))==1 && isempty(findstr(mdfDATA.keywords.sub1,'S'))==0
    constituents(1).name='Salinity';
elseif isempty(findstr(mdfDATA.keywords.sub1,'T'))==0 && isempty(findstr(mdfDATA.keywords.sub1,'S'))==1
    constituents(1).name='Temperature';
else
    display('No data available');
end

no_tracers = length(constituents);


if isempty(findstr(mdfDATA.keywords.sub2,'C'))==0
    tracers_total = 0;
    tracer_test = 1;
    while tracer_test == 1
        tracers_total = tracers_total + 1;
        eval(['tracer_test = isfield(mdfDATA.keywords,''namc',num2str(tracers_total+1),''');'])
    end
    
    for m =1:tracers_total
        eval(['constituents(no_tracers+m).name = strrep(mdfDATA.keywords.namc',num2str(m),','' '','''');'])
    end
end

end