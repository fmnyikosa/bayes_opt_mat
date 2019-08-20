%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Favour Mandanji Nyikosa (favour@robots.ox.ac.uk)
% January, 30 2015
% generate data from previous time steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% n 	 - number of time steps
% n_obsv - number of data points observed per timestep
% gap    - steo factor in incrementing time variable t
%


function [input_data, output_data, time_tag] = getDynFuncObservedData( n , n_obsv, gap )
 	D = 2;
 	minB = 0;
 	maxB = 5;
	input_data_temp =  minB + (maxB - minB) .* lhsdesign( n.*n_obsv, D);
    input_data_temp(1,:) = [2, 3.5];
    input_data_temp(3,:) = [2, 4.1];
    input_data_temp(5,:) = [2, 3];
    input_data_temp(7,:) = [1.32, 3.5];
    input_data_temp(14,:) = [2.6, 3.5];
	input_data  = zeros( n, D+1 );
	output_data = zeros( n, 1 );
	time_tag = 0;
	k = 1;
	for i = 1:n
		for j = 1:n_obsv
		   p_temp = input_data_temp(k,:);
		   input_data(k,:) = [ time_tag, p_temp ];
		   output_data(k,:) = dyn_func( time_tag, p_temp(1), p_temp(2) );
		   k = k + 1;
		end
		time_tag = time_tag + gap;
	end
end
