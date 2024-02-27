function boundary=ddb_reorder_fm_boundaries(boundary0,frc,t0,t1)

ibnd=0;

% First merge boundaries with same pli file

for ibnd0=1:length(boundary0)

    locfile=boundary0(ibnd0).locationfile;
    name=locfile(1:end-4);
    quant=boundary0(ibnd0).quantity;

    boundary0(ibnd0).include_time_series=0;
    boundary0(ibnd0).include_astronomic_components=0;
    boundary0(ibnd0).include_harmonic_components=0;
    
    % First loop nodes and forcings to find the matching forcing
    forcingfile=boundary0(ibnd0).forcingfile;
    
    for ip=1:length(boundary0(ibnd0).x)
        nodename=[name '_' num2str(ip,'%0.4i')];
        for ifrc=1:length(frc)
            if strcmpi(frc(ifrc).forcing_file,forcingfile)
                % Same forcing file
                if strcmpi(frc(ifrc).name,nodename)
                    % Found the right node, now check if it's the same
                    % quantity
                    if strcmpi(frc(ifrc).type,quant)
                        % Same quantity
                        switch lower(frc(ifrc).function)
                            case{'timeseries'}
                                boundary0(ibnd0).include_time_series=1;
                                boundary0(ibnd0).node(ip).time_series=frc(ifrc).time_series;                                
                            case{'astronomic'}
                                boundary0(ibnd0).include_astronomic_components=1;
                                boundary0(ibnd0).node(ip).astronomic_component=frc(ifrc).astronomic_component;
                            case{'harmonic'}
                                boundary0(ibnd0).include_harmonic_components=1;
                                boundary0(ibnd0).node(ip).harmonic_component=frc(ifrc).harmonic_component;
                        end
                    end
                end
            end
        end
    end
    
end

