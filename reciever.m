function [rxspectrogram,rxspectrogramnon,category] = reciever(samplingRate,duration,app)
% Receiver function with pilot tone synchronization and noise reduction
% Inputs:
%samplingRate = 44100;
%duration = 15;
studentNumber = '2518504'; % String representing the student number
    

% Parameters
pilotFreq = 19500; % Hz, known pilot frequency
pilotDuration = 0.25; % Pilot tone duration in seconds
pilotThreshold = 0.8; % Correlation threshold for detecting the pilot
bufferSize = samplingRate; % Buffer size for real-time processing (1 second)

% Create audio device reader for real-time capture
reader = audioDeviceReader('SamplesPerFrame', bufferSize, 'SampleRate', samplingRate);
%sprintf('Listening for Pilot Tone...')
%currentMessages = app.TextArea.Value;
%app.TextArea.Value =  [currentMessages; {message}];
message= sprintf('Listening for Pilot Tone...');
app.Label.Text = message;
drawnow

% Generate pilot tone reference

tPilot = 0:1/samplingRate:pilotDuration - 1/samplingRate;
pilotTone = sin(2 * pi * pilotFreq * tPilot);

pilotDetected = false;
signalToAnalyze = [];
signalToAnalyzenon = [];
% Design a bandpass filter to reduce noise
% Passband frequencies (frequencies of interest)
passband = [500 12000]; % Hz %500 12700
filterOrder = 6; % Higher order means steeper transitions
[bb1, a1] = butter(filterOrder, passband / (samplingRate / 2), 'bandpass');
passband = [19250, 19750]; % Hz %500 12700
filterOrder = 6; % Higher order means steeper transitions
[bb2, a2] = butter(filterOrder, passband / (samplingRate / 2), 'bandpass');
% Real-time processing loop
% Parameters
pilotFreq = 19500; % Hz, known pilot frequency
pilotDuration = 0.25; % Pilot tone duration in seconds
pilotThreshold = 0.8; % Correlation threshold for detecting the pilot
bufferSize = samplingRate; % Buffer size for real-time processing (1 second)
while ~pilotDetected
    audioBuffer = reader(); % Read audio from microphone
    
    % Apply bandpass filter to reduce noise
    filteredBuffer1 = filter(bb1, a1, audioBuffer);
    filteredBuffer2 = filter(bb2, a2, audioBuffer);
    filteredBuffer = filteredBuffer1 + filteredBuffer2;
    %filteredBuffer = audioBuffer;
    % Perform correlation to detect the pilot tone
    corrResult = xcorr(filteredBuffer, pilotTone);
    corrPeak = max(abs(corrResult));
    if corrPeak > pilotThreshold
        pilotDetected = true;
        %currentMessages = app.TextArea.Value;
        message= sprintf('Pilot tone detected! Synchronizing...');
        %app.TextArea.Value =  [currentMessages; {message}];
        app.Label_2.Text = message;
        drawnow
        % Extract the start point of the pilot tone
        [~, pilotStartIndex] = max(abs(corrResult));
        pilotStartIndex = pilotStartIndex - length(filteredBuffer);
        if pilotStartIndex > 0
            % Extract synchronized signal from the pilot start
            signalToAnalyze = filteredBuffer(pilotStartIndex + length(pilotTone):end);
            signalToAnalyzenon = audioBuffer(pilotStartIndex+ length(pilotTone):end);
                
            %minToneDuration = 0.4; % Minimum duration for a valid tone (in seconds)

            % Clean the signal using the STFT-based noise reduction
            windowLength = round(samplingRate * 0.5 / 4); % Window based on category 3 hop period
            overlapLength = round(windowLength * 0.5);
            fftLength = 2^nextpow2(windowLength);
            %signalToAnalyze = reduceNoiseUsingSTFT(signalToAnalyze, samplingRate, windowLength, overlapLength, fftLength, minToneDuration);
            %signalToAnalyzenon = reduceNoiseUsingSTFT(signalToAnalyzenon, samplingRate, windowLength, overlapLength, fftLength, minToneDuration);
            
        
        end
        break;
    end
