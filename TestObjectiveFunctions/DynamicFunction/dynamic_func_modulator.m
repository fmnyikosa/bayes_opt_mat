% Favour M Nyikosa (favour@robpots.ox.ac.uk)
% Dec-1-2016
% Input: 
%       a - amplitute/strengtth of attenuation
%       t - time variable
%       p - period
% Output:
%       mod -  modulation that pre-multiplies function output

function mod = dynamic_func_modulator( a, t, p )
% modulator function that changes over time

temp = a * sin(t/p);
mod = exp( temp );

end

