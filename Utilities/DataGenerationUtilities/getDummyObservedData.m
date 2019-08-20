%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Favour Mandanji Nyikosa (favour@robots.ox.ac.uk)
% January, 30 2015
% generate data from previous time steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [input_data, output_data] = getDummyObservedData( signal )

	[n, D ]= size( signal ); % n - number of points, D - dimensionality
	input_data_temp =  rand([n, D] );
	input_data = zeros( n, D+1 );
	output_data = zeros( n, 1 );
	parfor i = 1:n
	   time_tag = -( n - (i - 1) ) + 1;
	   p_temp = input_data_temp(i,:);
	   p_temp = 1./sum(p_temp) .* input_data_temp(i,:);
	   input_data(i,:) = [ time_tag, p_temp ];
	   output_data(i,:) = getBulkRewards( input_data(i,:), signal(i,:) );
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function u = getBulkRewards(opt_i, m)
    w = opt_i(:, 2:end);
    out = w * m'; 
    u = out;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%