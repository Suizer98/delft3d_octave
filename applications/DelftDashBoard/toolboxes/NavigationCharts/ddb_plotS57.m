function ddb_plotS57(fname)
%DDB_PLOTS57  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotS57(fname)
%
%   Input:
%   fname =
%
%
%
%
%   Example
%   ddb_plotS57
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
load(fname);

fn=fieldnames(s.Layers);
nf=length(fn);

for i=1:nf
    n=length(s.Layers.(fn{i}));
    for j=1:n
        if isfield(s.Layers.(fn{i})(j),'Type')
            if ~isempty(lower(s.Layers.(fn{i})(j).Type))
                switch(lower(s.Layers.(fn{i})(j).Type))
                    case{'polygon'}
                        if isfield(s.Layers.(fn{i})(j),'Outer')
                            np=length(s.Layers.(fn{i})(j).Outer);
                            for k=1:np
                                x=s.Layers.(fn{i})(j).Outer(k).Coordinates(:,1);
                                y=s.Layers.(fn{i})(j).Outer(k).Coordinates(:,2);
                            end
                            switch(fn{i})
                                case{'LNDARE'}
                                    x(isnan(y))=NaN;
                                    y(isnan(x))=NaN;
                                    ptch=patch(x,y,'y');hold on;
                                    %                                     set(ptch,'EdgeColor','none','FaceColor',[0.7 0.8 0.7]);
                                    %                                 case{'SEAARE'}
                                    %                                     x(isnan(y))=NaN;
                                    %                                     y(isnan(x))=NaN;
                                    %                                     ptch=patch(x,y,'y');hold on;
                                    %                                     set(ptch,'EdgeColor','none','FaceColor',[0.9 0.9 0.95]);
                                    %                                 otherwise
                                    %                                     plot(x,y,'k');hold on;
                            end
                        end
                        if isfield(s.Layers.(fn{i})(j),'Inner')
                            np=length(s.Layers.(fn{i})(j).Inner);
                            for k=1:np
                                x=s.Layers.(fn{i})(j).Inner(k).Coordinates(:,1);
                                y=s.Layers.(fn{i})(j).Inner(k).Coordinates(:,2);
                            end
                            switch(fn{i})
                                case{'LNDARE'}
                                    x(isnan(y))=NaN;
                                    y(isnan(x))=NaN;
                                    ptch=patch(x,y,'y');hold on;
                                    %                                     set(ptch,'EdgeColor','none','FaceColor',[0.7 0.8 0.7]);
                                    %                                 case{'SEAARE'}
                                    %                                     x(isnan(y))=NaN;
                                    %                                     y(isnan(x))=NaN;
                                    %                                     ptch=patch(x,y,'y');hold on;
                                    %                                     set(ptch,'EdgeColor','none','FaceColor',[0.8 0.8 0.9]);
                                    %                                 otherwise
                                    %                                     plot(x,y,'k');hold on;
                            end
                        end
                        %                     case{'point'}
                        %                         x=s.Layers.(fn{i})(j).Coordinates(:,1);
                        %                         y=s.Layers.(fn{i})(j).Coordinates(:,2);
                        %                         plt=plot(x,y,'.');hold on;
                        %                         set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','k');
                        %                     case{'polyline'}
                        %                         x=s.Layers.(fn{i})(j).Coordinates(:,1);
                        %                         y=s.Layers.(fn{i})(j).Coordinates(:,2);
                        %                         plot(x,y,'k');hold on;
                        %                     case{'multipoint'}
                        %                         x=s.Layers.(fn{i})(j).Coordinates(:,1);
                        %                         y=s.Layers.(fn{i})(j).Coordinates(:,2);
                        %                         sz=zeros(size(x))+5;
                        %                         c=-s.Layers.(fn{i})(j).Coordinates(:,3);
                        %                         sc=scatter(x,y,sz,c,'filled');hold on;
                        %                         %                plot(x,y,'.');hold on;
                end
                %                if isfield(s.Layers.(fn{i})(j),'OBJNAM')
                %                    name=['  ' s.Layers.(fn{i})(j).OBJNAM];
                %                    if ~isempty(name)
                %                        xt=mean(x);
                %                        yt=mean(y);
                %                        tx=text(xt,yt,name);
                %                        set(tx,'FontSize',6);
                %                    end
                %                end
            end
        end
    end
end

