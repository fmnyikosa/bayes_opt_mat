function Anew = fixcorrmatrix

Abad = [1.0000	0.7426	0.1601	-0.7000	0.5500;
        0.7426	1.0000	-0.2133	-0.5818	0.5000;
        0.1601	-0.2133	1.0000	-0.1121	0.1000;
        -0.7000	-0.5818	-0.1121	1.0000	0.4500;
        0.5500	0.5000	0.1000	0.4500	1.0000];

x0 = zeros(10,1);

M = zeros(5);
indices = find(triu(ones(5),1));

opts = optimset('Display','iter','maxfunevals',1e4,'TolCon',1e-14,'algorithm','active-set');
x = fmincon(@(x) objfun(x,Abad,indices,M), x0,[],[],[],[],-2,2,...
    @(x) confun(x,Abad,indices,M),opts);

M(indices) = x;
Anew = Abad + M + M';

function E = objfun(x,Abad,indices,M)

M(indices) = x;
Anew = Abad + M + M';

% Set your error condition here
ERR = abs((Anew - Abad)./Abad);
E = max(ERR(:));

function [c,ceq] = confun(x,Abad,indices,M)
ceq = [];

M(indices) = x;
Anew = Abad + M + M';

% Positive definite and every element is between -1 and 1
c = [-min(eig(Anew));
    -1 + max(abs(Anew(:)))];
