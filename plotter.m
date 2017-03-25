function out = plotter(matrix)
figure; hold on; title('ERRORS');
    for i = 1:size(matrix,2)
        plot(matrix(1,i),matrix(2,i),'rx');
    end


end