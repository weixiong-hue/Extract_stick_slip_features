%====================================================================================================================================

%This code aims to extract stick-slip events and related stick-slip features from the friction coefficient curve of shear bands
%When in use, a text file of the friction coefficient curve ('input_data.dat') needs to be inputted each time, and a result file will be output after running ('output.txt'). 
%The result file includes the five stick-slip features including the number of stick-slip events,
%average value of friction drop, standard deviation of friction drop,
%average value of recurrence time, and standard deviation of recurrence time.

%====================================================================================================================================




                                                                       % input data
data   = readmatrix('input_data.dat');

time   = data(:, 1);                                                   % Horizontal axis, time (s)
Stress = data(:, 2);                                                   % Vertical axis - effective friction coefficient 


                                                                       % Identify the maximum value
[maxStress, maxLoc] = findpeaks(Stress);                               % "MaxStress" is the maximum value of the effective friction coefficient, and "maxLoc" is the corresponding index

                                                                       % Identify the minimum value
[minStress, minLoc] = findpeaks(-Stress);                              % Take a negative value and then search for the maximum value to obtain the minimum value
minStress = -minStress;                                                % Reverse the minimum value back to a positive value

                                                                       % Generate stick-slip events
slipEvents = [];                                                       % Initialize the list of stick-slip events

for i = 1:length(maxLoc)
                                                                       % Find the first minimum value after the i-th maximum value
    if i <= length(maxLoc) 
        followingMinLoc = minLoc(minLoc > maxLoc(i)); 
        if ~isempty(followingMinLoc)
            slipEvents = [slipEvents; maxLoc(i), followingMinLoc(1)]; 
        end
    end
end

                                                                      % Define the friction drop and recurrence time
frictionDrops = [];                                                   % The friction drop
recurrenceTimes = zeros(size(slipEvents, 1), 1);                      % The recurrence time, initialized to 0

                                                                      % Calculate the friction drop and recurrence time
for i = 1:size(slipEvents, 1)
    maxIdx = slipEvents(i, 1);
    minIdx = slipEvents(i, 2);
    
                                                                      % The friction drop
    frictionDrop = Stress(maxIdx) - Stress(minIdx);
    frictionDrops = [frictionDrops; frictionDrop];
    
                                                                      % The recurrence time
    if i == 1
        recurrenceTimes(i) = 0; 
    else
        startTime = time(maxIdx);
        endTime = time(slipEvents(i-1, 2));
        recurrenceTimes(i) = startTime - endTime; 
    end
end

                                                                     % Calculate the average value and standard deviation
avgFrictionDrop = mean(frictionDrops);                               % Average value of friction drop
stdFrictionDrop = std(frictionDrops);                                % Standard deviation of friction drop
avgRecurrenceTime = mean(recurrenceTimes);                           % Average value of recurrence time
stdRecurrenceTime = std(recurrenceTimes);                            % Standard deviation of recurrence time


                                                                     % Output the results to a text file
outputFile = 'output_data.txt'; 
fid = fopen(outputFile, 'w'); 
if fid == -1
    error('could not open file: %s', outputFile);
end

                                                                     % Write parameter names
fprintf(fid, 'The number of stick-slip events\t\tAverage value of friction drop\t\tStandard deviation of friction drop\tAverage value of recurrence time\tStandard deviation of recurrence time\n');
                                                                     % Write parameter values
numSlipEvents = size(slipEvents, 1);                                 % The number of stick-slip events
fprintf(fid, '%d\t\t\t\t%.6f\t\t\t\t%.6f\t\t\t\t%.6f\t\t\t\t%.6f\n', ...
        numSlipEvents, avgFrictionDrop, stdFrictionDrop, avgRecurrenceTime, stdRecurrenceTime);

fclose(fid); 