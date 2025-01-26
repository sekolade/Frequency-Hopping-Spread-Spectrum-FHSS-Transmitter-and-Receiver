function [audioSignal,txSpectrogram] =  transmitter(category, message, samplingRate, studentNumber)


%     


%% Main Script (Example Usage)
% User Inputs
%category = 1;                      % Category (1, 2, or 3)
%message = '101101';              % Message (binary string)
%samplingRate = 44100;              % Sampling rate
%studentNumber = '2518504';         % Student number

% Generate FHSS Signal
[transmittedSignal, txSpectrogram] = generateFHSSSignal(category, message, samplingRate, studentNumber);

% Simulate transmission (add noise if necessary)

% Display results
disp('Original Message: ' + string(message));
% Future: Decode and validate received message
% Çalınacak ses için sinyali gerçek kısmına indirgeme
audioSignal = real(transmittedSignal);

% Ses çalma
%disp('FHSS sinyali hoparlörden çalınıyor...');
%sound(audioSignal, samplingRate); % Ses çalma (samplingRate ile)

function frequencyTable = generateFrequencyTable(category, studentNumber)
    % Extract student number components
    N7 = str2double(studentNumber(end));
    N6 = str2double(studentNumber(end-1));
    N5 = str2double(studentNumber(end-2));
    % Frequency table for each category
    switch category
        case 1
            b = (mod(N6, 2) == 0) * 2 - 1; % b = 1 if even, -1 if odd
            S = 100 * mod(N7, 5);
            frequencyTable = [1000 + b*S, 1500 + b*S, 2000 + b*S, 2500 + b*S, ...
                              3000 + b*S, 3500 + b*S, 4000 + b*S, 4500 + b*S, 5000 + b*S];
        case 2
            b = (mod(N5, 2) == 0) * 2 - 1;
            S = 100 * N7;
            frequencyTable = [1500 + b*S, 2500 + b*S, 3500 + b*S, 4500 + b*S, ...
                              5500 + b*S, 6500 + b*S, 7500 + b*S, 8500 + b*S];
        case 3
            S = 100 * N7;
            frequencyTable = [1000 + S, 3000 + S, 5000 + S, 7000 + S, 9000 + S, 11000 + S];
        otherwise
            error('Invalid category. Choose 1, 2, or 3.');
    end
end

function binaryData = encodeMessage(message, category)
    % Encode binary message based on FSK type
    switch category
        case 1 % 2-FSK
            binaryData = arrayfun(@(x) str2double(x) * 2 - 1, message); % 0 -> -1, 1 -> 1
        case 2 % 4-FSK
            if mod(length(message), 2) ~= 0
                error('Message length must be a multiple of 2 for 4-FSK.');
            end
            binaryData = [];
            for i = 1:2:length(message)
                bits = message(i:i+1);
                switch bits
                    case '00', binaryData = [binaryData, -2];
                    case '01', binaryData = [binaryData, -1];
                    case '10', binaryData = [binaryData, 1];
                    case '11', binaryData = [binaryData, 2];
                end
            end
        case 3 % 8-FSK
            if mod(length(message), 3) ~= 0
                error('Message length must be a multiple of 3 for 8-FSK.');
            end
            binaryData = [];
            for i = 1:3:length(message)
                bits = message(i:i+2);
                switch bits
                    case '000', binaryData = [binaryData, -4];
                    case '001', binaryData = [binaryData, -3];
                    case '010', binaryData = [binaryData, -2];
                    case '011', binaryData = [binaryData, -1];
                    case '100', binaryData = [binaryData, 1];
                    case '101', binaryData = [binaryData, 2];
                    case '110', binaryData = [binaryData, 3];
                    case '111', binaryData = [binaryData, 4];
                end
            end
        otherwise
            error('Invalid category. Choose 1, 2, or 3.');
    end
end

function [signal, spectrogram3] = generateFHSSSignal(category, message, samplingRate, studentNumber)
    % Parameters for each category
    params.hopPeriod = [1.0, 0.75, 0.50]; % Hop periods for categories
    params.deltaF = [100, 150, 200];      % Delta F values for categories
    
    % Select parameters for the given category
    hopPeriod = params.hopPeriod(category);
    deltaF = params.deltaF(category);
    
    % Generate frequency table
    frequencyTable = generateFrequencyTable(category, studentNumber);
    
    % Encode message
    binaryData = encodeMessage(message, category);
    
    % Generate random hop indices
    rng(42, 'twister'); % For reproducibility
    numHops = length(binaryData);
    hopIndices = randi(length(frequencyTable), 1, numHops)
    FrequencyTable= frequencyTable(hopIndices)
   % hopIndices = [2,9,4,6,4];
    % Initialize signal

    % Generate Pilot Tone
    pilotFreq = 19500; % Example pilot tone frequency (Hz)
    pilotDuration = 0.25; % Pilot tone duration (seconds)
    tPilot = 0:1/samplingRate:pilotDuration - 1/samplingRate;
    pilotTone = sin(2 * pi * pilotFreq * tPilot);
    
    % Initialize signal with pilot tone
    signal = pilotTone;
    freqs = [];
    minf = +inf;
    maxf = -inf;
    for i = 1:numHops
        hopFreq = frequencyTable(hopIndices(i));
        minf = min(minf,hopFreq);
        maxf = max(maxf,hopFreq);
        freq = hopFreq + binaryData(i) * deltaF; % Frequency shift
        freqs = [freqs,freq];
        t = 0:1/samplingRate:hopPeriod;
        signalSegment = exp(1j * 2 * pi * freq * t);
        signal = [signal, signalSegment];
    end
    freqs
    % Plot spectrogram
    windowLength = round(samplingRate * hopPeriod / 4);
    overlapLength = round(windowLength * 0.5);
    fftLength = 2^nextpow2(windowLength);

       %11025

       % 5513

      % 16384
    spectrogram3 = {signal,samplingRate,(windowLength),overlapLength,fftLength,minf,maxf};

    
end
end