% Simulate a simple race model, where confidence is measured as the distance between two
% independent accumulators at the time of boundary crossing. Do RTs reflect 1-confidence?
% 
% Anne Urai, CSHL, 2018

%% INITIALIZE THE MODEL PARAMETERS
close all; clc; clear;
rng default;

% at the moment, these are all hand-picked...
stimuli         = 1:2:10; % levels of stimulus strength, only simulate 1 stimulus identity
internalNoise   = 30;
bound           = 90;

%% RUN SOME SIMULATIONS OF THE MODEL

nsim = 100000;
sim.stimuli = repmat(stimuli, 1, nsim);
for trialidx = 1:length(sim.stimuli),
   
    % run the race model, two independent accumulators
    acc1 = 0;
    acc2 = 0;
    t    = 0;
    
    while acc1 < bound && acc2 < bound,
        t = t + 1;
        evidence = normrnd(sim.stimuli(trialidx), internalNoise);
        
        if evidence > 0,
            acc1 = acc1 + evidence;
        elseif evidence < 0,
            acc2 = acc2 - evidence;
        end
    end
    
    % find choice and RT
    sim.RT(trialidx)          = t;
    [~, sim.choice(trialidx)] = max([acc2 acc1]);
    sim.confidence(trialidx)  = abs(acc1-acc2);
    
end

%% COMPARE CONFIDENCE AND RT

sim.correct = ((sim.stimuli > 0) == (sim.choice > 1));

% average per stimulus level
[gr1, stimuli_correct] = findgroups(sim.stimuli(sim.correct == 1));
RTs_correct = splitapply(@mean, sim.RT(sim.correct == 1), gr1);
% there won't be RTs for each stimulus level, so only grab those where we
% have some data
[gr, stimuli_errors] = findgroups(sim.stimuli(sim.correct == 0));
RTs_error   = splitapply(@mean, sim.RT(sim.correct == 0), gr);

figure; 
subplot(221);
plot(stimuli_correct, RTs_correct, 'g', stimuli_errors, RTs_error, 'r');
xlabel('Input strength (a.u.)');
ylabel('RT (a.u.)');

% same for confidence, defined as 'balance of evidence'
conf_correct = splitapply(@mean, sim.confidence(sim.correct == 1), gr1);
conf_error   = splitapply(@mean, sim.confidence(sim.correct == 0), gr);

subplot(222);
plot(stimuli_correct, conf_correct, 'g', stimuli_errors, conf_error, 'r');
xlabel('Input strength (a.u.)');
ylabel('Balance of evidence (a.u.)');
print(gcf, '-dpdf', 'lca_confidence.pdf');

