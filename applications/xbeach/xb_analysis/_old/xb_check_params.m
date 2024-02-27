function [par Celpar] = XB_readpars(XBdir,standardpars)
%
% Function to read parameters specified in a params.txt file. If specified,
% the result is compared to a list of legal parameters optained using the
% function XB_updateParams.
%
% Syntax: [par Celpar] = XB_readpars(XBdir,standardpars)
%
% Input:  XBdir        = XBeach model directory. Optional, if not
%                        specified the current directory is used
%         standardpars = Parameter structure returned by XB_updateParams
%                        function. Optional, if not specified no comparison
%                        to legal values is made.
%
% Result: par          = Structure with all parameters specified in the
%                        params.txt file.
%         Celpar       = Cell structure of par
%
%
% Created 15-03-2010 : XBeach-group Delft
%
% See also XB_updateParams

par={};
Celpar={};
docheck = 1;

if ~exist('XBdir','var')
    XBdir=pwd;
end

if ~exist('standardpars','var')
    standardpars={};
    allowednames=('');
    docheck = 0;
end

if ~or(strcmpi(XBdir(end),'/'),strcmpi(XBdir(end),'\'))
    XBdir(end+1)=filesep;
end

paramsfname = [XBdir 'params.txt'];
fid=fopen(paramsfname);

maxlines = str2num( perl('countlines.pl',paramsfname) );

for i=1:length(standardpars);
    temp = strtrim(standardpars(i).name);
    allowednames(i,1:length(temp))=temp;
end


for nline=1:maxlines
    line=fgetl(fid);
    t1=findstr('=',line);
    if ~isempty(t1)
        parname=strtrim(line(1:t1-1));
        if docheck==1
            % Check if this is a valid parameter name
            t2=strmatch(parname,allowednames,'exact');
            if isempty(t2)
                display(['Warning. Unknown parameter ' parname]);
            else
                % is this numeric of character?
                parval=strtrim(line(t1+1:end));
                try
                    if isletter(parval(1))
                        eval(['par.' parname ' = ''' parval ''';']);
                        Celpar(end+1,1:2) = {parname,parval};
                    else
                        tempval=str2num(parval);
                        if or(tempval>standardpars(t2).maxval,tempval<standardpars(t2).minval)
                            display(['Warning. Parameter ' parname ' outside recommended range']);
                        end
                        eval(['par.' parname ' = ' parval ';']);
                        Celpar(end+1,1:2) = {parname,tempval};
                    end
                catch
                    error(['Function cannot parse ''' parname ' = ' parval ''' in params.txt']);
                end
            end
        else
            parval=strtrim(line(t1+1:end));
            try
                if isletter(parval(1))
                    eval(['par.' parname ' = ''' parval ''';']);
                    Celpar(end+1,1:2) = {parname,parval};
                else
                    eval(['par.' parname ' = ' parval ';']);
                    Celpar(end+1,1:2) = {parname,str2num(parval)};
                end
            catch
                error(['Function cannot parse ''' parname ' = ' parval ''' in params.txt']);
            end
        end
    end
end

% Find output variables

if isfield(par,'nglobalvar')
    par.outputglobal={};
    frewind(fid);
    for nline=1:maxlines-par.nglobalvar
        line=fgetl(fid);
        t1=findstr('nglobalvar',line);
        if ~isempty(t1)
            for ii=1:par.nglobalvar
                line=strtrim(fgetl(fid));
                par.outputglobal{ii}=line;
            end
            Celpar(end+1,1:2)={'outputglobal',par.outputglobal};
        end
    end    
end

if isfield(par,'nmeanvar')
    par.outputglobal={};
    frewind(fid);
    for nline=1:maxlines-par.nmeanvar
        line=fgetl(fid);
        t1=findstr('nmeanvar',line);
        if ~isempty(t1)
            for ii=1:par.nmeanvar
                line=strtrim(fgetl(fid));
                par.outputmean{ii}=line;
            end
            Celpar(end+1,1:2)={'outputmean',par.outputmean};
        end
    end    
end

if isfield(par,'npoints')
    par.outputpoints={};
    frewind(fid);
    for nline=1:maxlines-par.npoints
        line=fgetl(fid);
        t1=findstr('npoints',line);
        if ~isempty(t1)
            for ii=1:par.npoints
                line=strtrim(fgetl(fid));
                par.outputpoints{ii}=line;
            end
            Celpar(end+1,1:2)={'outputpoints',par.outputpoints};
        end
    end    
end

if isfield(par,'nrugauge')
    par.outputrugauge={};
    frewind(fid);
    for nline=1:maxlines-par.nrugauge
        line=fgetl(fid);
        t1=findstr('nrugauge',line);
        if ~isempty(t1)
            for ii=1:par.nrugauge
                line=strtrim(fgetl(fid));
                par.outputrugauge{ii}=line;
            end
            Celpar(end+1,1:2)={'outputrugauge',par.outputrugauge};
        end
    end    
end
