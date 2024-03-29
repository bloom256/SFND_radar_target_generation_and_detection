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
TargetVel = -20;

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
axis ([0 200 0 1]);

%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM


% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure,surf(doppler_axis,range_axis,RDM);


%% CFAR implementation

Tr = 10;
Td = 8;
Gr = 4;
Gd = 4;
offset = 10;
result = zeros(size(RDM));
for i = 1 + Tr + Gr : Nr / 2 - (Gr + Tr)
    for j = 1 + Td + Gd : Nd - (Td + Gd)
        
        noise_level = 0;
        for p = i - (Tr + Gr) : i + Tr + Gr
            for q = j - (Td + Gd) : j + Td + Gd
                if (abs(i - p) > Gr || abs(j - q) > Gd)
                    noise_level = noise_level + db2pow(RDM(p, q));                    
                end
            end
        end
        threshold = pow2db(noise_level / (2 * (Td + Gd + 1) * 2 * (Tr + Gr + 1) - (Gr * Gd) - 1));
        threshold = threshold + offset;
        CUT = RDM(i, j);
        
        if (CUT < threshold)
            result(i, j) = 0;
        else
            result(i, j) = 1;
        end
    end
end

figure,surf(doppler_axis,range_axis,result);
colorbar;


 
