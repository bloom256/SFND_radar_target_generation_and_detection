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
 
TargetRange = 30;
TargetVel = 5;

%% FMCW Waveform Generation

% *%TODO* :
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

Bandwidth = SpeedOfLight / (2 * RangeResolution);
ChirpTime = 5.5 * 2 * MaxRange / SpeedOfLight;
Slope = Bandwidth / ChirpTime;
disp(Slope);
