function varargout = digitizeImg(varargin)
%DIGITIZEIMG   Starts a GUI for digitizing graphs.
%              Can be used for multiple data sets per graph and NOs
%              if a data point is marked incorrectly.
%
%   Use:
%
%                   Follow the instructions of the GUI.
%                   RIGHT CLICK: Choose data point
%                   LEFT CLICK:  Finish
%                   MIDDLE MOUSE BUTTON: NO of the last data point
%
%   Syntax: digitizeImg2
%                   opens an file picker. Can only be used on data types that are
%                   compatible with IMREAD.
%                   After choosing a file, a GUI will open that will guide you through
%                   the steps required for extracting the data.
%                   If called without outputs, the data is saved in a MAT
%                   file.
%
%
%           ImgData = digitizeImg2;
%                   Saves the data in the matrix/struct ImgData (struct if more than one data set).
%
%           digitizeImg2(filename);
%                   To choose the file directly.
%
%   see also:       IMREAD, IMFINFO
%
%   Input arguments:
%
%       - filename: file name of the image to be digitized (optional)
%
%   Output arguments:
%
%       - ImgData:  X- and Y-coordinates of the digitized graphs
%
%
% Author:  Marc Jakobi - 15.12.2015
% Original versions: digitize (by J.D.Cogdell) / digitize2 (by A. Prasad)

% Check for proper number of input arguments
narginchk(0,1);

% Identify image filename
if (nargin == 0)
     [filename, pathname] = uigetfile( ...
	       {'*.jpg;*.tif;*.tiff;*.gif;*.png;*.bmp', ...
		'All supported file types (*.jpg,*.tif,*.tiff,*.gif,*.png,*.bmp)'; ...
		'*.jpg;*.jpeg', ...
		'JPEG image (*.jpg,*.jpeg)'; ...
		'*.tif;*.tiff', ...
		'TIFF image (*.tif,*.tiff)'; ...
		'*.gif', ...
		'GIF image (*.gif)'; ...
		'*.png', ...
		'PNG image (*.png)'; ...
		'*.bmp', ...
		'Bitmap image (*.bmp)'; ...
		'*.*', ...
		'All file types (*.*)'}, ...
	       'Choose image');
     if isequal(filename,0) || isequal(pathname,0)
	  return
     else
	  imagename = fullfile(pathname, filename);
     end
elseif nargin == 1
     imagename = varargin{1};
     [~, file,ext] = fileparts(imagename);
     filename = strcat(file,ext);
end   

% Read image from target filename
pic = imread(imagename);
image(pic)
FigName = ['IMAGE: ' filename];
set(gcf,'Units', 'normalized', ...
	'Position', [0 0.125 1 0.85], ...
	'Name', FigName, ...
	'NumberTitle', 'Off', ...
	'MenuBar','None')
set(gca,'Units','normalized','Position',[0   0 1   1]);

chk = true;
while chk
    try
        % Determine location of origin with mouse click
        OriginButton = questdlg('Select the ORIGIN with the LEFT mouse button', ...
            'DIGITIZEIMG: User input', ...
            'OK','Cancel','OK');
        switch OriginButton
            case 'OK'
                drawnow
                [Xopixels,Yopixels] = ginput(1);
                inp = line(Xopixels,Yopixels,...
                    'Marker','o','Color','g','MarkerSize',14);
                inp2 = line(Xopixels,Yopixels,...
                    'Marker','x','Color','g','MarkerSize',14);
            case 'Cancel'
                close(FigName)
                return
        end % switch OriginButton
        % Prompt user for X- & Y- values at origin
        prompt={'Abscissa (X-coordinate) at origin:',...
            'Ordinate (Y-coordinate) at origin:',...
            'Repeat selection? (Y/N)'};
        def={'0','0','N'};
        dlgTitle='DIGITIZEIMG: User input';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
        if (isempty(char(answer{:})) == 1)
            close(FigName)
            return
        elseif strcmp(char(answer{3}),'Y')
            delete(inp)
            delete(inp2)
            error('chk')
        else
            answer = answer(1:2);
            OriginXYdata = [str2double(char(answer{1}));...
                str2double(char(answer{2}))];
            chk = false;
        end
    catch
    end
end

