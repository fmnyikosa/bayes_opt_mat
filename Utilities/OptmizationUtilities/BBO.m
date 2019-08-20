function BBO
% Biogeography-based optimization (BBO) to minimize a continuous function
% This program was tested with MATLAB R2012b

GenerationLimit = 50; % generation count limit 
PopulationSize = 50; % population size
ProblemDimension = 20; % number of variables in each solution (i.e., problem dimension)
MutationProbability = 0.04; % mutation probability per solution per independent variable
NumberOfElites = 2; % how many of the best solutions to keep from one generation to the next
MinDomain = -2.048; % lower bound of each element of the function domain
MaxDomain = +2.048; % upper bound of each element of the function domain

% Initialize the population
rng(round(sum(100*clock))); % initialize the random number generator
x = zeros(PopulationSize, ProblemDimension); % allocate memory for the population
for index = 1 : PopulationSize % randomly initialize the population
    x(index, :) = MinDomain + (MaxDomain - MinDomain) * rand(1, ProblemDimension);
end
Cost = RosenbrockCost(x); % compute the cost of each individual  
[x, Cost] = PopulationSort(x, Cost); % sort the population from best to worst
MinimumCost = zeros(GenerationLimit, 1); % allocate memory
MinimumCost(1) = Cost(1); % save the best cost at each generation in the MinimumCost array
disp(['Generation 0 min cost = ', num2str(MinimumCost(1))]);
z = zeros(PopulationSize, ProblemDimension); % allocate memory for the temporary population

% Compute migration rates, assuming the population is sorted from most fit to least fit
mu = (PopulationSize + 1 - (1:PopulationSize)) / (PopulationSize + 1); % emigration rate
lambda = 1 - mu; % immigration rate

for Generation = 1 : GenerationLimit
    % Save the best solutions and costs in the elite arrays
    EliteSolutions = x(1 : NumberOfElites, :);
    EliteCosts = Cost(1 : NumberOfElites);

    % Use migration rates to decide how much information to share between solutions
    for k = 1 : PopulationSize
        % Probabilistic migration to the k-th solution
        for j = 1 : ProblemDimension

            if rand < lambda(k) % Should we immigrate?
                % Yes - Pick a solution from which to emigrate (roulette wheel selection)
                RandomNum = rand * sum(mu);
                Select = mu(1);
                SelectIndex = 1;
                while (RandomNum > Select) && (SelectIndex < PopulationSize)
                    SelectIndex = SelectIndex + 1;
                    Select = Select + mu(SelectIndex);
                end
                z(k, j) = x(SelectIndex, j); % this is the migration step
            else
                z(k, j) = x(k, j); % no migration for this independent variable
            end

        end
    end

    % Mutation
    for k = 1 : PopulationSize
        for ParameterIndex = 1 : ProblemDimension
            if rand < MutationProbability
                z(k, ParameterIndex) = MinDomain + (MaxDomain - MinDomain) * rand;
            end
        end
    end

    x = z; % replace the solutions with their new migrated and mutated versions
    Cost = RosenbrockCost(x); % calculate cost
    [x, Cost] = PopulationSort(x, Cost); % sort the population and costs from best to worst

    for k = 1 : NumberOfElites % replace the worst individuals with the previous generation's elites
        x(PopulationSize-k+1, :) = EliteSolutions(k, :);
        Cost(PopulationSize-k+1) = EliteCosts(k);
    end

    [x, Cost] = PopulationSort(x, Cost); % sort the population and costs from best to worst
    MinimumCost(Generation+1) = Cost(1);
    disp(['Generation ', num2str(Generation), ' min cost = ', num2str(MinimumCost(Generation+1))])
end

% Wrap it up by displaying the best solution and by plotting the results
disp(['Best solution found = ', num2str(x(1, :))])
close all
plot(0:GenerationLimit, MinimumCost);
xlabel('Generation')
ylabel('Minimum Cost')
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, Cost] = PopulationSort(x, Cost)
% Sort the population and costs from best to worst
[Cost, indices] = sort(Cost, 'ascend');
x = x(indices, :);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Cost] = RosenbrockCost(x)
% Compute the Rosenbrock function value of each element in x
NumberOfDimensions = size(x, 2);
Cost = zeros(size(x, 1), 1); % allocate memory for the Cost array
for PopulationIndex = 1 : length(x)
    Cost(PopulationIndex) = 0;
    for i = 1 : NumberOfDimensions-1
        Temp1 = x(PopulationIndex, i);
        Temp2 = x(PopulationIndex, i+1);
        Cost(PopulationIndex) = Cost(PopulationIndex) + 100 * (Temp2 - Temp1^2)^2 + (Temp1 - 1)^2;
    end
end
return