end





% Continue recording for the specified duration
while length(signalToAnalyze) < samplingRate * duration
    audioBuffer = reader();
    filteredBuffer1 = filter(bb1, a1, audioBuffer);

    filteredBuffer2 = filter(bb2, a2, audioBuffer);
    filteredBuffer = filteredBuffer1 + filteredBuffer2;
    %filteredBuffer = filter(bb, a, audioBuffer); % Apply noise reduction
    signalToAnalyze = [signalToAnalyze; filteredBuffer];
    signalToAnalyzenon = [signalToAnalyzenon ; audioBuffer];
end





% Truncate to the exact duration
signalToAnalyze = signalToAnalyze(1:samplingRate * duration);
signalToAnalyzenon = signalToAnalyzenon(1:samplingRate * duration);


% Perform STFT to analyze signal spectrogram
windowLength = round(samplingRate * 0.5 / 4); % Window based on category 3 hop period
overlapLength = round(windowLength * 0.5);
fftLength = 2^nextpow2(windowLength);
[s, f, t] = stft(signalToAnalyze, samplingRate, 'Window', hann(windowLength), ...
                 'OverlapLength', overlapLength, 'FFTLength', fftLength);







% Generate frequency tables for all categories
freqTable1 = generateFrequencyTable(1, studentNumber);
freqTable2 = generateFrequencyTable(2, studentNumber);
freqTable3 = generateFrequencyTable(3, studentNumber);

% Plot spectrogram
%figure;
%spectrogram(signalToAnalyze, hann(windowLength), overlapLength, fftLength, samplingRate, 'yaxis');
%caxis([-100 -30]);
%title('Received Signal Spectrogram');
%xlabel('Time (s)');
%ylabel('Frequency (Hz)');

% 6. Analyze the first frequency segment
[~, firstSegmentIdx] = min(abs(t - 0.5)); % First hop period after pilot
firstSegmentMagnitudes = abs(s(:, firstSegmentIdx));
[~, maxMagIdx] = max(firstSegmentMagnitudes);
detectedFrequency = abs(f(maxMagIdx));

% 7. Use detected frequency to identify category
% Generate hop indices for all categories
rng(42, 'twister');
hopIndicesCat1 = randi(length(freqTable1), 1, ceil((length(signalToAnalyze) / samplingRate) / 1));
rng(42, 'twister');
hopIndicesCat2 = randi(length(freqTable2), 1, ceil((length(signalToAnalyze) / samplingRate) / 0.75));
rng(42, 'twister');
hopIndicesCat3 = randi(length(freqTable3), 1, ceil((length(signalToAnalyze) / samplingRate) / 0.5));

% Initialize variables to store total differences
totalDiffCat1 = 0;
totalDiffCat2 = 0;
totalDiffCat3 = 0;

% Analyze all hops for each category
categories = {1, 2, 3};
hopPeriods = [1, 0.75, 0.5];
freqTables = {freqTable1, freqTable2, freqTable3};
hopIndicesList = {hopIndicesCat1, hopIndicesCat2, hopIndicesCat3};