chk = true;
while chk
    try
        % Define X-axis
        XLimButton = questdlg(...
            'Select a point on the X-axis with the LEFT mouse button ', ...
            'DIGITIZEIMG: User input', ...
            'OK','Cancel','OK');
        switch XLimButton
            case 'OK'
                drawnow
                [XAxisXpixels,XAxisYpixels] = ginput(1);
                inp = line(XAxisXpixels,XAxisYpixels,...
                    'Marker','*','Color','b','MarkerSize',14);
                inp2 = line(XAxisXpixels,XAxisYpixels,...
                    'Marker','s','Color','b','MarkerSize',14);
            case 'Cancel'
                close(FigName)
                return
        end % switch XLimButton
        % Prompt user for XLim value
        prompt={'Abscissa (X) at the selected coordinate:';...
            'Repeat? (Y/N)'};
        def={'1','N'};
        dlgTitle='DIGITIZEIMG: User input';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
        if (isempty(char(answer{:})) == 1)
            close(FigName)
            return
        elseif strcmp(answer{2},'Y')
            delete(inp)
            delete(inp2)
            error('chk')
        else
            answer = answer(1);
            XAxisXdata = str2double(char(answer{:}));
            chk = false;
        end
    catch
    end
end
    
% Determine X-axis scaling
Xtype = questdlg(...
	  'Define Axis scaling (X)', ...
	  'DIGITIZEIMG: User input', ...
	  'LINEAR','LOGARITHMIC','Cancel','LINEAR');
drawnow
switch Xtype
     case 'LINEAR'
	  logx = 0;
	  scalefactorXdata = XAxisXdata - OriginXYdata(1);
     case 'LOGARITHMIC'
	  logx = 1;
	  scalefactorXdata = log10(XAxisXdata/OriginXYdata(1));
     case 'Cancel'
	  close(FigName)
	  return
end % switch Xtype


% Rotate image if necessary
% note image file line 1 is at top
th = atan((XAxisYpixels-Yopixels)/(XAxisXpixels-Xopixels));  
% axis rotation matrix
rotmat = [cos(th) sin(th); -sin(th) cos(th)];    


% Define Y-axis
chk = true;
while chk
    try
        YLimButton = questdlg(...
            'Select a point on the Y axis with the LEFT mouse button ', ...
            'DIGITIZEIMG: User input', ...
            'OK','Cancel','OK');
        switch YLimButton
            case 'OK'
                drawnow
                [YAxisXpixels,YAxisYpixels] = ginput(1);
                inp = line(YAxisXpixels,YAxisYpixels,...
                    'Marker','*','Color','b','MarkerSize',14);
                inp2 = line(YAxisXpixels,YAxisYpixels,...
                    'Marker','s','Color','b','MarkerSize',14);
            case 'Cancel'
                close(FigName)
                return
        end
        
        % Prompt user for YLim value
        prompt={'Ordinate (Y) at the selected coordinate',...
            'Repeat? (Y/N)'};
        def={'1','N'};
        dlgTitle='DIGITIZEIMG: User input';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
        if (isempty(char(answer{:})) == 1)
            close(FigName)
            return
        elseif strcmp(answer{2},'Y')
            delete(inp)
            delete(inp2)
            error('chk')
        else
            answer = answer(1);
            YAxisYdata = str2double(char(answer{:}));
            chk = false;
        end
    catch
    end
end
% Determine Y-axis scaling
Ytype = questdlg('Define axis scaling (Y)', ...
		 'DIGITIZEIMG: User input', ...
		 'LINEAR','LOGARITHMIC','Cancel','LINEAR');
drawnow
switch Ytype
     case 'LINEAR'
	  logy = 0;
	  scalefactorYdata = YAxisYdata - OriginXYdata(2);
     case 'LOGARITHMIC'
	  logy = 1;
	  scalefactorYdata = log10(YAxisYdata/OriginXYdata(2));
     case 'Cancel'
	  close(FigName)
	  return
end

% Complete rotation matrix definition as necessary
delxyx = rotmat*[(XAxisXpixels-Xopixels);(XAxisYpixels-Yopixels)];
delxyy = rotmat*[(YAxisXpixels-Xopixels);(YAxisYpixels-Yopixels)];
delXcal = delxyx(1);
delYcal = delxyy(2);


