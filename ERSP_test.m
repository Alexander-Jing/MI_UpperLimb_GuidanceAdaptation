%-----------------------------------------------------------------------
% From https://zh-1-peng.gitbook.io/eeg-analysis-note/ersp
%-----------------------------------------------------------------------
D = 2; %signal duration
S = 1000; % sampling rate, i.e. N points pt sec used to represent sine wave
F = [10 20 45]; % 4 frequencies in Hz
w = 2*pi*F; % convert frequencies to radians
P = [0 .5 .25]; % 4 corresponding phases
A = [1 .5 .3]; % corresponding amplitudes
T = 1/S; % sampling period, i.e. for this e.g. points at 1 ms intervals
t = [T:T:D]; % time vector %NB this has been corrected from previous version
mysig=zeros(1,length(t)); %initialise mysig
myphi=2*pi*P; % compute phase angle
nfreqs=length(F); % N frequencies in the complex
% Add all sine waves together to give composite
for thisfreq=1:nfreqs
    mysig = mysig+A(thisfreq)*(sin(w(thisfreq)*t + myphi(thisfreq)));
end

A(2)=2; %amplitude of 2nd frequency increased from 1 to 2
mysig2=zeros(1,length(t)); %initialise mysig2
for thisfreq=1:nfreqs
    mysig2 = mysig2+A(thisfreq)*(sin(w(thisfreq)*t + myphi(thisfreq)));
end
mysig(500:1000)=mysig2(500:1000);
%t=t-.5; %subtract 500 ms to indicate first 500 ms are baseline, i.e. -ve time
%figure; %plot(t,mysig);
%xlabel('Time (seconds)');
%ylabel('Amplitude');

[ersp,itc,powbase,times,freqs]=newtimef( mysig,2000,[-500 1500],1000, 0,'plotitc','off');

% log info========================================================
% Computing Event-Related Spectral Perturbation (ERSP) and
% Inter-Trial Phase Coherence (ITC) images based on 1 trials
% of 2000 frames sampled at 1000 Hz.
% Each trial contains samples from -500 ms before to
% 1500 ms after the timelocking event.
% Image frequency direction: normal
% Adjust min freq. to 1.95 Hz to match FFT output frequencies
% Adjust max freq. to 50.78 Hz to match FFT output frequencies
% Using hanning FFT tapering
% Generating 200 time points (-371.9 to 1371.9 ms) !!!!!!
% Finding closest points for time variable
% Time values for time/freq decomposition is not perfectly uniformly distributed
% The window size used is 256 samples (256 ms) wide.
% Estimating 26 linear-spaced frequencies from 2.0 Hz to 50.8 Hz.
