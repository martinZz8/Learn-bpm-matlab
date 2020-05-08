close all %zamkniecie wszystkich otwartych okien
nntwarn off %wylaczenie ostrzezen od strony programu
format compact
load 'winequalityred.mat' %zaladowanie pliku z danymi

%deklaracja stalych
iterate = 0;
S1 = 5;
S2 = 3;
lr = 0.01;
mc = 0.9;

x = length(S1)*length(S2)*length(lr)*length(mc);
y = 6;
Parameters = zeros(x, y);

for i_S1 = 1:length(S1)
    for i_S2 = 1:length(S2)
        for i_lr = 1:length(lr)
            for i_mc = 1:length(mc)
                iterate = iterate + 1;
                net = newff(Pn, T, [S1(i_S1), S2(i_S2)], {'logsig', 'logsig', 'purelin'}, ...
                    'learngdm');
                net.divideFcn = 'divideind';
                net.divideParam.trainInd = 1:length(Pn);
                net.divideParam.valInd = 1:length(Pn);
                net.divideParam.testInd = 1:length(Pn);
                net.trainParam.lr = lr(i_lr);
                net.trainPrarm.mc = mc(i_mc);
                net.trainParam.epochs = 1000;
                net.trainParam.goal = 0.25;
                net = train(net, Pn, T);
                a = sim(net, Pn);
                
                %zapis wyniku procentowego trenowania
                currentPercent = (1 - sum(abs(T-a)>0.5)/length(P))*100;
                
                %zapis wyników do tablicy
                Parameters(iterate, 1) = iterate;
                Parameters(iterate, 2) = S1(i_S1);
                Parameters(iterate, 3) = S2(i_S2);
                Parameters(iterate, 4) = currentPercent;
                Parameters(iterate, 5) = lr(i_lr);
                Parameters(iterate, 6) = mc(i_mc);
                save Results Parameters;
                
                %mesh(S1, S2, currentPercent);
                
            end
        end
    end
end