dlgTitle='DIGITIZEIMG: User input';
lineNo = 1;
prompt = 'How many data sets?';
def = {'1'};
answer = inputdlg(prompt,dlgTitle,lineNo,def);
numsets = str2double(char(answer{:}));
% colors:
g = [118, 185, 0]./255;
b = [0, 130, 209]./255;
o = [255, 95, 0]./255;
gr = [175, 175, 175]./255;
g2 = [51, 102, 0]./255;
gr2 = [80, 80, 80]./255;
y = [255, 204, 0]./255;
b2 = [25, 25, 112]./255;
colors = {g,b,o,gr,g2,gr2,y,b2};
if numsets > 8
    colors = repmat(colors,1,ceil(numsets./length(colors)));
end

for si = 1:numsets %Data set loop
    xpt = [];
    ypt = [];
    % Commence Data Acquisition from image
    msgStr{1} = 'Select data points with LEFT mouse button';
    msgStr{2} = ' ';
    msgStr{3} = 'NO with MIDDLE mouse button';
    msgStr{4} = ' ';
    msgStr{5} = 'RIGHT CLICK, when finished';
    if numsets == 1
        titleStr = 'Ready to extract data';
    else
        titleStr = ['Ready to extract data set' ,num2str(si),' of ',...
            num2str(numsets)];
    end
    uiwait(msgbox(msgStr,titleStr,'warn','modal'));
    drawnow
    nXY = [];
    ng = 0;
    acquiring = true;
    while acquiring
        n = 0;
        % Data acquisition loop
        while acquiring
            [x,y, buttonNumber] = ginput(1);
            if buttonNumber == 1
                aqmarker = line(x,y,'Marker','.','Color',colors{si},'MarkerSize',12);
                xy = rotmat*[(x-Xopixels);(y-Yopixels)];
                delXpoint = xy(1);
                delYpoint = xy(2);
                if logx
                    x = OriginXYdata(1)*10^(delXpoint/delXcal*scalefactorXdata);
                else
                    x = OriginXYdata(1) + delXpoint/delXcal*scalefactorXdata;
                end
                if logy
                    y = OriginXYdata(2)*10^(delYpoint/delYcal*scalefactorYdata);
                else
                    y = OriginXYdata(2) + delYpoint/delYcal*scalefactorYdata;
                end
                n = n+1;
                xpt(n) = x; %#ok<*AGROW>
                ypt(n) = y;
                ng = ng+1;
                nXY(ng,:) = [n x y];
            elseif si == 1 && n == 0
                query = questdlg('No data selected. Cancel?', ...
                    'DIGITIZE: confirmation', ...
                    'YES', 'NO', 'NO');
                drawnow
                switch upper(query)
                    case 'YES'
                        error('cancelled.')
                    case 'NO'
                end
            elseif buttonNumber == 3
                query = questdlg('Finished?', ...
                    'DIGITIZE: confirmation', ...
                    'YES', 'NO', 'NO');
                drawnow
                switch upper(query)
                    case 'YES'
                        acquiring = false;
                    case 'NO'   
                end
            elseif buttonNumber == 2
                query = questdlg('Correct last selection?', ...
                    'DIGITIZE: confirmation', ...
                    'CORRECTION', 'CONTINUE', 'CONTINUE');
                drawnow
                switch upper(query)
                    case 'CORRECTION'
                        delete(aqmarker);
                        n = n - 1;
                        ng = ng - 1;
                    case 'CONTINUE'
                end
            end
            
        end
    end
    if numsets > 1
        eval(['ImgData.x',num2str(si),' = xpt'';']);
        eval(['ImgData.y',num2str(si),' = ypt'';']);
    end
end
     if nargout  == 0
	  % Save data to file
      try
          [writefname, writepname] = uiputfile('*.mat','Save as...');
          writepfname = fullfile(writepname, writefname);
          if numsets > 1
              save(writepfname,'ImgData')
          else
              ImgDataXY = [xpt' ypt']; %#ok<NASGU>
              save(writepfname,'ImgDataXY')
          end
      catch
          close(FigName)
          return
      end
     elseif nargout == 1
         if numsets == 1
            outputdata = [xpt' ypt'];
         else
            outputdata = ImgData;
         end
         varargout{1} = outputdata;
         close(FigName);
     end
end   







