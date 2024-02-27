classdef xls < oop.handle_light
%XLS  fast, object oriented, reading and writing of xls files
%
% xls is much faster than matlab native xls read when multiple calls are
% made, because the refrence to the activex excel server is stored in the
% object and reused. Similarly, the reference to the open workbook (xls
% file) is reused and only updated when a differen workbook is opened.
%
% xls can read/write to named ranges, whereas xlswrite cannot write to named
% ranges (xlsread can read from named ranges).
%
%   Methods for class xls:
%   open  read  write  clear  save  getWorksheets  getUsedRange
%
%   Example
%     % open instance of xls
%     X = xls('mysheet.xls')
%
%     % read data from sheet1, range 'A1:B4'
%     data = X.read('sheet1','A1:B4')
%
%     % read from another file. the xls server is reused
%     X.open('another_file.xls')
%
%     % call read with no arguments: the first sheet is read over the used range
%     data = X.read
%
%     % read named ranges
%     data = X.read('sheet1','table[#Data]')    % read data
%     data = X.read('sheet1','table[#All]')     % read data + headers
%     data = X.read('sheet1','table[#Headers]') % read only headers
%
%     % clearing the sheet also closes the xls server
%     clear X
%
%   See also: xls.open,  xls.create, xls.read,     xls.write, 
%             xls.clear, xls.save,   xls.close,    xls.closeWorkbook
%             xls.getUsedRange,      xls.addsheet, xls.getWorksheets
%             xlsread,      xlswrite
    
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Aug 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id: xls.m 15023 2019-01-08 16:41:12Z gerben.deboer.x $
% $Date: 2019-01-09 00:41:12 +0800 (Wed, 09 Jan 2019) $
% $Author: gerben.deboer.x $
% $Revision: 15023 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/xls.m $
% $Keywords: $
    
%% start of code
    properties(GetAccess = 'public', SetAccess = 'private')
        % define the properties of the class here, (like fields of a struct)
        filename;
        data_written;
    end
    properties(GetAccess = 'private', SetAccess = 'private')
        % define the properties of the class here, (like fields of a struct)
        excel;
        workbook;
    end
    methods
        % methods, including the constructor are defined in this block
        function obj = xls(filename)
            if nargin == 1
                obj.setFile(filename);
            end
            obj.data_written = false;
        end
        
        function delete(obj)
            obj.close
        end
        
        function setFile(obj,filename)
            if nargin ~= 2
                error('only input filename')
            end
            if ~exist(filename,'file')
                create(obj,filename)
