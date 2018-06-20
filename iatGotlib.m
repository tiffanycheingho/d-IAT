
function iatGotlib

%%% programmed by TH and last updated June 2018 %%%

Screen('Preference', 'SkipSyncTests', 2);
warning('off','MATLAB:dispatcher:InexactMatch');

%get subject info
prompt = {'Subject Name','Group # (1 or 2)', 'Random Seed'};

%grab a random number and seed the generator (include this as a gui field in case want to repeat and exact sequence)
s = round(sum(100*clock));

%fill in some stock answers to the gui input boxes
defAns = {'','', num2str(s)};

box = inputdlg(prompt,'Enter Subject Information...', 1, defAns);
if length(box)==length(defAns)      %simple check for enough input, otherwise bail out
   p.subName=char(box{1});p.numBlocks=1; p.group=str2double(box{2}); p.rndSeed=str2double(box{3});
   rand('state',p.rndSeed);  %actually seed the random number generator
else    %if cancel button or not enough input, then just bail
   return
end
ListenChar(2);

%--------------------begin user define parameters----------------------------%
p.fullScreen = 1;                     % 0 for small window

% monitor stuff
p.RefreshRate = 60; % XX refresh rate based on scanner laptop XX
p.nTrials = 60; %total num trials in a single block

% viewing distance and screen width, in CM...used to convert degrees visual
% angle to pixel units later on for drawing stuff
p.vDistCM = 70;
p.screenWidthCM = 28;

p.fontSize = 1;

%stimulus colors
p.bckGrnd   = .5;
p.fontColor = 1;

%fixation point and probe properties for dotprobe
p.fixColor = [0, 0, 0];
p.textColor = [255 255 255];
p.textColor2 = [0 255 128]; %green text
p.fixSizeDeg = .5;                  % length of the lines
p.probeSizeDeg = .25;
p.cueSizeDeg = p.fixSizeDeg;
p.fixLineSize = 4; 
p.cueLineSize = p.fixLineSize;

% response keys
p.keys=[69,73]; %XX may need to be edited but currently reflects 'e' and 'i'

%--------------------end user define parameters----------------------------%

%Start setting up the display
AssertOpenGL; % bail if current version of PTB does not use OpenGL

% figure out how many screens we have, and pick the last one in the list
s=max(Screen('Screens'));

% grab the current val for white and black for the selected screen
p.black = BlackIndex(s);
p.white = WhiteIndex(s);
%computed gray for another study paradigm
p.gray=round((p.white+p.black)/2);
if round(p.gray)==p.white
	p.gray=p.black;
end

% Open a screen
Screen('Preference','VBLTimestampingMode',-1);  % for the moment, must disable high-precision timer on Win apps
if p.fullScreen
    [w, p.sRect] = Screen('OpenWindow', s, p.black);
else  
    % if we're debugging open a 640x480 window that is a little bit down from the upper left
    % of the big screen
    [w p.sRect]=Screen('OpenWindow',s, p.black, [20,20,660,500]);    
end

if p.fullScreen
    HideCursor;	% Hide the mouse cursor
    % set the priority up way high to discourage interruptions
    Priority(MaxPriority(w));
end

% compute and store the center of the screen: p.sRect contains the upper
% left coordinates (x,y) and the lower right coordinates (x,y)
p.xCenter = (p.sRect(3) - p.sRect(1))/2;
p.yCenter = (p.sRect(4) - p.sRect(2))/2;


% convert all 'Deg' fields from degrees to pixels, open the function for
% exact details on how to use - in short, all fields with the phrase 'Deg'
% in them anywhere will be converted to pixels, so take care when naming
% variables
p = deg2pix(p);

% destination rects for fixation point
fixRect = [(p.xCenter  - p.fixSizePix),(p.yCenter - p.fixSizePix),(p.xCenter  + p.fixSizePix), (p.yCenter + p.fixSizePix)];

% the text boxes

textInstructSB=['Press the SPACE BAR to begin.'];
textInstructSB2=['Press the SPACE BAR to continue.'];

