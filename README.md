# ProjectPortfolio

This is my portfolio.  Project descriptions below:

Notes:  All MATLAB scripts and Simulink models have been verified to run on R2018b and may require the following add-ons: Communications Toolbox, Signal Processing Toolbox, DSP System Toolbox, Control System Toolbox, Statistics and Machine Learning Toolbox, and Communications Toolbox Support Package for Analog Devices ADALM-Pluto Radio.

Voyager_Communications_Simulation.m
- I was inspired by NASA's Voyager mission and it's innovative communications design.  The mission is one of the first, if not THE first, use of a Reed Solomon outer code concatenated with a convolutional inner code.
- The MATLAB script generates random messages, passes them through the two encoders with an interleaver in between, QPSK modulates (I wasn't actually sure what their modulation scheme was) and demodulates through AWGN channel, and then decodes and deinterleaves.  The Bit Error Rate is calculated and plotted.
- Unfortunately, or fortunately depending on your perspective, despite 4 hours of running the simulation with nearly 3 billion bits encoded and decoded, no errors were ever detected in the received message so the sim will run indefinitely (or an extremely long time)!

up_down_sampling_demo.m
- This shows the effects of sampling a signal at one rate and then down sampling or upsampling with interpolation.  
- The demo shows the same signal sampled directly at the same rate as the down and up sampled for comparison.

MSEE Projects:
M_PSK_Simulation.m
- This is a monte carlo simulation of a M-ary PSK modulation and demodulation with Maximum Liklihood symbol detection algorithm.  The purpose is to demonstrate the symbol error rate for a PSK constellation of size M in an AWGN channel at a range of SNRs.

Convolutional_Encoder_VA_Decoder_Sim.m
- This is to demonstrate the Viterbi Algorithm step by step and show it's performance for decoding a [5 7 7] convolutionally encoded random message transmitted over an AWGN channel assuming Hard Decision Decoding.  The upper bounds for both Hard Decision Decoding and Soft Decision Decoding are also plotted to give the viewer a reference.  This sim will take an extremely long time to run if you set the SNR range too wide (>8 hours at least).

