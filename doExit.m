function doExit(kc)
    % exit if escape key is pressed
    if kc(27)
        Screen('CloseAll');
        clear mex;
        clear all;
        return;
    end
