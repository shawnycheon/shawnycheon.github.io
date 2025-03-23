function ljHandle = BIOPAC_setup(channel_n)
%ljHandle = BIOPAC_setup(channel_n) 
%This function do basic setting of BIOPAC, and get handle.
%channel_n : Total channel number. You should exclude trigger channel.
%% Basic setting and load handle
BIOPAC_ON = 1;
BIOPAC_OFF = 0;
LJ_dtU3 = 3;
LJ_ctUSB = 1;
LJ_ioPIN_CONFIGURATION_RESET = 2017; % U3
LJ_ioPUT_DIGITAL_BIT = 40; % UE9 + U3

% Call ljud_LoadDriver from the command window or any mfile to load the
% LabJack driver. This needs to be done at the beginning of any file or
% before you can make any other calls to your LabJack.

if (libisloaded('labjackud') || (libisloaded('labjackud_doublePtr')))
    % Libraries already loaded
else
    %clear all;
    header='C:\Program Files (x86)\LabJack\Drivers\LabJackUD.h';
    loadlibrary('labjackud',header);
    loadlibrary labjackud labjackud_doublePtr.h alias labjackud_doublePtr
end

%ljud_LoadDriver; % Loads LabJack UD Function Library
%ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU3,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error) % Check for and display any Errros

%Start by using the pin_configuration_reset IOType so that all
%pin assignments are in the factory default condition.
Error = ljud_ePut(ljHandle, LJ_ioPIN_CONFIGURATION_RESET, 0, 0, 0);
Error_Message(Error)


%% Default configuration
for BIO_i = 1:channel_n
    Error = ljud_ePut(ljHandle, LJ_ioPUT_DIGITAL_BIT, BIO_i-1, BIOPAC_OFF ,0); % Because channel starts from 0.
    Error_Message(Error)
end

end