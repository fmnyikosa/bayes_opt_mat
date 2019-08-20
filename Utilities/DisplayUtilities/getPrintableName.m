% Returns printable string name from labels for MATLAB display and plot titles
% @author: favour@robots.ox.ac.uk 1/MAY/2017
function readable_name = getPrintableName(acquisitionFunc)
    if strcmp(acquisitionFunc,     'EI1')
        readable_name           = 'EI1';
    elseif strcmp(acquisitionFunc, 'EI2')
        readable_name           = 'EI2';
    elseif strcmp(acquisitionFunc, 'EL' )
        readable_name           = 'EL';
    elseif strcmp(acquisitionFunc, 'UCB')
        readable_name           = 'UCB';
    elseif strcmp(acquisitionFunc, 'LCB')
        readable_name           = 'LCB';
    elseif strcmp(acquisitionFunc, 'EI1_ABO')
        readable_name           = 'EI1';
    elseif strcmp(acquisitionFunc, 'EI2_ABO')
        readable_name           = 'EI2';
    elseif strcmp(acquisitionFunc, 'EL_ABO' )
        readable_name           = 'EL';
    elseif strcmp(acquisitionFunc, 'UCB_ABO')
        readable_name           = 'UCB';
    elseif strcmp(acquisitionFunc, 'LCB_ABO')
        readable_name           = 'LCB';
    elseif strcmp(acquisitionFunc, 'PI')
        readable_name           = 'PI';
    elseif strcmp(acquisitionFunc, 'PI_ABO')
        readable_name           = 'PI';
    elseif strcmp(acquisitionFunc, 'MaxMean_ABO')
        readable_name           = 'MaxMean';
    elseif strcmp(acquisitionFunc, 'MinMean_ABO')
        readable_name           = 'MinMean';
    elseif strcmp(acquisitionFunc, 'MaxMean')
        readable_name           = 'MaxMean';
    elseif strcmp(acquisitionFunc, 'MinMean')
        readable_name           = 'MinMean';
    end
end