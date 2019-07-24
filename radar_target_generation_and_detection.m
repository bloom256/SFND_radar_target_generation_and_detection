clear all
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
FrequencyOfOperation = 77e9;
MaxRange = 200;
RangeResolution = 1;
MaxVelocity = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

SpeedOfLight = 3e8;
%% User Defined Range and Velocity of target
% *%TODO* :
% define the target's initial position and velocity. Note : Velocity
% remains contant
 
TargetRange = 100;
TargetVel = -10;

%% FMCW Waveform Generation

% *%TODO* :
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

Bandwidth = SpeedOfLight / (2 * RangeResolution);
ChirpTime = 5.5 * 2 * MaxRange / SpeedOfLight;
Slope = Bandwidth / ChirpTime;
disp(Slope);
                                                    
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*ChirpTime,Nr*Nd); %total time for samples


%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i=1:length(t)         
    
    
    % *%TODO* :
    %For each time stamp update the Range of the Target for constant velocity. 
    if i > 1
        TargetRange = TargetRange + (TargetVel * (t(i) - t(i - 1))); 
    end
    
    % *%TODO* :
    %For each time sample we need update the transmitted and
    %received signal. 
    Tx(i) = cos(2 * pi * (FrequencyOfOperation * t(i) + Slope * t(i)^2 / 2));
    TripTime = TargetRange / SpeedOfLight * 2;
    Rx(i) = cos(2 * pi * (FrequencyOfOperation * (t(i) - TripTime) + Slope * (t(i) - TripTime)^2 / 2));
    
    % *%TODO* :
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    Mix(i) = Tx(i) * Rx(i);
end

%% RANGE MEASUREMENT


 % *%TODO* :
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.

MixMat = reshape(Mix,[Nr, Nd]);

% *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.

FFT1d = fft(MixMat(:,Nd));

P2_ = abs(FFT1d/Nr);
P1_ = P2_(1:Nr/2+1);
P1_(2:end-1) = 2*P1_(2:end-1);
f_ = Nr*(0:(Nr/2))/Nr;
plot(f_,P1_) 

