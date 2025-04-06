%% exportECGData_offline.m
% This script reads an ECG record from the CUDB database,
% then saves the processed data in a Simulink-compatible format

% --- Step 1: Add WFDB Toolbox to the MATLAB path (run once in MATLAB)
toolboxPath = 'C:\Users\Vram2\Repo\EV-AED\mcode'; % Update this path
if isempty(which('rdsamp'))
    addpath(toolboxPath);
    savepath;
end

% --- Step 2: Specify the record from CUDB
recordId = 'cu01'; % Change to any record between 'cu01' and 'cu36'
fullRecordName = ['cudb/' recordId];

% --- Step 3: Read the ECG record using rdsamp (assume channel 1 contains the ECG)
[rawECG, fs, tm] = rdsamp(fullRecordName, 1);

% --- (Optional) Preprocess the signal, e.g., filtering
% Here we use a bandpass filter between 0.5 and 40 Hz to remove baseline drift and high-frequency noise.
filteredECG = bandpass(rawECG, [0.5 40], fs);

% --- Step 4: Format data for Simulink compatibility
% Create a matrix with time in the first column and ECG data in the second column
simulinkData = [tm, filteredECG];

% Save as a variable named after its intended use in Simulink
ECG_simData = simulinkData;
save('ECGData_sim.mat', 'ECG_simData');

% --- Step 5: Also save in the original structure format for other uses
ECGData.ecg = filteredECG;
ECGData.fs = fs;
ECGData.tm = tm;
ECGData.ts = timeseries(filteredECG, tm, 'Name', ['ECG_' recordId]);
ECGData.ts.TimeInfo.Units = 'seconds';
save('ECGData_struct.mat', 'ECGData');

fprintf('ECG data saved to ECGData_sim.mat and ECGData_struct.mat\n');