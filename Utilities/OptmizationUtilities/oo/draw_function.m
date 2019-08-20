function draw_function(x_min,x_max,f,output)
if nargin < 4
    output =   0;
end

cla
hold on
x=x_min;

xseries = x:(x_max-x_min) * 0.001:x_max;
yseries = arrayfun(f,xseries);
plot(xseries,yseries,'Linewidth',3,'Color',[0 0 0]);

% while 1
%     y = f(x);
%     plot((x-x_min)/(x_max-x_min), y);
%     x= x+ (x_max-x_min) * 0.001;
%     if x>=x_max; break; end
% end
axis([0 1 -0.3 1.3]);

if output
    box on
    make_this_figure_tight
    saveas(gcf,output);
end