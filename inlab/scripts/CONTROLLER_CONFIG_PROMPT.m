
% Author: TJS
function [PENDULUM_TYPE, controllerTF] = CONTROLLER_CONFIG_PROMPT()

fprintf(':::Directions:::\n\n');
fprintf('As in the simulation, You can use this prompt to enter a controller Gc(s) = G1(s)*G2(s)*G3(s) ... Gn(s) \n');
fprintf('where G1(s) is the initial controller & Gi(s) for i = 2...n are compensators of the form (s+z)/(s+p).\n');
fprintf('First enter a controller kernel then you add compensators to the\n');
fprintf('existing controller. Restrictions are: \n\n');
fprintf('     1) Gc(s) cannot have zeros or poles at 0.\n     2) Gc(s) cannot have more zeros than poles\n');
fprintf('     3) The # of compensators n <= 6\n\n');
disp('Controllers are zeros, poles, gain: \n');
fprintf('Example:\n          zeros = -1, 2.5 \n          poles = 0, 0, -3, -7.2, -56.4\n          Gain = 10 \n\n');


% Length of the pendulum, user will be prompted to choose between
% 'LONG_24IN' & 'MEDIUM_12IN'
disp('There are two pendulums with different lengths. First choose a length.');
fprintf('\n\n');
length_option = input('Use long (24 in) pendulum (press enter) or short (12 in) pendulum? (press s): ', 's');

if length_option == 's'
    disp('Using short pendulum (12 in)'); 
    PENDULUM_TYPE = 'MEDIUM_12IN';
else 
    disp('Using long pendulum (24 in)');
    PENDULUM_TYPE = 'LONG_24IN';
    
end

fprintf('\n\n');

% Vector to hold compensators
controllerVector = [zpk([],[],1) zpk([],[],1) zpk([],[],1) zpk([],[],1) zpk([],[],1) zpk([],[],1) zpk([],[],1)];
compensatorCount = 1;

% User's controller that will be saved:
controllerTF = 1;

isExit = 0;

