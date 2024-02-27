function [tijdstapeenheid, tijdstap] = bepaal_tijdstap(taxis, mode)
% Determine timestep of given time axis.
% 
% CALL:
%  [tijdstapeenheid, tijdstap] = bepaal_tijdstap(taxis, mode)
% 
% INPUT:
%  taxis: Vector of Matlab datenum.
%  mode: (Optional) string with possible values:
%        'TE' (default) - Assume an equidistant timeseries, tijdstap is the
%                         smallest found timestep, this is useful when the 
%                         timeseries has missing values.
%        otherwise      - If timestep is always equal --> TE timeseries.
%                         Otherwise                   --> TN timeseries.
% 
% OUTPUT:
%  tijdstapeenheid:  String with possible values, empty if TN timeseries:
%                    - 'd' days
%                    - 'min' minute
%                    - 's' seconds
%                    - 'cs' centiseconds
% 
%  tijdstap: Integer with timestep in tijdstapeenheid units, empty for 'TN'
%  timeseries.
% 
% See also: cmp_taxis, set_taxis

if nargin < 2
    mode = 'TE';
end

resolution = 24*60*60*100; %seconden

if length(taxis) > 1
    tijdstap = unique(diff(round(resolution*taxis))/resolution);
else
    tijdstap = taxis;
end

if length(tijdstap) > 1
    if strcmp(mode, 'TE')
        tijdstap = min(tijdstap);
        
        if ~issorted(taxis)
            error('Tijdreeks is niet oplopend');
        end
    else
        %een niet equidistante reeks
        tijdstapeenheid = '';
        tijdstap = 0;
        return
    end
end

if tijdstap >= 1 %dagen
    tijdstapeenheid = 'min';
    tijdstap = tijdstap * 1440; %KJH20100216 dag schijnt niet geaccepteerd te worden door Donar
    return
end

% if tijdstap * 24 >= 1 %uur
%     tijdstapeenheid = 'uur';
%     tijdstap = tijdstap * 24;
%     return
% end

if tijdstap * 24 * 60 >= 1 %minuten
    tijdstapeenheid = 'min';
    tijdstap = tijdstap * 24 * 60;
    return
end

if tijdstap * 24 * 60 * 60 >= 1 %seconden
    tijdstapeenheid = 's';
    tijdstap = tijdstap * 24 * 60 * 60;
    return
end

if tijdstap * 24 * 60 * 60 * 100 >= 1 %centiseconden
    tijdstapeenheid = 'cs';
    tijdstap = tijdstap * 24 * 60 * 60 * 100;
    return
end

tijdstapeenheid = ''; 
