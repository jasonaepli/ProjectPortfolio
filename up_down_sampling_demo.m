% Creating my own simulation of up and down sampling.  Begins by generating
% a 200 Hz sine wave, then samples it at 2000 Hz.  The digital version is
% plotted.  Next the digital samples are down sampled to 1/2 the rate (1000
% Hz) and the result is plotted.  Finally, the original 200 Hz sine wave is
% upsampled to 6000 Hz and plotted.

clear all;

% All frequency values are in Hz.
Fs = 2000;      % Sampling Frequency
Forig = 200;    % Original sine wave frequency

% Filter specifications
N     = 20;     % Order
Fpass = 200;    % Passband Frequency
Fstop = 300;    % Stopband Frequency
Wpass = 1;      % Passband Weight
Wstop = 1;      % Stopband Weight

% Calculate the coefficients using the FIRLS function.
b  = firls(N, [0 Fpass Fstop Fs/2]/(Fs/2), [1 1 0 0], [Wpass Wstop]);
%H = dsp.FIRFilter(b);
%figure;
%freqz(b,1,256)

% Generate the sine wave
sin_orig = dsp.SineWave(1,Forig,0,'SampleRate',Fs,'SamplesPerFrame',2*Fs/Forig);
y = sin_orig();
figure;
subplot(3,2,3);
plot(y);
title('Original Signal');
xlabel('Hertz');

% Down sample
sin_down = downsample(sin_orig(),2);
subplot(3,2,1);
plot(sin_down);
title(['Down Sampled at ',num2str(Fs/2),' Hz']);
xlabel('Hertz');

% Up Sampled
sin_up = upsample(sin_orig(),3);
sin_up_interp = filter(b,1,sin_up);

% Plot
subplot(3,2,5);
plot(sin_up_interp);
title(['Up Sampled at ',num2str(3*Fs),' Hz and interpolated']);
xlabel('Hertz');

subplot(3,2,4);
plot(y);
title('Original Signal');
xlabel('Hertz');
subplot(3,2,2);
x = dsp.SineWave(1,Forig,0,'SampleRate',Fs/2,'SamplesPerFrame',2*(Fs/2)/Forig);
plot(x());
title(['Directly Sampled at ',num2str(Fs/2),' Hz']);
xlabel('Hertz');
subplot(3,2,6);
z = dsp.SineWave(1,Forig,0,'SampleRate',3*Fs,'SamplesPerFrame',2*(3*Fs)/Forig);
plot(z());
title(['Directly Sampled at ',num2str(3*Fs),' Hz']);
xlabel('Hertz');
disp(['The graphs on the left hand side show how the signal is distorted by up or down sampling after originally sampling the signal at ',num2str(Fs),' Hz.  The right hand side shows how it would look if the wave is directly sampled at either ',num2str(Fs/2),' Hz and ',num2str(3*Fs),' Hz.']);