for catIdx = 1:3
    hopPeriod = hopPeriods(catIdx);
    freqTable = freqTables{catIdx};
    hopIndices = hopIndicesList{catIdx};
    
    % Calculate number of hops
    numHops = length(hopIndices); 
    
    % Analyze each hop
    for hopIdx = 1:numHops
        flag = 1;
        % Determine segment midpoint time
        startTime = (hopIdx - 1) * hopPeriod;
        endTime = hopIdx * hopPeriod;
        midPoint = (startTime + endTime) / 2;
        
        % Find the closest time index in the precomputed STFT
        [~, midPointIdx] = min(abs(t - midPoint));
        
        % Find the frequency with maximum magnitude at the midpoint
        segmentMagnitudes = abs(s(:, midPointIdx));
        [~, maxMagIdx] = max(segmentMagnitudes);
        detectedFreq = abs(f(maxMagIdx));
        
        % Get the expected frequency for this hop from freqTable
        expectedFreq = freqTable(hopIndices(hopIdx));
        
        % Calculate frequency difference
        freqDiff = abs(detectedFreq - expectedFreq);
        
        % Accumulate differences for this category
        if flag == 1
            if (catIdx ==1 ) && (freqDiff <= 110 && freqDiff >= 90)
                totalDiffCat1 = totalDiffCat1 + 1;
            elseif (catIdx ==2 ) && ( (freqDiff <= 310 && freqDiff >= 290) || (freqDiff <= 160 && freqDiff >= 140))
                totalDiffCat2 = totalDiffCat2 + 1;

            elseif (catIdx ==3 ) && ((freqDiff <= 210 && freqDiff >= 190) || (freqDiff <= 410 && freqDiff >= 390) || ...
                   (freqDiff <= 610 && freqDiff >= 590) || (freqDiff <= 810 && freqDiff >= 790))
                totalDiffCat3 = totalDiffCat3 + 1;
            else
                flag = 0;
    
            end

        end
    end
end

% Determine category with minimum total difference
%[~, category] = min([totalDiffCat1, totalDiffCat2, totalDiffCat3]);

% Display results



%%
[maxdiff,maxind] = max([totalDiffCat1,totalDiffCat2,totalDiffCat3]);
category = maxind;
%disp(['Detected Category: ', num2str(category)]);

%currentMessages = app.TextArea.Value;
message= sprintf([sprintf('Detected Category: '), num2str(category)]);
%app.TextArea.Value =  [currentMessages; {message}];
app.Label_3.Text = message;
drawnow

