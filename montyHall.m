%%
%Pascal Wallisch
%09/21/2020

%% 1 The Monty Hall problem

%Assumptions: Monty Hall is fair, i.e. he always gives you the choice to
%switch, not only if you're on the prize. Otherwise, this doesn't make
%sense.

%For the purposes of this problem, we assuming the contestant always switches. We
%want to know what the probability of winning is, if the contestant is
%switching. As the sample space is closed and known, we can calculate
%p(not switching) as the 1-p(switching)

numDoors = 3;
DATA = zeros(numDoors^2,5); %Rows = trials. Columns = trial, prize, pick, strategy, outcome
trial = 1;
for pz = 1:numDoors %Put prize behind all doors, one after the next
    DOORSTATUS = zeros(1,numDoors); %Reinitialize the doors for every run, in terms of closing them. 1 = open, 0 = closed
    PRIZESTATUS = zeros(1,numDoors); %Re-initialize the doors for every run, in terms of prizes
    PRIZESTATUS(pz) = 1; %Actually putting the prize behind a given door
    for pk = 1:numDoors %Going through all initial picks by the contestant
        PICKSTATUS = zeros(1,numDoors); %Reinitializing pick status
        PICKSTATUS(pk) = 1; %Actually making the pick of a door
        temp = PRIZESTATUS + PICKSTATUS; %Represent doors that are either picked or where the prize is
        montyOptions = find(temp==0); %Find doors that monty Hall can open (not picked, no prize)
        whichDoorsCanMontyOpen = montyOptions(randperm(length(montyOptions))); %Pick the door he opens at random, out of the possible choices
        whichDoorWillMontyOpen = whichDoorsCanMontyOpen(1); %Decide on the one he actually opens
        DOORSTATUS(whichDoorWillMontyOpen) = 1; %Open a door, and reveal that it doesn't have a prize.
        %Now the participant switches
        temp = PICKSTATUS + DOORSTATUS; %Participant can't pick a door that is open (door status = 1) or already picked (pick status = 1)
        whichDoorCanParticipantSwitchTo = find(temp==0); %Which one is it?
        PICKSTATUS(pk) = 0; PICKSTATUS(whichDoorCanParticipantSwitchTo) = 1; %Moving the pick
        temp = PICKSTATUS + PRIZESTATUS; %See if we have a match!
        DATA(trial,1) = trial;
        DATA(trial,2) = pz; %Where was the prize put? 
        DATA(trial,3) = pk; %What was the initial pick by the contestant?
        DATA(trial,4) = 1; %Switched?
        
        if (sum(temp>1) > 0) %Is there a  winner? (temp == 2)
            disp('Winner!')
            DATA(trial,5) = 1; %Recording a win
        else
            disp('You lost')
            DATA(trial,5) = 0; %Recording a loss
            
        end
        trial = trial + 1;
    end
end
winningProportion = sum(DATA(:,5))./length(DATA) %Do NOT use the mean function here. Let's spell out the arithmetic
DATA %Have a look at the underlying DATA
%% 2 The Monty Carlo Hall problem
%Same as before, but now with many doors and many trials, playing at
%random. Because this is a simulation. Just large n
minDoors = 3; %How many doors minimally?
maxDoors = 25; %How many doors maximally?
numGames = 1e5; %How many plays per door number?
%Let's reuse most of the code, just repurpose it a bit
metaData = zeros(maxDoors,3); %Rows = Doors, Columns: Doors, SwitchingWinProportion, StayWinProportion
doorsOpened = 0;
for numDoors = minDoors:maxDoors
DATA = zeros(numGames,5); %Rows = trials. Columns = trial, prize, pick, strategy, outcome
numDoors %Where are we now? How many doors are we up to?
for game = 1:numGames %Play all the games, one after the next
    DOORSTATUS = zeros(1,numDoors); %Reinitialize the doors for every run, in terms of closing them. 1 = open, 0 = closed
    PRIZESTATUS = zeros(1,numDoors); %Re-initialize the doors for every run, in terms of prizes
    pz = randi(numDoors,1); %Where should the prize be put?
    PRIZESTATUS(pz) = 1; %Actually putting the prize behind a given door
    PICKSTATUS = zeros(1,numDoors); %Reinitializing pick status
    pk = randi(numDoors,1); %What should the initial pick be?
    PICKSTATUS(pk) = 1; %Actually making the pick of a door
    for od = 1:(numDoors-2) %Monty can open doors until there are n-2 left open - otherwise, the game doesn't work. So he opens one after the other
    temp = PRIZESTATUS + PICKSTATUS + DOORSTATUS; %Represent doors that are either picked or where the prize is, or that are already open
    montyOptions = find(temp==0); %Find doors that monty Hall can open (not picked, no prize)
    whichDoorsCanMontyOpen = montyOptions(randperm(length(montyOptions))); %Pick the door he opens at random, out of the possible choices
    whichDoorWillMontyOpen = whichDoorsCanMontyOpen(1); %Decide on the one he actually opens
    DOORSTATUS(whichDoorWillMontyOpen) = 1; %Open a door, and reveal that it doesn't have a prize.
    doorsOpened = doorsOpened + 1;
    end %Opening up all these doors will take time, so later iterations will take a lot longer. My fans just came on.
    %Now the contestantStrategy decides what to do, on the spot
    contestantStrategy = randi(2,1) - 1; %0 = Stay, 1 = switch
    if contestantStrategy == 1
        temp = PICKSTATUS + DOORSTATUS; %Participant can't pick a door that is open (door status = 1) or already picked (pick status = 1)
        whichDoorCanParticipantSwitchTo = find(temp==0); %Which one is it?
        PICKSTATUS(pk) = 0; PICKSTATUS(whichDoorCanParticipantSwitchTo) = 1; %Moving the pick
    else %Do nothing. In Python, you have to explicitly say "pass", or it won't work 
    end
        temp = PICKSTATUS + PRIZESTATUS; %See if we have a match!
        DATA(game,1) = game;
        DATA(game,2) = pz; %Where was the prize put? 
        DATA(game,3) = pk; %What was the initial pick by the contestant?
        DATA(game,4) = contestantStrategy; %Switched?
        
        if (sum(temp>1) > 0) %Is there a  winner? (temp == 2)
 %           disp('Winner!')
            DATA(game,5) = 1; %Recording a win
        else
  %          disp('You lost')
            DATA(game,5) = 0; %Recording a loss
            
        end
end

%Compile meta-data
switchingIndices = find(DATA(:,4)==1);
switchingWinningProportion = sum(DATA(switchingIndices,5))./length(switchingIndices)
stayingIndices = find(DATA(:,4)==0);
stayingWinningProportion = sum(DATA(stayingIndices,5))./length(stayingIndices)

metaData(numDoors,1) = numDoors; %How many doors?
metaData(numDoors,2) = switchingWinningProportion;
metaData(numDoors,3) = stayingWinningProportion;

end

%% 3 Plotting
figure
h1 = plot(metaData(minDoors:maxDoors,1),metaData(minDoors:maxDoors,2),'color','r','linewidth',4); %Winning proportion if switching
hold on
h2 = plot(metaData(minDoors:maxDoors,1),metaData(minDoors:maxDoors,3),'color','b','linewidth',4); %Winning proportion if staying
xlabel('Number of doors')
ylabel('Winning proportion')
title('Monty Carlo Hall')
legend([h1,h2],{'Switching','Staying'},'Location','East')
movshonize(38,1)
axis normal
makeWhite