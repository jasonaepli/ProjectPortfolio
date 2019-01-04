# ProjectPortfolio

This is my portfolio.  Project descriptions below:

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