%                 error('file could not be found')
            end
            fns = dir2(filename);
            filename = [fns.pathname fns.name];
            if strcmpi(filename,obj.filename)
                % same file, do nothing
            else
                % check new workbook
                fid = fopen(filename);
                assert(fid>=2,'file could not be opened');
                fclose(fid);
                
                % clear open workbook if any
                if ~isempty(obj.workbook)
                    obj.closeWorkbook
                end
                
                % reset filename, and open it
                obj.filename = filename;
                obj.open;
            end
        end
        
        function open(obj,filename)
        % xls.open only open excel object if it is not available already
        %
        % open(filename)
        %
        % See also: xls            
            
            if isempty(obj.excel)
                obj.excel = actxserver('excel.application');
                obj.excel.DisplayAlerts = 0;
            end
            
            if nargin == 2
                % change filename if that is passed as argument
                obj.setFile(filename);
            elseif isempty(obj.workbook)
                if isempty(obj.filename)
                    warning('XLS:noFileSpecified','Call <obj>.open with an argument to specify which workbook to open');
                    return
                end
                % only open workbook if there is not one open already;
                obj.workbook = obj.excel.workbooks.Open(obj.filename);
            end
        end
        
        function create(obj,filename)
        % xls.create Create new workbook
        %
        %  create(filename)
        %
        % See also: xls                
            
            if isempty(obj.excel)
                obj.excel = actxserver('excel.application');
                obj.excel.DisplayAlerts = 0;
            end
            
            obj.workbook = obj.excel.workbooks.Add;
            [~,~,ext]=fileparts(filename);
            switch ext
                case '.xls' %xlExcel8 or xlWorkbookNormal
                   xlFormat = -4143;
                case '.xlsb' %xlExcel12
                   xlFormat = 50;
                case '.xlsx' %xlOpenXMLWorkbook
                   xlFormat = 51;
                case '.xlsm' %xlOpenXMLWorkbookMacroEnabled 
                   xlFormat = 52;
                otherwise
                   xlFormat = -4143;
            end
            obj.workbook.SaveAs(filename, xlFormat);
            obj.data_written = false;
            close(obj)
        end
        
        function newsheet = addsheet(obj,sheet)
        % xls.addsheet Add new worksheet to excel object
        %
        %  newsheet = addsheet(sheet)
        %
        % See also: xls           
        
            % .
            newsheet  = obj.workbook.WorkSheets.Add;
            % If Sheet is a string, rename new sheet to this string.
            if isnumeric(sheet)
                sheet = ['Sheet' num2str(sheet)];
            end
            set(newsheet,'Name',sheet);
        end
        
        function worksheets = getWorksheets(obj)
        % xls.getWorksheets get worksheets
        %
        %  worksheets = getWorksheets()
        %
        % See also: xls                
        
            obj.open;
            num_of_worksheets = obj.workbook.Worksheets.count;
            for ii = num_of_worksheets:-1:1
                names{ii} = obj.workbook.Worksheets.Item(ii).Name;
            end
            worksheets = names;
        end
        
        function usedRange = getUsedRange(obj,sheet)
        % xls.getUsedRange get used range
        %
        %  usedRange = getUsedRange(sheet)
        %
        % See also: xls                
        
            if nargin < 2
                sheet = 1;
            end
            usedRange = obj.workbook.Worksheets.Item(sheet).UsedRange.Address;
        end
        
        function save(obj)
        % xls.save save excel object
        %
        %  save()
        %
        % See also: xls      
        
            if obj.data_written
                obj.workbook.Save;
                obj.data_written = false;
            end
        end
        
        function close(obj)
        % xls.close close excel object
        %
        %  close()
        %
        % See also: xls         
        
            obj.closeWorkbook;
            if ~isempty(obj.excel)
                obj.excel.Quit;
                obj.excel.delete;
                obj.excel = [];
            end
        end
        
        function closeWorkbook(obj)
        % xls.closeWorkbook close workbook
        %
        %  closeWorkbook()
        %
        % See also: xls          
        
            if ~isempty(obj.workbook)
                if obj.data_written
                    warning('XLS:dataDiscarded','Data was not saved in %s, call <obj>.save before closing',obj.filename);
                end
                obj.excel.workbooks.Close;
                obj.workbook = [];
            end
        end
        
        function data = read(obj,sheet,range)
        % xls.read read from excel object
        %
        % data = read(sheet,range)
        %
        % range can be a named range.
        %
        % See also: xls   
        
            obj.open;
            if nargin < 2
                sheet = 1;
            end
            TargetSheet = get(obj.excel.sheets,'item',sheet);
            %Activate silently fails if the sheet is hidden
            set(TargetSheet, 'Visible','xlSheetVisible');
            % activate worksheet
            Activate(TargetSheet);
            if nargin < 3
                range = obj.getUsedRange(sheet);
            end
            Select(Range(obj.excel,range));
            DataRange = get(obj.excel,'Selection');
            data = DataRange.Value;
        end
        
        function write(obj,data,sheet,range)
        % xls.write write to excel object
        %
        % write(data,sheet,range)
        %
        % range can be a named range, unlike xlswrite.
        %
        % write needs to followed by save() and close().
        %
        % See also: xls
        
            obj.open;
            if obj.workbook.ReadOnly ~= 0
                %This means the file is probably open in another process.
                warning('XLS:LockedFile', 'The file %s is not writable.  It may be locked by another process.',obj.filename);
                return
            end
            worksheets = getWorksheets(obj);
            if ~ismember(sheet,worksheets)
                addsheet(obj,sheet);
            end
            TargetSheet = get(obj.excel.sheets,'item',sheet);
            %Activate silently fails if the sheet is hidden
            set(TargetSheet, 'Visible','xlSheetVisible');
            % activate worksheet
            Activate(TargetSheet);
            Select(Range(obj.excel,range));
            if iscell(data)
                % ok
            else
                data = num2cell(data);
                [data{cellfun(@isnan,data)}] = deal([]);
            end
            % Export data to selected region.
            set(obj.excel.selection,'Value',data);
            obj.data_written = true;
        end
        % write(obj,data,sheet,range)
        
        function clear(obj,sheet,range)
        % xls.clear clear
        %
        %  clear(sheet,range)
        %
        % See also: xls           
        
            obj.open;
            TargetSheet = get(obj.excel.sheets,'item',sheet);
            %Activate silently fails if the sheet is hidden
            set(TargetSheet, 'Visible','xlSheetVisible');
            % activate worksheet
            Activate(TargetSheet);
            if nargin < 3
                range = obj.getUsedRange(sheet);
            end
            Select(Range(obj.excel,range));
            DataRange = get(obj.excel,'Selection');
            %Clear range
            DataRange.ClearContents;
            obj.data_written = true;
        end
       
    end % methods    

end