for ibnd0=1:length(boundary0)
    
    locfile=boundary0(ibnd0).locationfile;
    name=locfile(1:end-4);
    quant=boundary0(ibnd0).quantity;
    
    k=0;
    
    if ibnd0>1
        for j=1:ibnd
            if strcmpi(locfile,boundary(j).boundary.location_file)
                % This location file has already been used! Merge the two.
                k=j;
                break
            end
        end
    end
    
    if k==0
        
        % New boundary
        ibnd=ibnd+1;
        np=length(boundary0(ibnd0).x); % number of nodes
        t0=0;
        t1=0;

        switch lower(boundary0(ibnd0).quantity)
            case{'waterlevelbnd'}
                tp='water_level';
            case{'normalvelocitybnd'}
                tp='normal_velocity';
            case{'tangentialvelocitybnd'}
                tp='tangential_velocity';
            case{'riemannbnd'}
                tp='riemann';
        end
        
        boundary(ibnd).boundary=ddb_delft3dfm_initialize_boundary(name,tp,'astronomic',t0,t1,boundary0(ibnd0).x,boundary0(ibnd0).y);
        
        if boundary0(ibnd0).include_time_series
            boundary(ibnd).boundary.(tp).time_series.active=1;
            boundary(ibnd).boundary.(tp).time_series.forcing_file=boundary0(ibnd0).forcingfile;
            for ip=1:length(boundary0(ibnd0).x)
                boundary(ibnd).boundary.(tp).time_series.nodes(ip).time=boundary0(ibnd0).node(ip).time_series.time;
                boundary(ibnd).boundary.(tp).time_series.nodes(ip).value=boundary0(ibnd0).node(ip).time_series.value;
            end
        end
        
        if boundary0(ibnd0).include_astronomic_components
            boundary(ibnd).boundary.(tp).astronomic_components.active=1;
            boundary(ibnd).boundary.(tp).astronomic_components.forcing_file=boundary0(ibnd0).forcingfile;
            for ip=1:length(boundary0(ibnd0).x)
                boundary(ibnd).boundary.(tp).astronomic_components.nodes(ip).name=boundary0(ibnd0).node(ip).astronomic_component.name;
                boundary(ibnd).boundary.(tp).astronomic_components.nodes(ip).amplitude=boundary0(ibnd0).node(ip).astronomic_component.amplitude;
                boundary(ibnd).boundary.(tp).astronomic_components.nodes(ip).phase=boundary0(ibnd0).node(ip).astronomic_component.phase;
            end
        end
        
        if boundary0(ibnd0).include_harmonic_components
            boundary(ibnd).boundary.(tp).harmonic_components.active=1;
            boundary(ibnd).boundary.(tp).harmonic_components.forcing_file=boundary0(ibnd0).forcingfile;
            for ip=1:length(boundary0(ibnd0).x)
                boundary(ibnd).boundary.(tp).harmonic_components.nodes(ip).frequency=boundary0(ibnd0).node(ip).harmonic_component.frequency;
                boundary(ibnd).boundary.(tp).harmonic_components.nodes(ip).amplitude=boundary0(ibnd0).node(ip).harmonic_component.amplitude;
                boundary(ibnd).boundary.(tp).harmonic_components.nodes(ip).phase=boundary0(ibnd0).node(ip).harmonic_component.phase;
            end
        end
        
    else
        
        % Another boundary already used this pli file !!!
        
        % merge boundaries
        switch boundary(k).boundary.type
            case{'water_level'}
                switch boundary0(ibnd0).quantity
                    case{'normalvelocitybnd'}
                        boundary(k).boundary.type='water_level_plus_normal_velocity';
                    case{'tangentialvelocitybnd'}
                        boundary(k).boundary.type='water_level_plus_tangential_velocity';
                end
            case{'water_level_plus_normal_velocity'}
                switch boundary0(ibnd0).quantity
                    case{'tangentialvelocitybnd'}
                        boundary(k).boundary.type='water_level_plus_normal_velocity_plus_tangential_velocity';
                end
            case{'water_level_plus_tangential_velocity'}
                switch boundary0(ibnd0).quantity
                    case{'normalvelocitybnd'}
                        boundary(k).boundary.type='water_level_plus_normal_velocity_plus_tangential_velocity';
                end
        end
        
        switch lower(boundary0(ibnd0).quantity)
            case{'waterlevelbnd'}
                tp='water_level';
            case{'normalvelocitybnd'}
                tp='normal_velocity';
            case{'tangentialvelocitybnd'}
                tp='tangential_velocity';
            case{'riemannbnd'}
                tp='riemann';
        end
        
        if boundary0(ibnd0).include_time_series
            boundary(k).boundary.(tp).time_series.active=1;
            boundary(k).boundary.(tp).time_series.forcing_file=boundary0(ibnd0).forcingfile;
            for ip=1:length(boundary0(ibnd0).x)
                boundary(k).boundary.(tp).time_series.nodes(ip).time=boundary0(ibnd0).node(ip).time_series.time;
                boundary(k).boundary.(tp).time_series.nodes(ip).value=boundary0(ibnd0).node(ip).time_series.value;
            end
        end
        
        if boundary0(ibnd0).include_astronomic_components
            boundary(k).boundary.(tp).astronomic_components.active=1;
            boundary(k).boundary.(tp).astronomic_components.forcing_file=boundary0(ibnd0).forcingfile;
            for ip=1:length(boundary0(ibnd0).x)
                boundary(k).boundary.(tp).astronomic_components.nodes(ip).name=boundary0(ibnd0).node(ip).astronomic_component.name;
                boundary(k).boundary.(tp).astronomic_components.nodes(ip).amplitude=boundary0(ibnd0).node(ip).astronomic_component.amplitude;
                boundary(k).boundary.(tp).astronomic_components.nodes(ip).phase=boundary0(ibnd0).node(ip).astronomic_component.phase;
            end
        end
        
        if boundary0(ibnd0).include_harmonic_components
            boundary(k).boundary.(tp).harmonic_components.active=1;
            boundary(k).boundary.(tp).harmonic_components.forcing_file=boundary0(ibnd0).forcingfile;
            for ip=1:length(boundary0(ibnd0).x)
                boundary(k).boundary.(tp).harmonic_components.nodes(ip).frequency=boundary0(ibnd0).node(ip).harmonic_component.frequency;
                boundary(k).boundary.(tp).harmonic_components.nodes(ip).amplitude=boundary0(ibnd0).node(ip).harmonic_component.amplitude;
                boundary(k).boundary.(tp).harmonic_components.nodes(ip).phase=boundary0(ibnd0).node(ip).harmonic_component.phase;
            end
        end
        
    end

