close all %zamkniecie wszystkich otwartych okien
clear all
clc
nntwarn off %wylaczenie ostrzezen od strony programu
format compact
load 'winequalityred.mat' %zaladowanie pliku z danymi

%deklaracja stalych
iterate = 0;
S1 = (24:1:30);
S2 = (18:1:20);
lr = 0.01;
mc = (0.8:0.1:0.9);

x = length(S1)*length(S2)*length(lr)*length(mc);
y = 6; %liczba parametrow do zapisania w pliku
Parameters = zeros(x, y);
currentPercent = zeros(length(S1), length(S2), length(lr), length(mc));

for i_S1 = 1:length(S1)
    for i_S2 = 1:length(S2)
        for i_lr = 1:length(lr)
            for i_mc = 1:length(mc)
                iterate = iterate + 1;
                net = newff(Pns, Ts, [S1(i_S1), S2(i_S2)], {'tansig', 'tansig', 'purelin'},'traingdm', 'learngdm'); %logsig albo tansig
                net.divideFcn = 'dividetrain';
                net.trainParam.lr = lr(i_lr);
                net.trainParam.mc = mc(i_mc);
                net.trainParam.epochs = 100000;
                net.trainParam.goal = 0.25;
                net.performFcn = 'mse';
                [net, tr, Y, E] = train(net, Pns, Ts);
                a = sim(net, Pns);
                
                %zapis wyniku procentowego trenowania
                currentPercent(i_S1, i_S2, i_lr, i_mc) = (1 - sum(abs(Ts-a)>=0.5)/length(Pns))*100;
                
                %zapis wynikow do tablicy
                Parameters(iterate, 1) = iterate;
                Parameters(iterate, 2) = S1(i_S1);
                Parameters(iterate, 3) = S2(i_S2);
                Parameters(iterate, 4) = currentPercent(i_S1, i_S2, i_lr, i_mc);
                Parameters(iterate, 5) = lr(i_lr);
                Parameters(iterate, 6) = mc(i_mc);
                save Results Parameters;
                 
            end
        end
    end
end

currentPercent1 = zeros(length(S1), length(S2));
sum = 0;
for j_S1 = 1:length(S1)
    for j_S2 = 1:length(S2)
        for j_lr = 1:length(lr)
            for j_mc = 1:length(mc)
                sum = sum + currentPercent(j_S1, j_S2, j_lr, j_mc);
            end
        end
        currentPercent1(j_S1, j_S2) = sum/(length(lr)*length(mc));
        sum = 0;
    end
end

currentPercent2 = zeros(length(lr), length(mc));
sum = 0;
for j_lr = 1:length(lr)
    for j_mc = 1:length(mc)
        for j_S1 = 1:length(S1)
            for j_S2 = 1:length(S2)
                sum = sum + currentPercent(j_S1, j_S2, j_lr, j_mc);
            end
        end
        currentPercent2(j_lr, j_mc) = sum/(length(S1)*length(S2));
        sum = 0;
    end
end

mesh(S2, S1, currentPercent1)
xlabel('S2');
ylabel('S1');
zlabel('Percentage');
title('F1(S1,S2)');
mesh(mc, lr, currentPercent2)
xlabel('mc');
ylabel('lr');
zlabel('Percentage');
title('F2(lr,mc)');
