% Generate a random message, encode via Reed Solomon (255, 253)
% outer encoder, interleave with depth = 4, followed by constraint length
% K = 7, rate 1/2 convolutional encoder inner code.

clear all;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up variables and objects %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CumulErrors = 0;
bitsSent = 0;
u = 1;
inter_depth = 5;
m = 8;                      % Set the Galois field GF(2^m)
n = 2^m-1; k = 223;         % Codeword length and message length
K = 7;                      % Set convolutional code constraint length
hEnc = comm.RSEncoder(n,k); % Define the RS encoder object
hDec = comm.RSDecoder(n,k); % Define the RS decoder object
hEnc.PrimitivePolynomialSource = 'Property';    
hDec.PrimitivePolynomialSource = 'Property';
hEnc.GeneratorPolynomialSource = 'Auto';
hDec.GeneratorPolynomialSource = 'Auto';
hEnc.PrimitivePolynomial       = gfprimdf(m,2); % Set primitive poly to x^8+x^4+x^3+x^2+1
hDec.PrimitivePolynomial	   = gfprimdf(m,2); % Set primitive poly to x^8+x^4+x^3+x^2+1
bpskModulator = comm.BPSKModulator;             % Create the modulator object
bpskDemodulator = comm.BPSKDemodulator;         % Create the demodulator object

%% %%%%%%%%%%%%%%%%%%%%%%
% Begin Simulation Loop %
%%%%%%%%%%%%%%%%%%%%%%%%%
for SNR = 0:0.5:1.0
    numErrors = 0;
    while(numErrors < 1)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate one random message %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg = randi([0 m-1],k,1);   % Generate symbols for RS encoding
Tx_msg_binary = de2bi(msg);    % Now we need to convert those symbols to bits for BER tracking
Tx_msg_binary = fliplr(Tx_msg_binary); % Re-orients so the top is the MSB
x = 0;
for i = 1:1:size(Tx_msg_binary,1)  % Builds a column vector of bits with top being MSB
    for j = 1:1:size(Tx_msg_binary,2)
        Tx_msg_binary_out(j+x,1) = Tx_msg_binary(i,j);
    end
    x = x + size(Tx_msg_binary,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% Encode via RS encoder %
%%%%%%%%%%%%%%%%%%%%%%%%%
RSencoded = step(hEnc, msg);

%%%%%%%%%%%%%%
% Interleave %
%%%%%%%%%%%%%%
intrlvd = matintrlv(RSencoded,n/inter_depth,inter_depth);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert to binary vector %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
binary = de2bi(intrlvd);
binary = fliplr(binary); % Re-orients so the top is the MSB
x = 0;
for i = 1:1:size(binary,1)  % Builds a column vector of bits with top being MSB
    for j = 1:1:size(binary,2)
        binary_out(j+x,1) = binary(i,j);
    end
    x = x + size(binary,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%
% Convolutional Encode %
%%%%%%%%%%%%%%%%%%%%%%%%
trellis = poly2trellis(K,[171 133]);    % Generates the trellis for the conv encoder
Tx_code = convenc(binary_out,trellis);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mod, Demod, and Channel Effects %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modData = bpskModulator(Tx_code);   % Modulate the data via BPSK
rxSig = awgn(modData,SNR);          % Add white gaussian noise according to desired SNR
Rx_code = bpskDemodulator(rxSig);   % Demodulate the signal vis BPSK

%%%%%%%%%%%%%%%%%%%%
% Viterbi Decoding %
%%%%%%%%%%%%%%%%%%%%
VA_decoded = vitdec(Rx_code,trellis,5*K,'trunc','hard');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert from binary to symbol vector %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = 0;
for i = 1:1:size(VA_decoded,1)/m  
    for j = 1:1:m
        symbol_out(i,j) = VA_decoded(j+x,1);
    end
    x = x + m;
end
Rx_symbol = bi2de(symbol_out,'left-msb');

%%%%%%%%%%%%%%%%%
% Deinterleaved %
%%%%%%%%%%%%%%%%%
deintrlvd = matdeintrlv(Rx_symbol,n/inter_depth,inter_depth);

%%%%%%%%%%%%%%%%%%%%%%%
% Reed Solomon Decode %
%%%%%%%%%%%%%%%%%%%%%%%
msgRx = step(hDec, deintrlvd);

Rx_msg_binary = de2bi(msg);    % Now we need to convert those symbols to bits for BER tracking
Rx_msg_binary = fliplr(Rx_msg_binary); % Re-orients so the top is the MSB
x = 0;
for i = 1:1:size(Rx_msg_binary,1)  % Builds a column vector of bits with top being MSB
    for j = 1:1:size(Rx_msg_binary,2)
        Rx_msg_binary_out(j+x,1) = Rx_msg_binary(i,j);
    end
    x = x + size(Rx_msg_binary,2);
end
% Calculate number of bit errors for the message
[numErrors, errorRatio] = biterr(Tx_msg_binary_out,Rx_msg_binary_out);
bitsSent(u) = bitsSent(u) + size(Tx_msg_binary_out,1);
CumulErrors(u) = CumulErrors(u) + numErrors;
    end
% Calculate the Bit Error Rate at the SNR
BER(u) = CumulErrors(u)/bitsSent(u);
SNR_plot(u) = SNR;
u = u + 1;
end

%% %%%%%%%%%%%%%%%%%%%%
% Plot Bit Error Rate %
%%%%%%%%%%%%%%%%%%%%%%%

semilogy(SNR_plot,BER);
title('NASA Voyager Concatenated Code');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');