% Receiver function with p[ilot tone synchronization
% Updated with FHSS decoding based on Table I

% Existing code to detect category...

% Define FHSS parameters based on category
% Define FHSS parameter['Recommended: ',string(555555)]s based on category
switch category
    case 1
        hopPeriod = 1.0;
        deltaF = 100;
        numHops = maxdiff;
        freqCat = freqTable1(hopIndicesCat1(1:numHops));
        margin = deltaF; % Sadece ±100 aralığında sinyal kabul edilecek
    case 2
        hopPeriod = 0.75;
        deltaF = 150;
        numHops = maxdiff;
        freqCat = freqTable2(hopIndicesCat2(1:numHops));
        margin = 2 * deltaF; % Sadece ±150 ve ±300 aralığında sinyal kabul edilecek
    case 3
        hopPeriod = 0.5;
        deltaF = 200;
        numHops = maxdiff;
        freqCat = freqTable3(hopIndicesCat3(1:numHops));
        margin = 4 * deltaF; % Sadece ±200, ±400, ±600 ve ±800 aralığında sinyal kabul edilecek
end

% Divide the signal into segments based on hopPeriod
%numHops = floor((length(signalToAnalyze) / samplingRate) / hopPeriod);
decodedBinary = ""; % Initialize binary decoded message

minf = +inf;
maxf = -inf;
for hopIdx = 1:numHops
    % Determine segment midpoint time
    startTime = (hopIdx - 1) * hopPeriod;
    endTime = hopIdx * hopPeriod;
    midPoint = (startTime + endTime) / 2;
    
    % Find the closest time index in the precomputed STFT
    [~, midPointIdx] = min(abs(t - midPoint));
    
    % Find the frequency with maximum magnitude at the midpoint
    segmentMagnitudes = abs(s(:, midPointIdx));
    [~, maxMagIdx] = max(segmentMagnitudes);
    detectedFreq = abs(f(maxMagIdx));
    maxf= max(maxf,detectedFreq);
    minf = min(minf,detectedFreq);
    % Get the expected frequency for this hop from freqCat
    expectedFreq = freqCat(hopIdx); 
    
    % Calculate frequency difference and MK value
    freqDiff = detectedFreq - expectedFreq;
    mk = round(freqDiff / deltaF);
    
    % Decode binary message based on MK value
    if category == 1
        if mk == 1
            decodedBinary = strcat(decodedBinary, "1");
        elseif mk == -1
            decodedBinary = strcat(decodedBinary, "0");
        end
    elseif category == 2
        if mk == 2
            decodedBinary = strcat(decodedBinary, "11");
        elseif mk == 1
            decodedBinary = strcat(decodedBinary, "10");
        elseif mk == -1
            decodedBinary = strcat(decodedBinary, "01");
        elseif mk == -2
            decodedBinary = strcat(decodedBinary, "00");
        end
    elseif category == 3
        binaryMap = ["111", "110", "101", "100", "011", "010", "001", "000"];
        if mk >= -4 && mk <= 4
            switch mk
                        case 4
                            decodedBinary = strcat(decodedBinary, binaryMap(1));
                        case 3
                            decodedBinary = strcat(decodedBinary, binaryMap(2));
                        case 2
                            decodedBinary = strcat(decodedBinary, binaryMap(3));
                        case 1
                            decodedBinary = strcat(decodedBinary, binaryMap(4));
                        case -1
                            decodedBinary = strcat(decodedBinary, binaryMap(5));
                        case -2
                            decodedBinary = strcat(decodedBinary, binaryMap(6));
                        case -3
                            decodedBinary = strcat(decodedBinary, binaryMap(7));
                        case -4
                            decodedBinary = strcat(decodedBinary, binaryMap(8));
             end

            
            
        end
    end
end

%ylim([minf/1e3-1, maxf/1e3+1]);
rxspectrogram = {signalToAnalyze, hann(windowLength), overlapLength,fftLength,samplingRate,[minf/1e3-1, maxf/1e3+1]};
rxspectrogramnon = {signalToAnalyzenon, hann(windowLength), overlapLength,fftLength,samplingRate,[minf/1e3-5, maxf/1e3+5]};

% Display final decoded binary message
%currentMessages = app.TextArea.Value;
message= sprintf([sprintf('Decoded Message: '), char(decodedBinary)]);
%app.TextArea.Value =  [currentMessages; {message}];
app.Label_4.Text = message;
drawnow
%disp(['Decoded Binary Message: ', decodedBinary]);



 %%
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




%%
% Function to remove noise based on STFT analysis
function signalCleaned = reduceNoiseUsingSTFT(signal, samplingRate, windowLength, overlapLength, fftLength, minDuration)
    % Perform STFT to analyze signal
    [ss, ff, tt] = stft(signal, samplingRate, 'Window', hann(windowLength), ...
                     'OverlapLength', overlapLength, 'FFTLength', fftLength);

    % Calculate the magnitude spectrogram
    magnitudeSpectrogram = abs(ss);

    % Threshold to identify sustained tones (minimum duration in seconds)
    minFrames = ceil(minDuration / (tt(2) - tt(1))); % Minimum number of frames

    % Identify frequencies that persist for at least minFrames
    [numFreqBins, numTimeFrames] = size(magnitudeSpectrogram);
    persistentTones = false(numFreqBins, numTimeFrames);

    for freqIdx = 1:numFreqBins
        % Find time frames where the magnitude exceeds a threshold (e.g., 10% of max)
        threshold = 0 * max(magnitudeSpectrogram(freqIdx, :));
        activeFrames = magnitudeSpectrogram(freqIdx, :) > threshold;

        % Check for persistence over minFrames
        activeFrames = bwareaopen(activeFrames, minFrames);
        persistentTones(freqIdx, :) = activeFrames;
    end

    % Zero out frequencies that do not persist
    cleanedSpectrogram = ss .* persistentTones;

    % Reconstruct the time-domain signal from the cleaned spectrogram
    signalCleaned = istft(cleanedSpectrogram, samplingRate, 'Window', hann(windowLength), ...
                          'OverlapLength', overlapLength, 'FFTLength', fftLength);
end

end