function UCIT_saveDataUS(d)
%UCIT_SAVEDATAUS  saves data of gui into matfile
%
%
%   See also plotAlongshore

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------clear selecteditems;clc;

%% check whether overview figure is present
[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make an overview figure (plotTransectOverview)','No map found');
    return
end

results = get(findobj('tag','par'), 'userdata');

if ~isempty(results)
    [FileName,PathName] = uiputfile('d:\*.txt','Save data to txt-file', 'Saved_data.txt');
    if FileName==0 & PathName==0
        return
    else
        
        counter = 1;
        finaltable = repmat(0,length(results(1).x),10);
        
        for i = 1 :2: length(results)*2
            finaltable(:,i) = results(counter).x;
            finaltable(:,i+1) = results(counter).y;
            counter = counter +1;           
        end
        
        fid = fopen([PathName,FileName],'w');
        fprintf(fid,'%6.2f  %6.2f  %6.2f  %6.2f  %6.2f  %6.2f  %6.2f  %6.2f  %6.2f  %6.2f \n',[finaltable]');
        fclose(fid);
        %         save([PathName,FileName],'results')
    end

else
    errordlg('First run preview');
end





