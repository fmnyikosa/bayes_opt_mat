function draw_partition_tree(t,settings)

UCBK = log((settings.nb_iter)^2/settings.delta)/2;

for h=1:settings.h_max
    for i=1:numel(t{h}.x)
        
        %         plot([t{h}.x(i) t{h}.x(i)],[settings.axis(3)+0.71 settings.axis(3)+0.69],'-k');
        
        if ((t{h}.leaf(i) == 1))
            plot([t{h}.x(i) t{h}.x(i)],[(settings.axis(3)+1) (settings.axis(3)+1+0.1*h)],'-r','Linewidth',3);
            %             text(t{h}.x(i),settings.axis(3)+3,sprintf('%d',h));
        end
        %         if (t{h}.leaf(i) == 1)
        %             ag_set_pen_color(AG_BLACK);
        
        %         plot([t{h}.x_min(i) t{h}.x_min(i)],[settings.axis(3)+0.8 settings.axis(3)+0.6],'-k');
        %         plot([t{h}.x_max(i) t{h}.x_max(i)],[settings.axis(3)+0.8 settings.axis(3)+0.6],'-k');
        %
        
        
        %             ag_line(dyv_ref(x_min[h],i),0.02,dyv_ref(x_min[h],i),-0.02);
        %             ag_line(dyv_ref(x_max[h],i),0.02,dyv_ref(x_max[h],i),-0.02);
        %         ag_set_pen_color(AG_BLUE);
        %             plot(t{h}.x(i),t{h}.y(i),'sr','MarkerSize',3);
        if ~isempty(t{h}.values{i})
            plot(t{h}.x(i),t{h}.values{i},'og','MarkerSize',5,'MarkerFaceColor','green');
        end
        
        meanF = t{h}.sums(i)/t{h}.ks(i);
        if (t{h}.ks(i) > 0)
            switch settings.type
                case 'sto',  b_hi = meanF + sqrt(UCBK/t{h}.ks(i));
                otherwise,  b_hi = meanF;
            end
        else
            b_hi = inf;
        end
        
        %             ag_set_pen_color(AG_BLACK);
        if ((t{h}.leaf(i) == 1))
            plot(t{h}.x(i),meanF,'+k','MarkerSize',7,'MarkerFaceColor','blue');
            plot(t{h}.x(i),b_hi,'^b','MarkerSize',4,'MarkerFaceColor','blue');
            %             ag_set_pen_color(AG_GREEN);
            plot(t{h}.x(i),b_hi);
            c = sprintf('%d',t{h}.ks(i));
            %             ag_set_pen_color(AG_BLACK);
            text(t{h}.x(i)+0.005,b_hi+0.005,c);
        end
        % 	printf("i: %f, b_hi: %f, y_hi: %f, mean: %f, ks: %d \n",...
        %             dyv_ref(x[h],i),b_hi,dyv_ref(y[h],i),meanF, ivec_ref(ks[h],i));
        %         end
    end
end
axis(settings.axis)
drawnow

