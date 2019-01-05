% Jason Aepli - This script runs a lossy audio compression algorithm that selects
% a chunk of audio data from a .wav file, applies a window function to enhance 
% the spectral characteristics, and calculates the FFT of the selected and 
% windowed data.  From the FFT, the algorithm chooses only the "most
% significant" spectral information (n of the peaks to be exact) and zeroes
% the rest.  Then the algorithm synthesizes the audio file from the
% compressed data.  The script runs the algorithm for varying sizes of n to
% show how reducing the compression ratio (N/n) improves audio quality.

clear all;
N = 256; % Size of the FFT/IFFT and window
S = load('handel.mat');
audiowrite('handel.wav',S.y,S.Fs);
[X1,fs] = audioread('handel.wav');
Xn = [X1' zeros(1,N*ceil(size(X1,1)/N)-size(X1,1))];
%sound(X1,fs);
n = (N/2+1); % n is the amount of data retained in each compression run


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Triangular Window %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for x = 1:N  % 
        if x <= N/2
            Wn(1,x) = 2*x/N;
        else
            Wn(1,x) = 2-2*x/N;
        end
end

%% %%%%%%%%%%
% Main Loop %
%%%%%%%%%%%%%
for n = 1:(N/2+1)
for a = 1:ceil(length(Xn)/N)
         
    X = Wn.*Xn(((a-1)*N+1):a*N); % Select a chunk of data of size N and apply the window to it
    
    Xk = fft(X,N);  % Generate spectral information of the windowed data chunk
    
    peaks = sort(Xk,'descend');
    minpwr = peaks(1,n);
    for x = 1:N
        if Xk(1,x) >= minpwr
           Yk(n,x) = Xk(1,x);
        else
           Yk(n,x) = 0;
        end
    end
    
    Yn1 = ifft(Yk(n,:),N);
    Output(n,((a-1)*N+1):a*N) = Yn1(1:N);

end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Output Audio Files %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
audiowrite('Decompressed_Output.wav',Output(n,:)',fs);

%% %%%%%%%%%%%%%%%
% Calculate SNRs %
%%%%%%%%%%%%%%%%%%
for z = 1:(N/2+1)
    SNR1(1,z)=10*log10(sum(Xn.^2)./sum((Xn-abs(Output(z,:))).^2));
end

%% %%%%%%%%%%%%%%%%%
% Plot the results %
%%%%%%%%%%%%%%%%%%%%
x = 1/N*100:1/N*100:n/N*100;
plot(x,SNR1')
title('Effect of n and N with triangular window and method 1');
xlabel('n/N (%)');
ylabel('SNR(dB)');
