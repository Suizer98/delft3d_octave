function [s1,zb,varargout] = belanger (varargin)

%% Initialisation
OPT.g        =     9.81;
OPT.Q        =  10000.0;
OPT.B        =    200.0;
OPT.L        =  10000.0;
OPT.ib       =    1.e-5;
OPT.C        =     55.0;
OPT.depth    =     10.1;
OPT.AorR     =      'R';
OPT.grid     =       [];
OPT.method   =     'tk';

OPT         = setproperty (OPT,varargin);

%% Numerical parameters
if isempty (OPT.grid)
    dx             =   -1.*(OPT.L/10000);
    x              =   0.0:-1.*dx:OPT.L;
else
    x              =   OPT.grid;
end

no_pnt         =   length(x);
eps            =   1e-6;

%% fill parameters with specified values
g              = OPT.g;
Q              = OPT.Q;
B              = OPT.B;
L              = OPT.L;
ib             = OPT.ib;
C              = OPT.C;
AorR           = OPT.AorR;
a(1:no_pnt)    =   NaN;
a(end)         =   OPT.depth;

%% Local water levels (calculate backwards)
for i_pnt      = no_pnt:-1:2
    if ~isempty(OPT.grid)
        dx = x(i_pnt - 1) - x(i_pnt); % dx negative!
    end
    
    if strcmpi(AorR,'r')
        R = (B*a(i_pnt))/(B + 2*a(i_pnt));
    else
        R = a(i_pnt);
    end
    
    u      = Q/(B*a(i_pnt));
    dhdx1  = (ib - abs(u)*u/(C*C*R))/(1 - u*u/(g*a(i_pnt)));
    da_old = dhdx1*dx;
    
    if (strcmp(OPT.method,'tk'))
        diff   = 1e10;
        iter   = 0;
        while diff > eps && iter <= 1000
            iter = iter + 1;
            a_tmp  = a(i_pnt) + da_old;
            if strcmpi(AorR,'r')
                R = (B*a_tmp)/(B + 2*a_tmp);
            else
                R = a_tmp;
            end
            u      = Q/(B*a_tmp);
            da_new = (ib - abs(u)*u/(C*C*R))/(1 - u*u/(g*a_tmp))*dx;
            diff   = abs (da_old - da_new);
            da_old = da_new;
        end
        if iter == 1000
            disp('no convergance');
        end
        a(i_pnt - 1) = a(i_pnt) + da_old;
    elseif strcmpi(OPT.method,'pc');
        % predictor corrector
        a_tmp  = a(i_pnt) + da_old;
        if strcmpi(AorR,'r')
            R = (B*a_tmp)/(B + 2*a_tmp);
        else
            R = a_tmp;
        end
        u      = Q/(B*a_tmp);
        dhdx2 = (ib - abs(u)*u/(C*C*R))/(1 - u*u/(g*a_tmp));
        a(i_pnt - 1) = a(i_pnt) + 0.5*(dhdx1 + dhdx2)*dx;
    else
        diff   = 1e10;
        iter   = 0;
        while diff > eps && iter <= 1000
            iter = iter + 1;
            a_tmp  = a(i_pnt) + da_old;
            if strcmpi(AorR,'r')
                R = (B*a_tmp)/(B + 2*a_tmp);
            else
                R = a_tmp;
            end
            u      = Q/(B*a_tmp);
            dhdx2 = (ib - abs(u)*u/(C*C*R))/(1 - u*u/(g*a_tmp));
            da_new = 0.5*(dhdx1 + dhdx2)*dx;
            diff   = abs (da_old - da_new);
            da_old = da_new;
        end
        if iter == 1000
            disp('no convergance');
        end
        a(i_pnt - 1) = a(i_pnt) + da_old;
        
    end
end


%% Water levels relative to fixed reference plane (NAP like)
zb(no_pnt) =  0;
s1(no_pnt) =  a(no_pnt);
for i_pnt = no_pnt-1:-1:1
    zb(i_pnt) = zb(i_pnt + 1) + ib*(x(i_pnt + 1) - x(i_pnt));
    s1(i_pnt) = zb(i_pnt) + a(i_pnt);
end

varargout{1} = x;





