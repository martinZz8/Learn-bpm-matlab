close all %zamkniecie wszystkich otwartych okien
nntwarn off %wylaczenie ostrzezen od strony programu
format compact
load 'winequalityred.mat' %zaladowanie pliku z danymi

%deklaracja stalych
iterate = 0;
S1 = 15;
S2 = 9;
lr = 0.005;
mc = 0.9;

x = length(S1)*length(S2)*length(lr)*length(mc);
y = 6; %liczba parametrow do zapisania w pliku
Parameters = zeros(x, y);

for i_S1 = 1:length(S1)
    for i_S2 = 1:length(S2)
        for i_lr = 1:length(lr)
            for i_mc = 1:length(mc)
                iterate = iterate + 1;
                net = newff(Pns, Ts, [S1(i_S1), S2(i_S2)], {'tansig', 'tansig', 'purelin'},'traingdm', 'learngdm'); %logsig anlbo tansig
                net.divideFcn = 'divideind';
                net.divideParam.trainInd = 1:length(Pns);
                net.divideParam.valInd = 1:length(Pns);
                net.divideParam.testInd = 1:length(Pns);
                net.trainParam.lr = lr(i_lr);
                net.trainParam.mc = mc(i_mc);
                net.trainParam.epochs = 100000;
                net.trainParam.goal = 0.25;
                net.performFcn = 'mse'; %mse
                [net, tr, Y, E] = train(net, Pns, Ts);
                a = sim(net, Pns);
                
                %zapis wyniku procentowego trenowania
                currentPercent = (1 - sum(abs(Ts-a)>=0.5)/length(Pns))*100;
                
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

