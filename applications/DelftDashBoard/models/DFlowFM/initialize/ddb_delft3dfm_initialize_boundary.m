function boundary=ddb_delft3dfm_initialize_boundary(name,tp,forcing,t0,t1,x,y,varargin)

bcfile='test001.bc';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'bcfile'}
                bcfile=varargin{ii+1};   % water level correction
        end
    end                
end

np=length(x);

quantities={'water_level','normal_velocity','tangential_velocity','riemann','discharge'};

boundary.name=name;
boundary.type=tp;
boundary.x=x;
boundary.y=y;
boundary.nrnodes=np;
boundary.handle=-999;
boundary.location_file=[name '.pli'];
for ip=1:np
    boundary.nodenames{ip}=[name '_' num2str(ip,'%0.4i')];
end
boundary.activenode=1;

for iq=1:length(quantities)
    
    quant=quantities{iq};

    % Time-series
    boundary.(quant).time_series.forcing_file=bcfile;
    boundary.(quant).time_series.active=0;
    for ip=1:np
        boundary.(quant).time_series.nodes(ip).time=[t0;t1];
        boundary.(quant).time_series.nodes(ip).value=[0;0];
    end
    
    % Astro
    boundary.(quant).astronomic_components.forcing_file=bcfile;
    boundary.(quant).astronomic_components.active=0;
    for ip=1:np
        boundary.(quant).astronomic_components.nodes(ip).name{1}='M2';
        boundary.(quant).astronomic_components.nodes(ip).amplitude(1)=0;
        boundary.(quant).astronomic_components.nodes(ip).phase(1)=0;
    end
    
    % Harmo
    boundary.(quant).harmonic_components.forcing_file=bcfile;
    boundary.(quant).harmonic_components.active=0;
    for ip=1:np
        boundary.(quant).harmonic_components.nodes(ip).frequency=30;
        boundary.(quant).harmonic_components.nodes(ip).amplitude(1)=0;
        boundary.(quant).harmonic_components.nodes(ip).phase(1)=0;
    end
    
end

switch lower(forcing)
    
    case{'astronomic'}
        switch tp
            case{'water_level'}
                % initialize with astro
                boundary.water_level.astronomic_components.active=1;
            case{'water_level_plus_normal_velocity'}
                boundary.water_level.astronomic_components.active=1;
                boundary.normal_velocity.astronomic_components.active=1;
            case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
                boundary.water_level.astronomic_components.active=1;
                boundary.normal_velocity.astronomic_components.active=1;
                boundary.tangential_velocity.astronomic_components.active=1;
            case{'riemann'}
                boundary.riemann.astronomic_components.active=1;
            case{'discharge'}
                boundary.riemann.astronomic_components.active=1;
        end
        
    case{'time_series'}
        switch tp
            case{'water_level'}
                % initialize with astro
                boundary.water_level.time_series.active=1;
            case{'water_level_plus_normal_velocity'}
                boundary.water_level.time_series.active=1;
                boundary.normal_velocity.time_series.active=1;
            case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
                boundary.water_level.time_series.active=1;
                boundary.normal_velocity.time_series.active=1;
                boundary.tangential_velocity.time_series.active=1;
            case{'riemann'}
                boundary.riemann.time_series.active=1;
            case{'discharge'}
                boundary.riemann.time_series.active=1;
        end
        
    case{'harmonic'}
        switch tp
            case{'water_level'}
                % initialize with astro
                boundary.water_level.harmonic_components.active=1;
            case{'water_level_plus_normal_velocity'}
                boundary.water_level.harmonic_components.active=1;
                boundary.normal_velocity.harmonic_components.active=1;
            case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
                boundary.water_level.harmonic_components.active=1;
                boundary.normal_velocity.harmonic_components.active=1;
                boundary.tangential_velocity.harmonic_components.active=1;
            case{'riemann'}
                boundary.riemann.harmonic_components.active=1;
            case{'discharge'}
                boundary.riemann.harmonic_components.active=1;
        end

end
