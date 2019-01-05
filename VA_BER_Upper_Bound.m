%This computes the Viterbi Algorithm HDD and SDD upper bound on BER
clear all;
k = 1;
dfree = 8;
No = 1;
count = 1;
Rc = 1/3;

for Eb = 0.5:0.5:8
    P = 1-cdf('normal',0,sqrt(Eb),No);
    Y1 = exp(-1*Eb/No*Rc);
    Y2 = sqrt(4*P*(1-P));
    Bdfree = 1;
    
    SDDber(1,count) = 1/k*((Y1)^8+6*(Y1)^21+9*(Y1)^26);
    HDDber(1,count) = 1/k*((Y2)^8+6*(Y2)^21+9*(Y2)^26);
    
    EbdB(1,count) = 10*log10(Eb);
    count = count + 1;
end


semilogy(EbdB,SDDber);
hold on
semilogy(EbdB,HDDber);
title('HDD vs SDD BER Bounds');
legend('SDD','HDD','Location','southwest');
