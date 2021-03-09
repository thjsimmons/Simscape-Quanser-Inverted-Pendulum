%Parameter tuning!
% qc_update_model; => used to update the model variables in real time while
% keeping the initial values of encoder data?
addpath ('./scripts');
clear;
global ENABLE_MOTOR
ENABLE_MOTOR = 0;
% "Title screen", Lab directions
fprintf('::::::INVERTED PENDULUM CONTROL LAB EXPERIMENT::::::\n\n');
fprintf('1) Lab 1: Inverted Pendulum Controller Design'); fprintf('\n');
fprintf('This prompt can enter controllers into the simulink model and run them on the hardware.\n');
fprintf('You can start, stop, and pause the controller while the simulink model is running. /\n\n');
fprintf('Begin the run with the pendulum pointing straight down. Once the simulink model is running\n');
fprintf('but the controller has not been STARTED place the pendulum in the upright position. \n\n');
fprintf('After the prompt shows the line "MODEL RUNNING:\n');
fprintf('(Press "s" then ENTER) -> Start the controller \n');
fprintf('(Press "p" then ENTER) -> Pause the controller (but keep the model running)\n');
fprintf('(Press "e" then ENTER) -> Stop the controller (model stops running, prompt ends)\n');
fprintf('\n\n');

fprintf('Make sure that a model is not running before running this script.\n');
fprintf('If the model is already running, enter the line\n\n');
fprintf('     qc_stop_model(''lab1'')\n\n');
fprintf('into the command prompt.\n\n');


PEND_TYPE = 'LONG_24IN'; 
controllerTF = tf(1,1);
[PEND_TYPE, controllerTF] = CONTROLLER_CONFIG_PROMPT();
setup_lab_ip02_sesip;

%load_system('lab1.mdl')
%qc_build_model('lab1')
%qc_connect_model('lab1')

input('If this doesn''t look right, hit Ctrl+C. Otherwise, hit enter to RUN MODEL: ', 's');
%qc_start_model('lab1')

fprintf('MODEL RUNNING\n\n');



loop_input = '';
isPaused = 0;
isEnded = 0;
isEdit = 0;
isBefore = 1;



while ~isEnded

    loop_input = input('s->START controller, p-> PAUSE controller, e->END run: ', 's');
    switch loop_input
        case 's'
            fprintf('CONTROLLER IS STARTED! ...\n\n');
            ENABLE_MOTOR = 1; 
            %qc_update_model;
            pause(1);
            isPaused = 0;
        case 'p' 
            fprintf('CONTROLLER IS PAUSED! ...\n\n');
            ENABLE_MOTOR = 0;
            %qc_update_model;
            pause(1);
            isPaused = 1;
        case 'e' 
            fprintf('CONTROLLER IS STOPPED! ...\n\n');
            ENABLE_MOTOR = 0;
            %qc_update_model;
            pause(1);
            isEnded = 1;
        
        otherwise 
            disp('PAUSED: Enter a valid input!');
            ENABLE_MOTOR = 0;
            %qc_update_model;
            pause(1);
            isPaused = 1;

    end 
    
    if isEnded == 1
        disp('ENDING RUN NOW');
        break;
    end
end


input('Hit enter to stop the demo.' , 's');

if ENABLE_MOTOR ~= 0
    ENABLE_MOTOR = 0;
end
%qc_update_model;
%qc_stop_model('lab1');
input('MODEL STOPPED');
disp('Have a great day!');
