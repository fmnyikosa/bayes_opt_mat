function demo_stats()
% Demo the calculation of stats

fprintf(1, 'P(B)\t& G(B)\t& P(C)\t& G(C)\t& P(D)\t& G(A)\t& G(Market)\n');
fprintf(1, '---------------------------------------------------------\n');

% High frequency trading
calStat('dja', 0.998);
calStat('ndx', 0.998);

% Daily 
calStat('tse', 0.985);
calStat('msci', 0.985);
calStat('nyse_o', 0.985);
calStat('nyse_n', 0.985);

% Weekly
calStat('week_nyse_o', 0.985);
calStat('week_nyse_n', 0.985);

fprintf(1, '---------------------------------------------------------\n');
fprintf(1, 'P(B)\t& G(B)\t& P(C)\t& G(C)\t& P(D)\t& G(A)\t& G(Market)\n');

end