end

% Now merge existing boundaries with different quantities


%     k=0;
    
%     if ibnd0>1
%         for j=1:ibnd
%             if strcmpi(boundary0(ibnd0).locationfile,boundary(j).locationfile)
%                 % This location file has already been used! Merge the two.
%                 k=j;
%             end
%         end
%     end
    
%     if k==0
% 
%         % New boundary
% 
%         ibnd=ibnd+1;
% 
%         np=length(boundary0(ibnd0).x); % number of nodes
%         t0=0;
%         t1=0;
%         
%         boundary(ibnd).boundary=ddb_delft3dfm_initialize_boundary(t0,t1,np);
%         
%         boundary(ibnd).boundary.locationfile=boundary0(ibnd0).locationfile;
%         boundary(ibnd).boundary.x=boundary0(ibnd0).x;
%         boundary(ibnd).boundary.y=boundary0(ibnd0).y;
%         
%         switch lower(boundary0(ibnd0).quantity)
%             
%             case{'waterlevelbnd'}
% 
%                 forcingfile=boundary0(ibnd0).forcingfile;
%                 
%                 % Loop through nodes and forcings
%                 for ip=1:np
%                 boundary(ibnd).boundary.type='water_level';
%                 % Look up what sort of forcing this is in the forcing file
%                 boundary(ibnd).boundary.water_level.water_level_forcing_file=boundary0(ibnd0).forcingfile;
%                 end
%                 
%         end
%         
%         
%     else
%         % merge boundaries
%         switch boundary(k).type
%             case{'water_level'}                
%                 switch boundary0(ibnd0).quantity
%                     case{'normalvelocitybnd'}
%                         boundary(k).type='water_level_plus_normal_velocity';
%                         boundary(k).normal_velocity_forcing_file=boundary0(ibnd0).forcingfile;
%                 end                
%         end
%     end
%     
% end
% 
% nbnd=length(boundary);
% % And now match forcing
% for ibnd=1:nbnd
%     locfile=boundary(ibnd).locationfile;
%     name=locfile(1:end-4);
%     for ip=1:length(boundary(ibnd).x)
%         nodename=[name '_' num2str(ip,'%0.4i')];
%         for ifrc=1:length(frc)
%             
%             if strcmpi(nodename,frc(ifrc).name)
%                 
%                 switch lower(frc(ifrc).function)
%                     
%                     case{'astronomic'}
%                         
%                         switch lower(frc(ifrc).quantity(2).name)
%                             case{'waterlevelbnd amplitude'}
%                                 boundary(ibnd).node(ip).water_level.astronomic_component=frc(ifrc).astronomic_component;
%                             case{'normalvelocitybnd amplitude'}
%                                 boundary(ibnd).node(ip).normal_velocity.astronomic_component=frc(ifrc).astronomic_component;
%                             case{'riemannbnd amplitude'}
%                                 boundary(ibnd).node(ip).riemann.astronomic_component=frc(ifrc).astronomic_component;
%                         end                        
%                         
%                     case{'harmonic'}
% 
%                     case{'timeseries'}
% 
%                         switch lower(frc(ifrc).quantity(2).name)
%                             case{'waterlevelbnd'}
%                                 boundary(ibnd).node(ip).water_level.time_series.time=frc(ifrc).time_series.time;
%                                 boundary(ibnd).node(ip).water_level.time_series.value=frc(ifrc).time_series.value;
%                             case{'normalvelocitybnd'}
%                                 boundary(ibnd).node(ip).normal_velocity.time_series.time=frc(ifrc).time_series.time;
%                                 boundary(ibnd).node(ip).normal_velocity.time_series.value=frc(ifrc).time_series.value;
%                             case{'riemannbnd'}
%                                 boundary(ibnd).node(ip).riemann.time_series.time=frc(ifrc).time_series.time;
%                                 boundary(ibnd).node(ip).riemann.time_series.value=frc(ifrc).time_series.value;
%                         end                        
%                 
%                 end
%                 
%             end
%         end
%         
%     end
% end
