function wind = meg_padding_win

goon = input('Eliminate artefact(s) (1) or don''t (0) ? : ');

if goon
    na=1;
    wina=zeros(100,2);
    while goon
        fprintf('\n\n ----');
        
        disp(['Time window containing artefact n�',num2str(na)])
        
        wina(na,1) = input('Initial time (s) : ');
        wina(na,2) = input('Final time (s)   : ');
        
        na = na+1;
        
        fprintf('\n ---- \n');

        goon = input('Add a new time window (1) or stop (0) ? : ');
        disp(' ')
    end
    wind = wina(1:na-1,:);
else
    wind = [];
end