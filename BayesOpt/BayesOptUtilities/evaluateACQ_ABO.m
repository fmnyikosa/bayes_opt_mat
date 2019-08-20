% Evaluates acuition function at x0 outside optimisation context but within
% doBayesopt function.
% @author: favour@robots.ox.ac.uk 19/MAY/2017
function acq = evaluateACQ_ABO(x0, boSettings)
    %  define variables for acquisition function handles
    FUNC1              = @(x) acquisitionEI1(x, boSettings);
    FUNC2              = @(x) acquisitionEI2(x, boSettings);
    FUNC3              = @(x) acquisitionEL(x, boSettings);
    FUNC4              = @(x) acquisitionUCB(x, boSettings);
    FUNC5              = @(x) acquisitionLCB(x, boSettings);
    FUNC6              = @(x) acquisitionEI1_ABO(x, boSettings);
    FUNC7              = @(x) acquisitionEI2_ABO(x, boSettings);
    FUNC8              = @(x) acquisitionEL_ABO(x, boSettings);
    FUNC9              = @(x) acquisitionUCB_ABO(x, boSettings);
    FUNC10             = @(x) acquisitionLCB_ABO(x, boSettings);
    FUNC11             = @(x) acquisitionPI(x, boSettings);
    FUNC12             = @(x) acquisitionPI_ABO(x, boSettings);
    
    FUNC18             = @(x) acquisitionMaxMean(x, boSettings);
    FUNC19             = @(x) acquisitionMinMean(x, boSettings);
    FUNC20             = @(x) acquisitionMaxMean_ABO(x, boSettings);
    FUNC21             = @(x) acquisitionMinMean_ABO(x, boSettings);
    %  obtain acquisition function settings
    acquisitionFunc    = boSettings.acquisitionFunc;
    
    if strcmp(acquisitionFunc,     'EI1')
        FUNC           = FUNC1;
    elseif strcmp(acquisitionFunc, 'EI2')
        FUNC           = FUNC2;
    elseif strcmp(acquisitionFunc, 'EL' )
        FUNC           = FUNC3;
    elseif strcmp(acquisitionFunc, 'UCB')
        FUNC           = FUNC4;
    elseif strcmp(acquisitionFunc, 'LCB')
        FUNC           = FUNC5;
    elseif strcmp(acquisitionFunc, 'EI1_ABO')
        FUNC           = FUNC1;
    elseif strcmp(acquisitionFunc, 'EI2_ABO')
        FUNC           = FUNC2;
    elseif strcmp(acquisitionFunc, 'EL_ABO' )
        FUNC           = FUNC3;
    elseif strcmp(acquisitionFunc, 'UCB_ABO')
        FUNC           = FUNC4;
    elseif strcmp(acquisitionFunc, 'LCB_ABO')
        FUNC           = FUNC5;
    elseif strcmp(acquisitionFunc, 'PI')
        FUNC           = FUNC11;
    elseif strcmp(acquisitionFunc, 'PI_ABO')
        FUNC           = FUNC12;
    elseif strcmp(acquisitionFunc, 'MaxMean')
        FUNC           = FUNC18;
    elseif strcmp(acquisitionFunc, 'MinMean')
        FUNC           = FUNC19;
    elseif strcmp(acquisitionFunc, 'MaxMean_ABO')
        FUNC           = FUNC18;
    elseif strcmp(acquisitionFunc, 'MinMean_ABO')
        FUNC           = FUNC19;    
      
    end
    acq = FUNC(x0);
end