textInstruct1=['Put your index fingers on the E and I keys.\n'...
    'Words representing the categories at the top\n'...
    'will appear one-by-one in the middle of the screen.\n'...
    'Press E to sort items to the left category.\n'...
    'Press I to sort items to the right category.\n'...
    'Items belong to only one category.\n'...
    'If you make an error, an X will appear.\n'...
    'Fix the error by hitting the other key.\n'...
    'Be as fast and as accurate as possible.\n'...
    'This task will take about 5 minutes to complete.'];

textInstruct2=['Look at the top of the screen.\n'...
    'The categories have changed.\n'...
    'The items for sorting have changed too.\n'...
    'Press E to sort items to the left category.\n'...
    'Press I to sort items to the right category.\n'...
    'Items belong to only one category.\n'...
    'If you make an error, an X will appear.\n'...
    'Fix the error by hitting the other key.'];

textInstruct3=['Look at the top of the screen.\n'...
    'The four categories are now appearing together.\n'...
    'Remember, each item belongs to only one group.\n'...
    'The labels are different colors to help you.\n'...
    'Press E to sort items to the left category.\n'...
    'Press I to sort items to the right category.\n'...
    'Items belong to only one category.\n'...
    'If you make an error, an X will appear.\n'...
    'Fix the error by hitting the other key.'];

textInstruct4=['Sort the same four categories again.\n'...
    'Remember to be as fast and as accurate as possible.'];
 
textInstruct5=['Look at the top of the screen.\n'...
    'The categories have switched positions.\n'...
    'Practice this new configurion.\n'...
    'Press E to sort items to the left category.\n'...
    'Press I to sort items to the right category.\n'...
    'Items belong to only one category.\n'...
    'If you make an error, an X will appear.\n'...
    'Fix the error by hitting the other key.'];

textInstruct6=['Look at the top of the screen.\n'...
    'The categories are now in a different configuration.\n'...
    'Remember each item belongs to only one group.\n'...
    'Remember to be as fast and as accurate as possible.'];

textInstruct7=['Sort the same four categories again.\n'...
    'Remember to be as fast and as accurate as possible.'];
    
    Screen('TextFont',w, 'Courier New');
    Screen('TextSize',w, 36);
    
p.deathTargets={'Suicide','Die','Funeral','Lifeless','Deceased'};
p.lifeTargets={'Alive','Live','Thrive','Survive','Breathing'};
p.meTargets={'Myself','My','Mine','I','Self'};
p.themTargets={'Them','They','Theirs','Their','Other'};

p.categories={'DEATH', 'LIFE'};
p.attributes={'ME','NOT ME'};
p.numTraining=20;
p.numTest=60;

p.totalTrials=p.numTraining*3+p.numTest*2;