while ~isExit
    
    user_input = input('Start from scratch? (s)  OR  Add a compensator? (press a) OR Finished? (press x): ', 's');
    switch user_input 
        case 's' % User starts defining controller kernel
            fprintf('Enter G1(s):\n\n ');
            
            % Prompt user for controller zero positions:
            isValid = 0;
            while ~isValid 
                zerosStr = input('zeros = ', 's');
                if isempty(zerosStr)
                    zerosVec = [];
                    isValid = 1;
                elseif isempty(str2num(regexprep(zerosStr, ', ', ' ')))
                    disp('ERROR: invalid zeros values, see example above');
                    zerosVec = []; 
                else 
                    zerosVec = str2num(regexprep(zerosStr, ', ', ' '));
                    isValid = 1;
                end
            end
            
            isValid = 0;
            % Prompt user for controller pole positions:
            while ~isValid 
                polesStr = input('poles = ', 's');
                if isempty(polesStr)
                    polesVec = [];
                    isValid = 1;
                elseif isempty(str2num(regexprep(polesStr, ', ', ' ')))
                    disp('ERROR: invalid zeros values, see example above');
                    polesVec = []; 
                else 
                    polesVec = str2num(regexprep(polesStr, ', ', ' '));
                    isValid = 1;
                end
            end
            % Prompt user for controller gain:
            isValid = 0;
            gain = 1;
            while ~isValid 
                gainStr = input('gain = ', 's');
                if isempty(gainStr)
                    isValid = 1;
                elseif isnan(gain)
                    disp('ERROR: invalid gain value, see example above');
                else 
                    gain = str2num(gainStr);
                    isValid = 1;
                end
            end
            
            controllerVector(1) = zpk(zerosVec, polesVec, gain);
            controllerTF = 1;
            for i = 1:length(controllerVector)
                controllerTF = controllerTF * controllerVector(i);
            end
            % Format controller:
            syms s;
            user_tf  = 1;
            
            for i = 1:length(zerosVec)
                user_tf = user_tf * (s - zerosVec(i));
            end
            
            for i = 1:length(polesVec)
                user_tf = user_tf / (s - polesVec(i));
            end
            
            user_tf = gain * user_tf;
            % Print controller:
            disp('You entered controller G1(s) =  ');
            fprintf('\n');
            pretty(user_tf);
            % Compensator count updated:
            compensatorCount = compensatorCount + 1;
            
            
        case 'a'
            
            if compensatorCount == 6
                disp('Reached Maximum # of compensators of 6');
            elseif compensatorCount == 1
                disp('Start from scratch first to design the main controller');
            else
                fprintf('\nCurrent Gc(s) = \n\n');
                pretty(user_tf);
                disp(['Enter G', num2str(compensatorCount), '(s): ']);
                fprintf('\n\n');
                
                % Prompt user for compensator zero positions
                isValid = 0;
                while ~isValid 
                    zerosStr = input('zeros = ', 's');
                    if isempty(zerosStr)
                        zerosVec = [];
                        isValid = 1;
                    elseif isempty(str2num(regexprep(zerosStr, ', ', ' ')))
                        disp('ERROR: invalid zeros values, see example above');
                        zerosVec = []; 
                    else 
                        zerosVec = str2num(regexprep(zerosStr, ', ', ' '));
                        isValid = 1;
                    end
                end
                
                % Prompt user for compensator pole positions
                isValid = 0;
                while ~isValid 
                    polesStr = input('poles = ', 's');
                    if isempty(polesStr)
                        polesVec = [];
                        isValid = 1;
                    elseif isempty(str2num(regexprep(polesStr, ', ', ' ')))
                        disp('ERROR: invalid zeros values, see example above');
                        polesVec = []; 
                    else 
                        polesVec = str2num(regexprep(polesStr, ', ', ' '));
                        isValid = 1;
                    end
                end
                
                % Prompt user for compensator gain value
                isValid = 0;
                gain = 1;
                while ~isValid 
                    gainStr = input('gain = ', 's');
                    if isempty(gainStr)
                        isValid = 1;
                    elseif isnan(gain)
                        disp('ERROR: invalid gain value, see example above');
                    else 
                        gain = str2num(gainStr);
                        isValid = 1;
                    end
                end

                % Format compensator:
                syms s;
                user_tf  = 1;

                for i = 1:length(zerosVec)
                    user_tf = user_tf * (s - zerosVec(i));
                end

                for i = 1:length(polesVec)
                    user_tf = user_tf / (s - polesVec(i));
                end
                
                % Print compensator:
                user_tf = gain * user_tf;
                disp(['You added compensator G', num2str(compensatorCount), '(s) = ']);
                fprintf('\n');
                pretty(user_tf);
                
                % Updating controller TF value from compensator:
                controllerVector(compensatorCount) = zpk(zerosVec, polesVec, gain);
                controllerTF = 1;
                for i = 1:length(controllerVector)
                    controllerTF = controllerTF * controllerVector(i);
                end
              
                disp('The current controller is: ');
                % Format current controller:
                [zerosVec, polesVec, gain] = zpkdata(controllerTF, 'v');
                syms s;
                user_tf  = 1;
                for i = 1:length(zerosVec)
                    user_tf = user_tf * (s - zerosVec(i));
                end

                for i = 1:length(polesVec)
                    user_tf = user_tf / (s - polesVec(i));
                end
                user_tf = gain * user_tf;
                % Print current controller:
                fprintf('\n');
                pretty(user_tf);
                % Compensator count updated:
                compensatorCount = compensatorCount + 1;
            end
        case 'x'
            % Print on exit:
            fprintf('\nExiting prompt!\n');
            disp('Next you can run the controller on the model...');
            
            isExit = 1;
        otherwise 
            % Print on invalid key:
            disp('Enter a valid letter(a, s, x): ');
    end
end
% Apply possible pole-zero cancellations:
controllerTF = minreal(controllerTF);
end

% User net transfer function & pendulum length is stored and updated

