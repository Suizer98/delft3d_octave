function plt=axeslimits(plt,opt)

switch opt
    case{'deg2proj'}
        switch plt.projection
            case{'mercator'}
                plt.xminproj=plt.xmin;
                plt.xmaxproj=plt.xmax;
                plt.yminproj=merc(plt.ymin);
                plt.ymaxproj=merc(plt.ymax);
            case{'albers'}
                plt=alberslimits(plt);
            otherwise
                plt.xminproj=plt.xmin;
                plt.xmaxproj=plt.xmax;
                plt.yminproj=plt.ymin;
                plt.ymaxproj=plt.ymax;
        end
    otherwise
end
