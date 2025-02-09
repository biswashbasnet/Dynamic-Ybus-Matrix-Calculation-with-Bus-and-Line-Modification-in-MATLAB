clc;
clear all;

% Step 1: Input bus names
disp('Enter the names of buses in the transmission lines:');
buses = {}; % Initialize an empty cell array to store bus names
i = 1; % Initialize the index

while true
    buses{i} = input(['Enter the name of Bus ', num2str(i), ': '], 's');
    addAnother = input('Is there another bus? Type 1 for Yes, 0 for No: ');

    if addAnother == 0
        break;
    elseif addAnother ~= 1
        disp('Invalid input. Please type 1 to add another bus or 0 to finish.');
        continue;
    end
    i = i + 1;
end

% Step 2: Calculate the number of buses
Nbus = length(buses);
disp(['The number of buses are: ', num2str(Nbus)]);

% Step 3: Determine connections and count the number of lines
Nline = 0;
linedata = [];

for i = 1:Nbus-1
    for k = i+1:Nbus
        connection = input(['Is there a connection between Bus (', num2str(i), ') ', buses{i}, ' and Bus  (', num2str(k), ')', buses{k}, '? (yes/no): '], 's');
        
        if strcmpi(connection, 'yes')
            Nline = Nline + 1;
          R = input(['Enter resistance (p.u.) between Bus (', num2str(i), ') ', buses{i}, ' and Bus (', num2str(k), ') ', buses{k}, ': ']);
X = input(['Enter reactance (p.u.) between Bus (', num2str(i), ') ', buses{i}, ' and Bus (', num2str(k), ') ', buses{k}, ': ']);

            Z = R + 1j * X;
            Y = 1 / Z;
            linedata(Nline, :) = [Nline, i, k, real(Y), imag(Y)];
        end
    end
end

% Step 4: Display results
disp(['The number of lines are: ', num2str(Nline)]);
disp('Linedata (connections between buses):');
disp('Line No   | Start Bus | End Bus | Real(Y) | Imag(Y)');
disp('----------------------------------------------------------------------------')
disp(linedata);

% Step 5: Calculate the initial Ybus matrix
Ybus = zeros(Nbus, Nbus);
for i = 1:Nline
    p = linedata(i, 2);
    q = linedata(i, 3);
    yline = linedata(i, 4) + 1j * linedata(i, 5);
    Ybus(p, p) = Ybus(p, p) + yline;
    Ybus(q, q) = Ybus(q, q) + yline;
    Ybus(p, q) = Ybus(p, q) - yline;
    Ybus(q, p) = Ybus(q, p) - yline;
end

disp('Initial Ybus matrix:');
disp(Ybus);

%% **Step 6: Allow User to Add a Bus or Lines Only**
while true
    choice = input('Do you want to add a new bus with lines or add only lines? (bus/line/none): ', 's');

    if strcmpi(choice, 'bus')
        % Add a new bus
        Nbus = Nbus + 1;
        buses{Nbus} = input('Enter the name of the new bus: ', 's');
        disp(['New bus "', buses{Nbus}, '" has been added.']);

        % Expand Ybus matrix
        Ybus(Nbus, :) = 0;
        Ybus(:, Nbus) = 0;

        % Ask for new connections for this bus
        for i = 1:Nbus-1
            connection = input(['Is there a connection between Bus ', buses{i}, ' and Bus ', buses{Nbus}, '? (yes/no): '], 's');
            if strcmpi(connection, 'yes')
                Nline = Nline + 1;
                R = input(['Enter resistance (p.u.) between Bus ', buses{i}, ' and Bus ', buses{Nbus}, ': ']);
                X = input(['Enter reactance (p.u.) between Bus ', buses{i}, ' and Bus ', buses{Nbus}, ': ']);
                Z = R + 1j * X;
                Y = 1 / Z;
                linedata(Nline, :) = [Nline, i, Nbus, real(Y), imag(Y)];

                % Update Ybus matrix
                Ybus(i, i) = Ybus(i, i) + Y;
                Ybus(Nbus, Nbus) = Ybus(Nbus, Nbus) + Y;
                Ybus(i, Nbus) = Ybus(i, Nbus) - Y;
                Ybus(Nbus, i) = Ybus(Nbus, i) - Y;
            end
        end
        
        disp('Updated Ybus matrix:');
        disp(Ybus);
    
    elseif strcmpi(choice, 'line')
        % Add a new line between existing buses
        startBus = input('Enter the starting bus of the new line (index or name): ', 's');
        endBus = input('Enter the ending bus of the new line (index or name): ', 's');

        % Convert bus names to indices if necessary
        if ischar(startBus)
            startBus = find(strcmp(buses, startBus));
        end
        if ischar(endBus)
            endBus = find(strcmp(buses, endBus));
        end

        % Validate input
        if isempty(startBus) || isempty(endBus) || startBus == 0 || endBus == 0 || startBus > Nbus || endBus > Nbus
            disp('Invalid bus selection.');
            continue;
        end
        
        % Input line parameters
        R = input(['Enter resistance (p.u.) between Bus ', buses{startBus}, ' and Bus ', buses{endBus}, ': ']);
        X = input(['Enter reactance (p.u.) between Bus ', buses{startBus}, ' and Bus ', buses{endBus}, ': ']);
        Z = R + 1j * X;
        Y = 1 / Z;

        % Increment line count
        Nline = Nline + 1;
        linedata(Nline, :) = [Nline, startBus, endBus, real(Y), imag(Y)];

        % Update Ybus matrix
        Ybus(startBus, startBus) = Ybus(startBus, startBus) + Y;
        Ybus(endBus, endBus) = Ybus(endBus, endBus) + Y;
        Ybus(startBus, endBus) = Ybus(startBus, endBus) - Y;
        Ybus(endBus, startBus) = Ybus(endBus, startBus) - Y;
        
        disp('Updated Ybus matrix:');
        disp(Ybus);
    
    elseif strcmpi(choice, 'none')
        break; % Exit loop
    else
        disp('Invalid input. Please enter "bus", "line", or "none".');
    end
end

% Final display
disp('Final Ybus matrix after all updates:');
disp(Ybus);
