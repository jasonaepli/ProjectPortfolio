% Jason Aepli - Viterbi Decoder (HDD) Monte Carlo Simulation
% This script generates a random message and then convolutionally encodes
% it.  The decoding process is the focus of this simulation so the convec
% function is used, but the Viterbi Algorithm is executed step by step.

%***********************************************************************
%*****************Adjustable Parameters/Initialization******************
%***********************************************************************
clear all;
No = 1/2;
count = 1;
Eb = [0:1:8]';      % Set the range of SNRs to evaluate from
CodeGenerator = [5 7 7];    % Set the convolutional code shift register
ConstraintLength = size(CodeGenerator,2);
%Code Generation
MsgLength = 3;
trellis = poly2trellis(ConstraintLength,CodeGenerator);
Dfree = distspec(trellis);
% Initialize variables
ErrorProb = zeros(1,size(Eb,1));
UnCodedErrorProb = zeros(1,size(Eb,1));
NoError = zeros(1,size(Eb,1)); 
UnCodedNoError = zeros(1,size(Eb,1));
ErrorCount = zeros(1,size(Eb,1));
UnCodedErrorCount = zeros(1,size(Eb,1));


%*******************************************************************
%*********************Begin Main Operating Loop*********************
%*******************************************************************

for power = Eb(1,1):Eb(size(Eb,1),1)/size(Eb,1):Eb(size(Eb,1),1)

    while ErrorCount(1,count)<20
    
        msg = randi([0 1],1,MsgLength);
        TxCodeWord = convenc(msg,trellis);
        
    for a = 1:1:size(TxCodeWord,2)  %Convert to Polar NRZ symbol with noise
        if TxCodeWord(1,a) == 0
            RxSymbol(1,a) = -sqrt(power)+No*randn(1,1);
        else
            RxSymbol(1,a) = sqrt(power)+No*randn(1,1);
        end
    end
    
    for b = 1:1:size(TxCodeWord,2)  %Hard decisions made
        if RxSymbol(1,b) > 0
            RxCodeWord(1,b) = 1;
        else
            RxCodeWord(1,b) = 0;
        end
    end
    
    [Lib, Loca] = ismember(RxCodeWord,TxCodeWord,'rows');
    
    if Loca == 1
        UnCodedNoError(1,count) = UnCodedNoError(1,count) + size(TxCodeWord,2);
    else
        UnCodedErrorCount(1,count) = UnCodedErrorCount(1,count) + sum(abs(RxCodeWord-TxCodeWord),2);
    end

    TracePath = zeros(2^(trellis.numStates-1),trellis.numStates);
    for n = 1:1:2^(trellis.numStates-1)
%Unique Path Decisions Identified
        PathDecisions(n,:) = fliplr(de2bi(n-1,trellis.numStates-1));
%For each time frame, trace which state comes next and their weights
        for t = 1:1:trellis.numStates-1
            if PathDecisions(n,t) == logical(0)
                TracePath(n,t+1) = trellis.nextStates(TracePath(n,t)+1,1);
                PathWeight(n,t) = trellis.outputs(TracePath(n,t)+1,1);
            else TracePath(n,t+1) = trellis.nextStates(TracePath(n,t)+1,2);
                PathWeight(n,t) = trellis.outputs(TracePath(n,t)+1,2);
            end
        end
    end

    %Compare received code with each codeword
    k = 1;
    for frame = 1:3:size(TxCodeWord,2)
        ParsedBits(k,:) = RxCodeWord(1,frame:1:frame+2);
        k = k + 1;
    end
    for i = 1:1:size(PathWeight,1)
        for y = 1:1:size(PathWeight,2)
            PathWeightFrame(y,:) = fliplr(de2bi(PathWeight(i,y),3));
        end
        HammingDist(i,:) = sum(abs(ParsedBits-PathWeightFrame));
    end
    
CWerror = sum(HammingDist,2);

%Make Transmitted CW Decision
[M, BestPath] = min(CWerror);
    
    if sum(abs(msg-PathDecisions(BestPath,:))) == 0
        NoError(1,count) = NoError(1,count) + size(PathDecisions(BestPath,:),2);
    else
        ErrorCount(1,count) = ErrorCount(1,count)+sum(abs(msg-PathDecisions(BestPath,:)));
    end

end
    
UnCodedErrorProb(1,count) = UnCodedErrorCount(1,count)./(UnCodedNoError(1,count)+UnCodedErrorCount(1,count));
ErrorProb(1,count) = ErrorCount(1,count)./(NoError(1,count)+ErrorCount(1,count));
count = count + 1;

end

%Results
EbdB = 10.*log10(Eb);
semilogy(EbdB, ErrorProb);
hold on;
semilogy(EbdB, UnCodedErrorProb);
title(['Monte Carlo Sim for [5 7 7] Convolutional Code']);
xlabel('Eb/No (dB)');
ylabel('Codeword Error Rate');
legend('Simulation','Uncoded','location','southwest');
hold off;