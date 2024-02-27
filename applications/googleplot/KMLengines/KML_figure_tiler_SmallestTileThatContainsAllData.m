function code = KML_figure_tiler_SmallestTileThatContainsAllData(D)
%KML_figure_tiler_SmallestTileThatContainsAllData subsidiary of KMLfigure_tiler
%
%   code = KML_figure_tiler_SmallestTileThatContainsAllData(D)
%
% where D has fields lat and lon
%
%  The quadtree tiling is zero-based as:
%  +----+----+
%  | 00 | 01 |
%  +----+----+
%  | 02 | 03 |
%  +----+----+
%
% 0    whole world: 0
%
% 00    upper left  = north America
% 000xx <<outside world>>
% 001xx, <<outside world>>
% 002   Us east coast and great plains 
% 003   US west coast, Greenland
%
% 01    upper right = EurAsia + North Africa
%  010xx <<outside world>>
%  011xx <<outside world>>
%  012   Europe, India, North Africa
%   0120  NW Europe
%   0121  central Russia
%   0122  Southern Europe, North Africa
%   0123  India
%  013   China, Japan, Siberia
%
% 02    lower left  = Oceania + South America
%  020   Oceania 
%  021   South America 
%  022   <<outside world>>
%  023   <<outside world>>
%
% 03   lower right =  Southern Africa + Australia
%  030   Southern Africa
%  031   Australia
%  032   <<outside world>>
%  033   <<outside world>>
%
%See also: KMLfigure_tiler, KML_figure_tiler_code2boundary

dataBounds.N = max(D.lat(:));
dataBounds.S = min(D.lat(:));
dataBounds.W = min(D.lon(:));
dataBounds.E = max(D.lon(:));

code   = '0';
search = true;

if isnan(dataBounds.N) || isnan(dataBounds.S) || isnan(dataBounds.W) || isnan(dataBounds.E)
    return
end

while search;
    dataIntile = 0;
    for addCode = ['0','1','2','3']
        tileBounds = KML_figure_tiler_code2boundary([code addCode]);
        if ((dataBounds.E > tileBounds.W &&...
             dataBounds.W < tileBounds.E   )&&...
            (dataBounds.N > tileBounds.S &&...
             dataBounds.S < tileBounds.N  ))
            dataIntile = dataIntile+1;
            nextCode = [code addCode];
        end
    end
    if dataIntile>1
        search = false;
    else
        code = nextCode;
    end
end