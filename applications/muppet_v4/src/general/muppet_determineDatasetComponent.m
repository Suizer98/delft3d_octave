function [dataset,d]=muppet_determineDatasetComponent(dataset,d)

%% Determine component
switch dataset.rawquantity
    case{'vector2d','vector3d'}
        if isempty(dataset.component)
            dataset.component='vector';
        end
        % Vector, compute components if necessary
        switch lower(dataset.component)
            case('magnitude')
                d.Val=sqrt(d.XComp.^2+d.YComp.^2);
                dataset.quantity='scalar';
            case('angle (radians)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi);
                dataset.quantity='scalar';
%            case('angledegrees')
            case('angle (degrees)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi)*180/pi;
                dataset.quantity='scalar';
            case{'m-component','m component','mcomponent'}
                alf = dataset.alfas*pi/180;
                switch dataset.plane
                    case{'tz','vz'}
                        xcomp=d.XComp;
                        ycomp=d.YComp;
                        [val1,val2]=muppet_cur2ca(xcomp,ycomp,alf);
                    case{'xy','xz'}
                        xcomp(1,:,:)=d.XComp;
                        ycomp(1,:,:)=d.YComp;
                        alf=alf';
                        [val1,val2]=muppet_cur2ca(xcomp,ycomp,alf);
                end
                d.Val=squeeze(val1);
                dataset.quantity='scalar';
            case{'n-component','n component','ncomponent'}
                alf = dataset.alfas*pi/180;
                switch dataset.plane
                    case{'tz','vz','tv'}
                        xcomp=d.XComp;
                        ycomp=d.YComp;
                        [val1,val2]=muppet_cur2ca(xcomp,ycomp,alf);
                    case{'xy','xz'}
                        xcomp(1,:,:)=d.XComp;
                        ycomp(1,:,:)=d.YComp;
                        alf=alf';
                        [val1,val2]=muppet_cur2ca(xcomp,ycomp,alf);
                end
                d.Val=squeeze(val2);
                dataset.quantity='scalar';
            case{'x-component','x component','xcomponent'}
                d.Val=d.XComp;
                dataset.quantity='scalar';
            case{'y-component','y component','ycomponent'}
                d.Val=d.YComp;
                dataset.quantity='scalar';
        end
end
