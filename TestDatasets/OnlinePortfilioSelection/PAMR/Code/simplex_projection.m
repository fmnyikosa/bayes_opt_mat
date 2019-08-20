function [w] = simplex_projection(v, z)
%% Projection vectors to the simplex domain
% Copyright 2011 by Bin
% Implemented according to the paper: Efficient projections onto the
% l1-ball for learning in high dimensions, John Duchi, et al. ICML 2008.
% Implementation Time: 2011 June 17 by Bin@libin AT pmail.ntu.edu.sg
% Optimization Problem: min_{w}\| w - v \|_{2}^{2} 
%                       s.t. sum_{i=1}^{m}=z, w_{i}\geq 0
% Input: A vector v \in R^{m}, and a scalar z > 0
% Output: Projection vector w

p = size(v, 1);  
rho = p;
w = zeros(size(v));

% Sort v into u in descending order
[u, idx] = sort(v, 'descend');

% Find \rho = max{j \in [n]: u_{j}-(sum(u(1:j, 1))-z)/j >0  }
for j = 1:p,
   if (u(j, 1) - (sum(u(1:j, 1))-z) / j <= 0)
       rho = j - 1;
       break;
   end
end

% Define \theta = (sum(u(1:rho, 1))-z)/rho
theta = (sum(u(1:rho, 1))-z)/rho;

% w_{i}=max{ v_{i} - theta }
w(idx(1:rho, 1), 1) = v(idx(1:rho, 1), 1) - theta;

end