% start a block loop (this is only 1 block)
for b=1:p.numBlocks
   %build an output file name and check to make sure that it does not exist already.
   p.root = pwd;
   if ~exist([p.root, '\Subject Data\'], 'dir')
       mkdir([p.root, '\Subject Data\']);
   end

   fName=[p.root, '\Subject Data\', p.subName, '_IAT', num2str(b), '.mat'];

   if exist(fName,'file')
       Screen('CloseAll');
       msgbox('File name already exists, please specify another', 'modal')
       return;
   end
  
    p.trialType=[repmat(1, 1, p.numTraining), repmat(2,1,p.numTraining), repmat(3,1,p.numTest), repmat(4, 1, p.numTraining), repmat(5,1,p.numTest)];
        %block 1: target sorting practice (20 trials)
        %block 2: attribute sorting practice (20 trials)
        %block 3: (in)consistent hypothesis test (60 trials with the first 20 being practice)
        %block 4: practice target switch (20 trials)
        %block 5: (in)consistent hypothesis test (opp of block 3; 60 trials with the first 20 being practice)
   
    startCat=Randi(2); %determining which side deathTargets and meTargets are initially displayed (1=left, 2=right)
%     startCat=2;
    %blocks here will refer to the test items
    %ans refer to the correct answer (left or right)
    p.block1=repmat([p.deathTargets, p.lifeTargets],1,2);
    sideDM=repmat(startCat,1,5);
    sideLO=repmat(abs(startCat-3),1,5);
    
    p.ans1=repmat([sideDM, sideLO],1,2);
    p.randind1=randperm(length(p.block1));
    p.block1=p.block1(p.randind1);
    p.ans1=p.ans1(p.randind1);
    
    p.block2=repmat([p.meTargets, p.themTargets], 1,2);
    p.ans2=repmat([sideDM, sideLO],1,2);
    p.randind2=randperm(length(p.block2));
    p.block2=p.block2(p.randind2);
    p.ans2=p.ans2(p.randind2);
    
    allitems=[p.deathTargets, p.lifeTargets, p.meTargets, p.themTargets];
    testblock=repmat(allitems,1,2);
        
    randind3=randperm(length(allitems));
    randind33=randperm(length(testblock));
    randind5=randperm(length(allitems));
    randind55=randperm(length(testblock));
    
    %p.group determines if block3 is DEATH-ME pairing (1) or LIFE-ME
    %pairing (2)
    
        prac=[sideDM, sideLO, sideDM, sideLO];
        test=repmat(prac,1,2);
        prac2=[sideLO, sideDM, sideDM, sideLO];
        test2=repmat(prac2,1,2);
        
        prac3=[sideDM, sideLO, sideLO, sideDM];
        test3=repmat(prac3,1,2);
        prac4=[sideLO, sideDM, sideLO, sideDM];
        test4=repmat(prac4,1,2);

    if p.group==1
        p.ans3=[prac test];
        p.ans5=[prac2 test2];  
        p.ans3=[prac(randind3) test(randind33)];   
        p.ans5=[prac2(randind5) test2(randind55)];
        
    elseif p.group==2
        p.ans3=[prac3 test3];
        p.ans5=[prac4 test4];
        p.ans3=[prac3(randind3) test3(randind33)];
        p.ans5=[prac4(randind5) test4(randind55)];
    end
    
    p.block3=[allitems(randind3),testblock(randind33)];
    p.block5=[allitems(randind5),testblock(randind55)];
    
    p.block4=repmat([p.lifeTargets, p.deathTargets],1,2);
    p.ans4=repmat([sideDM, sideLO],1,2);
    p.randind4=randperm(length(p.block4));
    p.block4=p.block4(p.randind4);
    p.ans4=p.ans4(p.randind4);
    
    
    p.testItem=[p.block1, p.block2, p.block3, p.block4, p.block5];
    p.testSide=[p.ans1, p.ans2, p.ans3, p.ans4, p.ans5];
    
    
    p.respWindow = 0; %won't be using this in this exp
    p.respFeedSecs = .25; %in seconds
    p.endFix = 0; %may want to change this if we end up scanning
    
    % allocate some arrays for storing subject response
    p.resp =      ones(p.totalTrials, 1)*-1;        % store the response
    p.correct =   nan(p.totalTrials,1);
    p.rt =        p.correct;        
    p.incorRT =   p.correct;
    p.trialStart =  zeros(1, p.totalTrials);
    p.trialEnd   =  zeros(1, p.totalTrials);    

   gap=30; %hardcoding distance between top category and bottom
   gap2=150; %indentation
    %----------------------------------------------------------------------
    % Start the stimulus presentation stuff, wait for SPACE BAR from the keyboard
    %----------------------------------------------------------------------
    DrawFormattedText(w, textInstruct1, 'center', 'center', p.textColor);
    DrawFormattedText(w, textInstructSB, 'center', p.sRect(2)+RectWidth(Screen('TextBounds', w, textInstructSB)), p.textColor);
    
    if startCat==1
        DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
        DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
    else
        DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
        DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
    end
    
    Screen('Flip', w);

    %%%Waiting for space bar%%%
    resp=0; 
    while resp==0
    [resp, timeStamp] = checkForResp([23,27,32,84,40]);
        if resp==23 || resp==27 || resp==84 || resp==40
            break;
        end
        if resp==-1; ListenChar(0); return; end;
    end
   cumTime = GetSecs;
   p.startExp = cumTime;
 
   % here is the start of trial loop
   for t=1:p.totalTrials
       p.trialStart(t) = GetSecs;   % start a clock to get the RT

      if t==21
                DrawFormattedText(w, textInstruct2, 'center', 'center', p.textColor);
                DrawFormattedText(w, textInstructSB2, 'center', p.sRect(2)+RectWidth(Screen('TextBounds', w, textInstructSB)), p.textColor);
                
                if startCat==1
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap2, p.textColor2);
                else
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap2, p.textColor2);
                end
                
                Screen('DrawingFinished', w);
                Screen('Flip', w);
                 resp=0; 
                    while resp==0
                    [resp, timeStamp] = checkForResp([23,27,32,84,40]);
                        if resp==23 || resp==27 || resp==84 || resp==40
                            break;
                        end
                        if resp==-1; ListenChar(0); return; end;
                    end
      elseif t==41
                DrawFormattedText(w, textInstruct3, 'center', 'center', p.textColor);
                DrawFormattedText(w, textInstructSB2, 'center', p.sRect(2)+RectWidth(Screen('TextBounds', w, textInstructSB)), p.textColor);

                if startCat*p.group==1
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);                
                elseif startCat*p.group==4
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);  
                elseif startCat==1 & p.group==2
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
               elseif startCat==2 & p.group==1
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
              end
                Screen('DrawingFinished', w);
                Screen('Flip', w);
                resp=0; 
                    while resp==0
                    [resp, timeStamp] = checkForResp([23,27,32,84,40]);
                        if resp==23 || resp==27 || resp==84 || resp==40
                            break;
                        end
                        if resp==-1; ListenChar(0); return; end;
                    end
      elseif t==61
                DrawFormattedText(w, textInstruct4, 'center', 'center', p.textColor);
                DrawFormattedText(w, textInstructSB2, 'center', p.sRect(2)+RectWidth(Screen('TextBounds', w, textInstructSB)), p.textColor);
                
                if startCat*p.group==1
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);                
                elseif startCat*p.group==4
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);  
                elseif startCat==1 & p.group==2
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
               elseif startCat==2 & p.group==1
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
              end
                
                Screen('DrawingFinished', w);
                Screen('Flip', w);
                resp=0; 
                    while resp==0
                    [resp, timeStamp] = checkForResp([23,27,32,84,40]);
                        if resp==23 || resp==27 || resp==84 || resp==40
                            break;
                        end
                        if resp==-1; ListenChar(0); return; end;
                    end
                    
      elseif t==101
                DrawFormattedText(w, textInstruct5, 'center', 'center', p.textColor);
                DrawFormattedText(w, textInstructSB2, 'center', p.sRect(2)+RectWidth(Screen('TextBounds', w, textInstructSB)), p.textColor);
                        
                if startCat==1
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                else
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                end
                Screen('DrawingFinished', w);
                Screen('Flip', w);
                resp=0; 
                    while resp==0
                    [resp, timeStamp] = checkForResp([23,27,32,84,40]);
                        if resp==23 || resp==27 || resp==84 || resp==40
                            break;
                        end
                        if resp==-1; ListenChar(0); return; end;
                    end
      elseif t==121
                DrawFormattedText(w, textInstruct6, 'center', 'center', p.textColor);
                DrawFormattedText(w, textInstructSB2, 'center', p.sRect(2)+RectWidth(Screen('TextBounds', w, textInstructSB)), p.textColor);
                 if startCat*p.group==4
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);                
                elseif startCat*p.group==1
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);  
                elseif startCat==2 & p.group==1
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
               elseif startCat==1 & p.group==2
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
              end
                 
                 Screen('DrawingFinished', w);
                Screen('Flip', w);
                resp=0; 
                    while resp==0
                    [resp, timeStamp] = checkForResp([23,27,32,84,40]);
                        if resp==23 || resp==27 || resp==84 || resp==40
                            break;
                        end
                        if resp==-1; ListenChar(0); return; end;
                    end
                    
        elseif t==141
                DrawFormattedText(w, textInstruct7, 'center', 'center', p.textColor);
                DrawFormattedText(w, textInstructSB2, 'center', p.sRect(2)+RectWidth(Screen('TextBounds', w, textInstructSB)), p.textColor);
                 if startCat*p.group==4
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);                
                elseif startCat*p.group==1
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);  
                elseif startCat==2 & p.group==1
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
               elseif startCat==1 & p.group==2
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);  
              end
                             
            Screen('DrawingFinished', w);
            Screen('Flip', w);
            resp=0; 
                while resp==0
                [resp, timeStamp] = checkForResp([23,27,32,84,40]);
                    if resp==23 || resp==27 || resp==84 || resp==40
                        break;
                    end
                    if resp==-1; ListenChar(0); return; end;
                end
      end
          

       if ismember(p.testItem{t}, p.meTargets) || ismember(p.testItem{t},p.themTargets)
            DrawFormattedText(w, p.testItem{t},'center','center', p.textColor2);
       else
           DrawFormattedText(w, p.testItem{t},'center','center', p.textColor);
       end
            
       if p.trialType(t)==1 & startCat==1 || p.trialType(t)==4 & startCat==2
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
            elseif p.trialType(t)==2 & startCat==1
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap2, p.textColor2);
            elseif p.trialType(t)==2 & startCat==2
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap2, p.textColor2);
            elseif p.trialType(t)==4 & startCat==1 || p.trialType(t)==1 & startCat==2
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
            elseif p.trialType(t)==3 & startCat*p.group==1 || p.trialType(t)==5 & startCat*p.group==4
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);
             elseif p.trialType(t)==3 & p.group==2 & startCat==1 || p.trialType(t)==5 & p.group==1 & startCat==2
                    DrawFormattedText(w, p.categories{1}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{2})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);        
             elseif p.trialType(t)==3 & startCat*p.group==4  || p.trialType(t)==5 & startCat*p.group==1
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{2})),p.sRect(2)+gap+gap2, p.textColor2);
            elseif p.trialType(t)==3 & p.group==1 & startCat==2  || p.trialType(t)==5 & p.group==2 & startCat==1
                    DrawFormattedText(w, p.categories{2}, p.sRect(1)+gap2,p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.categories{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.categories{1})),p.sRect(2)+gap2, p.textColor);
                    DrawFormattedText(w, p.attributes{2}, p.sRect(1)+gap2,p.sRect(2)+gap+gap2, p.textColor2);
                    DrawFormattedText(w, p.attributes{1}, p.sRect(3)-gap2-RectWidth(Screen('TextBounds', w, p.attributes{1})),p.sRect(2)+gap+gap2, p.textColor2);
            end
              
               Screen('Flip',w); %present the text
            % Read the keyboard, checking for response or 'escape'
                 resp=0;
                 respMade=0;
                 corResp=0;
                 while respMade==0
                    [resp, timeStamp] = checkForResp([27,p.keys]);
                    if resp==-1; ListenChar(0); return; end;  
                    if resp && find(p.keys==resp) && respMade==0
                        p.resp(t) = find(p.keys==resp);
                        p.rt(t) = GetSecs-p.trialStart(t);
                        p.correct(t)=p.resp(t)==p.testSide(t);
                        respMade=1;
                    end
                 end
                 
                    if p.correct(t)==0
                        resp=0;
                        myimgfile='redX_smallest.png';
                        ima=imread(myimgfile, 'png');
                        Screen('PutImage', w, ima); % draw image 
                        Screen('Flip',w); % red X now on screen
                            while corResp==0
                                [resp, timeStamp] = checkForResp([27,p.keys]);
                                if resp && find(p.keys==resp) && corResp==0
                                    secondresp=find(p.keys==resp);
                                    if secondresp==p.testSide(t)
                                        p.incorRT(t) = GetSecs-p.trialStart(t);
                                        corResp=1;
                                    else
                                        corResp=0;
                                    end
                                end
                            end
                    end
            Screen('Flip',w); %clear out screen
            WaitSecs(p.respFeedSecs);
            p.trialEnd(t) = GetSecs;
   end %end trial loop
           
    % clear out screen
     Screen('Flip', w);
     WaitSecs(p.respFeedSecs);
     resp = 0;
    while resp~=32
       [resp, timeStamp] = checkForResp([27,32]);
       if resp==-1; ListenChar(0); return; end;
    end
    Screen('Flip', w);
    p.EndExp = GetSecs;
    p.totalExpTime=p.startExp-p.EndExp;
       
    %save trial data from this block
    save(fName, 'p');
end % end block loop

ListenChar(0);
Screen('CloseAll');
return
