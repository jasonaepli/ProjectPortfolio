% This script generates a random M-ary PSK symbol, both In phase and
% Quadrature components, corrupst with noise, and then runs through a
% Maximum Liklihood detection algorithm.  The purpose is to demonstrate the
% symbol error rate for a given constellation of size M over a range of
% SNRs.

%Adjustable Parameters/Initialization
No = 1;
M = 16;
m = randsample(1:M,1);
I = 0;
Eb = [0.5:0.5:10]';
Es = Eb.*log2(M);
Sx = zeros(size(Eb,1),M);
Sy = zeros(size(Eb,1),M);
Dx = zeros(size(Eb,1),M);
Dy = zeros(size(Eb,1),M);
Rx = zeros(size(Eb,1),1);
Ry = zeros(size(Eb,1),1);
ErrorProb = zeros(size(Eb,1),1);
NoError = zeros(size(Eb,1),1); 
ErrorCount = zeros(size(Eb,1),1);
TxSymbol = zeros(size(Eb,1),1);
dist = zeros(size(Eb,1),M);

% Begin Main Operating Loop
while min(ErrorCount)<20
i = [1:1:M]';
n1 = normrnd(0,No/2,size(Eb,1),1);
n2 = normrnd(0,No/2,size(Eb,1),1);
Sx = (bsxfun(@times,sqrt(Es'),cos(2*pi*(i-1)/M)))';
Sy = (bsxfun(@times,sqrt(Es'),sin(2*pi*(i-1)/M)))';   
Rx = (sqrt(Es)*cos(2*pi*(m-1)/M))+n1;
Ry = (sqrt(Es)*sin(2*pi*(m-1)/M))+n2;

%Decision Made
for j = 1:1:size(Eb,1)
    Dx(j,:) = pdist2(Rx(j,1),Sx(j,:)','euclidean','Smallest',1);
    Dy(j,:) = pdist2(Ry(j,1),Sy(j,:)','euclidean','Smallest',1);
end

dist = sqrt(Dx.^2+Dy.^2);
[C,I] = min(dist,[],2);

%Did Error Occur?
TxSymbol = ones(size(Eb,1),1).*m;

for a = 1:1:size(Eb,1);
    if isequal(I(a,1),TxSymbol(a,1)) == 1;
       NoError(a,1) = NoError(a,1) + 1;
    else
       ErrorCount(a,1) = ErrorCount(a,1) + 1;
    end
end
        
%Once At Least 20 Errors For A Given Eb Have Occured Loop Exits
end
    
%Results
ErrorProb = ErrorCount./(NoError+ErrorCount);

EbdB = 10.*log10(Eb);
semilogy(EbdB, ErrorProb);

Mary = 'M = %d';
Title = 'Monte Carlo Sim for M = %d';
str1 = sprintf(Mary,M);
str2 = sprintf(Title,M);
legend(str1);
title(str2);
xlabel('Eb/No (dB)');
ylabel('M-PSK Probability of Error');
