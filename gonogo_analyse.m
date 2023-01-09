%% GONOGO_ANALYSE: COMBINE AND ANALYSE MEASURES TAKEN FROM GONOGO_EXTRACT

% This script takes the measures inserted into the variable struct from the
% gonogo_analyse script and performs basic analyses on them, providing e.g. tables of
% averages that can subsequently be statistically analysed and plotted. 

%%----------------------------------------------------------------------------------------------------------------------------

% FUNCTIONS:
% get_exp_filenames             = to extract all .mat files containing the variables of
%                                 interest, contained in the 'variable' struct (set to 'analyse')
% correlate_rt_tt               = correlate RT and TT measures
% vincentize                    = vincentize RT distributions 
%
% ADDITIONAL INFO: 
% To find out what each of the columns in the variable.trials.stat cell
% array contains, see the variable_trials_stats_structure.txt file. 
%
% LIST OF EXPERIMENTS: 
% systemic_D1agonist_V1
% systemic_D1agonist_V2
% systemic_D1antagonist_V3
% systemic_D1antagonist_V5
% systemic_D2agonist
% systemic_D2antagonist
% systemic_5HT2Cantagonist_V1
% systemic_5HT2Cantagonist_V2
% systemic_5HT2CD1combo
% local_5HT2C
% local_amph_V1
% local_D1agonist_V1
% local_D1agonist_V2
% local_D1antagonist_V1
% local_D1antagonist_V2

%%----------------------------------------------------------------------------------------------------------------------------

clearvars;

experiment      = 'local_D1agonist_cohort2/'; % change to experiment of interest
rats            = {'13','15','16','17','19','20','21','22','23','25','26','27'}


%rats ={'13','15','16','17','19','20','21','23','24','25','26','27'};
%{'01','03','04','05','06','07','08','09','10','11','12'};
%{'13','14','15','16','17','19','20','21','22','23','24','25','26','27'};
drugs = {'sal_','skfl','skfh'}; %schv % must always be 4 characters long (e.g. sal_)

parent_directory = '/Users/grimal/Dropbox/dopamine_pharm/data/behaviour/extracted';
filename = get_exp_filenames_behaviour(parent_directory,experiment,'analyse',rats,drugs);

vincentizing = 0;
correlating = 0;
histogramming = 0;

% create arrays for allocating RTs and TTs for correlation
no_trials           = NaN(100,length(rats),length(drugs));
rt_go1              = NaN(100,length(rats),length(drugs));
rt_go2              = NaN(100,length(rats),length(drugs));
rt_wrong_lever1     = NaN(100,length(rats),length(drugs));
rt_wrong_lever2     = NaN(100,length(rats),length(drugs));
rt_cue_time_ex1     = NaN(100,length(rats),length(drugs));
rt_cue_time_ex2     = NaN(100,length(rats),length(drugs));
rt_go_noinvalid1    = NaN(100,length(rats),length(drugs));
rt_go_noinvalid2    = NaN(100,length(rats),length(drugs));
rt_nogo1            = NaN(100,length(rats),length(drugs));
rt_nogo2            = NaN(100,length(rats),length(drugs));
tin_failednogo1     = NaN(100,length(rats),length(drugs));
tin_failednogo2     = NaN(100,length(rats),length(drugs));
tin_successfulnogo1 = NaN(100,length(rats),length(drugs));
tin_successfulnogo2 = NaN(100,length(rats),length(drugs));
tt_go1              = NaN(100,length(rats),length(drugs));
tt_go2              = NaN(100,length(rats),length(drugs));
lp_go1              = NaN(100,length(rats),length(drugs));
lp_go2              = NaN(100,length(rats),length(drugs));
go_fm1              = NaN(100,length(rats),length(drugs));
go_fm2              = NaN(100,length(rats),length(drugs));
nogo_fm1            = NaN(100,length(rats),length(drugs));
nogo_fm2            = NaN(100,length(rats),length(drugs));
re_eng_success      = NaN(200,length(rats),length(drugs));
re_eng_failed       = NaN(200,length(rats),length(drugs));
tin_nogo1           = NaN(200,length(rats),length(drugs));
tin_nogo2           = NaN(200,length(rats),length(drugs));
abort_latencies     = NaN(200,length(rats),length(drugs));
scale_abort_latencies = NaN(200,length(rats),length(drugs));
re_eng_nogo_success1 = NaN(200,length(rats),length(drugs));
re_eng_nogo_success2 = NaN(200,length(rats),length(drugs));
re_eng_nogo_failed1  = NaN(200,length(rats),length(drugs));
re_eng_nogo_failed2  = NaN(200,length(rats),length(drugs));
re_eng_go_success1 = NaN(200,length(rats),length(drugs));
re_eng_go_success2 = NaN(200,length(rats),length(drugs));
re_eng_go_failed1 = NaN(200,length(rats),length(drugs));
re_eng_go_failed2 = NaN(200,length(rats),length(drugs));

for ifile = 1:length(filename)   
    
    load(filename{ifile});
    fprintf('Working on %s \n',filename{ifile})
    
    all_sessions{ifile}.variable = variable; % put all variable structs into one larger struct
    
    trial_info{ifile} = all_sessions{ifile}.variable.trials.stats; % shortcut
   
    
    for irat = 1:length(rats)
        for idrug = 1:length(drugs)      
            if strcmp(all_sessions{ifile}.variable.animalno, rats{irat})
                if strcmp(all_sessions{ifile}.variable.drug, drugs{idrug})     
                   

                    
%                     sanjay_trial_info.stats{irat,idrug,:} = [variable.trials.stats(:,1), variable.trials.stats(:,2), variable.trials.stats(:,4), variable.trials.stats(:,6)]; 
%                     sanjay_trial_info.double{irat,idrug,:} = variable.double; 
%                     sanjay_trial_info.cue_length{irat,idrug,:} = [variable.trials.stats(:,5)];
                    
                    %% EXTRA BITS FOR RATE OF ABORTED TRIALS AND VERY EARLY (<250ms) HEAD EXITS 

                    no_trials = cell2mat(trial_info{ifile}(end,1)); % gives number of trials in total - both successful and failed
                    no_trials_all(irat,idrug,:) = no_trials;
                    
                    head_exit_times = cell2mat(trial_info{ifile}(:,6));
                    no_immediate_exits = 0;
                    for time = 1:length(head_exit_times)
                        if head_exit_times(time) < 0.15
                            no_immediate_exits = no_immediate_exits + 1; 
                        end
                    end

                    no_immediate_exits_all(irat,idrug,:) = no_immediate_exits;
                    
                    %% EXTRA BITS FOR REVIEWER RESPONSE:
                    
                    % are response omission errors more likely after: 
                    % reward vs. no reward
                    
                    % find indices of trials 1 before when response omission errors occur (not including when it's the very first trial. Get success/fail and turn into 1/0.
                    % Then turn into proportion 
                    iprior_response_omission         = nonzeros((cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'reaction time exceeded')),1))) -1);
                    rew_prior_response_omission      = strcmp(trial_info{ifile}(iprior_response_omission,4),'success'); 
                    
                    prop_rew_prior_response_omission(irat,idrug,:) = sum(rew_prior_response_omission)/length(rew_prior_response_omission);
                    no_rew_prior_response_omission(irat,idrug,:)   = sum(rew_prior_response_omission);
                    
                    % go vs. no go                    
                    gor_prior_response_omission      = strcmp(trial_info{ifile}(iprior_response_omission,2),'GO Right'); 
                    gol_prior_response_omission      = strcmp(trial_info{ifile}(iprior_response_omission,2),'GO Left');  
                    go_prior_response_omission       = gor_prior_response_omission | gol_prior_response_omission;
                    
                    prop_go_prior_response_omission(irat,idrug,:)  = sum(go_prior_response_omission)/length(go_prior_response_omission);
                    no_go_prior_response_omission(irat,idrug,:)   = sum(go_prior_response_omission);

                    %% GO TRIALS

                    if strcmp(variable.double,'right')
                        
                        % reaction times for successful/failed go trials depending on reward size (2 = double reward) - time to leave the nosepoke from cue onset
                        rt.successful_go2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),6));
                        rt.wrong_lever_press2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),6));
                        rt.cue_time_exceeded2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4), 'reaction time exceeded')),6));
                        rt.successful_go1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),6));
                        rt.wrong_lever_press1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),6));
                        rt.cue_time_exceeded1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4), 'reaction time exceeded')),6));
                        rt.successful_go_noinvalid1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')),6));
                        rt.successful_go_noinvalid2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')),6));
                        
                        % travel times for successful/failed go trials - to 1st lever press
                        tt.successful_go2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),7));
                        tt.wrong_lever_press2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),7));
                        tt.successful_go1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),7));
                        tt.wrong_lever_press1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),7));
                        
                        % time taken to complete successful trial - from cue onset to 2nd lever press
                        ct.successful_go2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),5));
                        ct.successful_go1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),5));
                        
                        % time taken between 1st and 2nd lever presses in successful trials 
                        lp.successful_go2    = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),12));
                        lp.successful_go1    = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success')),12));
                        
                        % time taken from successful trial completion to reward collection in the food magazine
                        ctfm.successful_go2   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),8));
                        ctfm.successful_go1   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),8));
                        
                        % time taken from reward delivery to reward collection in the food magazine
                        rdfm.successful_go2   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),16));
                        rdfm.successful_go1   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),16));
                        
                        rdfm.successful_small = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') | strcmp(trial_info{ifile}(:,2),'NO GO SINGLE')  & strcmp(trial_info{ifile}(:,4),'success')),16));
                        rdfm.successful_large = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') | strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE')  & strcmp(trial_info{ifile}(:,4),'success')),16));    
                        
                    elseif strcmp(variable.double,'left')
                        
                        % reaction times for successful/failed go trials depending on reward size (2 = double reward) - time to leave the nosepoke from cue onset
                        rt.successful_go1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),6));
                        rt.wrong_lever_press1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),6));
                        rt.cue_time_exceeded1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4), 'reaction time exceeded')),6));
                        rt.successful_go2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),6));
                        rt.wrong_lever_press2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),6));
                        rt.cue_time_exceeded2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4), 'reaction time exceeded')),6));
                        rt.successful_go_noinvalid1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')),6));
                        rt.successful_go_noinvalid2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')),6));
                        
                        % travel times for successful/failed go trials - to 1st lever press (including cue period)
                        tt.successful_go1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),7));
                        tt.wrong_lever_press1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),7));
                        tt.successful_go2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),7));
                        tt.wrong_lever_press2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'incorrect lever press')),7));
                        
                        % time taken to complete successful trial - from cue onset to 2nd lever press
                        ct.successful_go1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),5));
                        ct.successful_go2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),5));
                        
                        % time taken between 1st and 2nd lever presses in successful trials 
                        lp.successful_go1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),12));
                        lp.successful_go2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success')),12));
                        
                        % time taken from successful trial completion to reward collection in the food magazine
                        ctfm.successful_go1   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),8));
                        ctfm.successful_go2   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),8));
                        
                        % time taken from reward delivery to reward collection in the food magazine
                        rdfm.successful_go1   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')),16));
                        rdfm.successful_go2   = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')  & strcmp(trial_info{ifile}(:,4),'success')),16));
                        
                        rdfm.successful_small = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') | strcmp(trial_info{ifile}(:,2),'NO GO SINGLE')  & strcmp(trial_info{ifile}(:,4),'success')),16));
                        rdfm.successful_large = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') | strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE')  & strcmp(trial_info{ifile}(:,4),'success')),16)); 
                
                        
                    end
                    
                    % if the value is less than 1.02 or 0.02 the food magazine was blocked - replace with a NaN
                    ctfm.successful_go1(ctfm.successful_go1 < 1.02) = NaN;
                    ctfm.successful_go2(ctfm.successful_go2 < 1.02) = NaN;
                    
                    
                    rdfm.successful_go1(rdfm.successful_go1 < 0.02) = NaN;
                    rdfm.successful_go2(rdfm.successful_go2 < 0.02) = NaN;
                    
                    rdfm.successful_small(rdfm.successful_small < 0.02) = NaN;
                    rdfm.successful_large(rdfm.successful_large < 0.02) = NaN;
                    
%                     % time taken from head exit to reward collection
%                     whole_traj.successful_go1 = ct.successful_go1 + ctfm.successful_go1 - rt.successful_go1;
%                     whole_traj.successful_go2 = ct.successful_go2 + ctfm.successful_go2 - rt.successful_go2;

                    %% NOGO TRIALS
                    
                    % reaction times for successful nogo - from end of cue to leaving poke
                    rt.successful_nogo1  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success')),3));
                    rt.successful_nogo2  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp (trial_info{ifile}(:,4),'success')),3));
                    
                    % time in nosepoke from cue
                    tin.successful_nogo1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success')),6));
                    tin.failed_nogo1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'failed')),6));
                    tin.successful_nogo2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,4),'success')),6));
                    tin.failed_nogo2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,4),'failed')),6));
                    
                    tin.nogo1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE')),6));
                    tin.nogo2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE')),6));
                    
                    % time taken to complete successful trial - cue onset to end of cue period
                    ct.successful_nogo1  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success')),5));
                    ct.successful_nogo2  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,4),'success')),5));
                    
                    % time taken from successful trial completion to reward collection in the food magazine
                    ctfm.successful_nogo1  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success')),8));
                    ctfm.successful_nogo2  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,4),'success')),8));
                    
                    ctfm.successful_nogo1(ctfm.successful_nogo1 < 1.02) = NaN;
                    ctfm.successful_nogo2(ctfm.successful_nogo2 < 1.02) = NaN;
                    
                    % time taken from reward delivery to reward collection in the food magazine
                    rdfm.successful_nogo1     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success')),16));
                    rdfm.successful_nogo2     = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE')  & strcmp(trial_info{ifile}(:,4),'success')),16));
                    
                    rdfm.successful_nogo1(rdfm.successful_nogo1 < 0.02) = NaN;
                    rdfm.successful_nogo2(rdfm.successful_nogo2 < 0.02) = NaN;
                    
                    % time taken from exit nosepoke to food magazine - nogo
                    exitfm.successful_nogo1 = (ctfm.successful_nogo1 - rt.successful_nogo1);
                    exitfm.successful_nogo2 = (ctfm.successful_nogo2 - rt.successful_nogo2);
                    
                    %% CALCULATING LATENCY MEASURES - AVERAGES
                    
                    % Reaction time/time in nosepoke means & medians
                    
                    beh.RDgo(irat,idrug,:)           = [nanmean(rdfm.successful_go1),nanmean(rdfm.successful_go2)];
                    beh.RDnogo(irat,idrug,:)         = [nanmean(rdfm.successful_nogo1),nanmean(rdfm.successful_nogo2)];
                    beh.RDgo_median(irat,idrug,:)    = [nanmedian(rdfm.successful_go1), nanmedian(rdfm.successful_go2)];
                    beh.RDnogo_median(irat,idrug,:)  = [nanmedian(rdfm.successful_nogo1), nanmedian(rdfm.successful_nogo2)];
                    
                    beh.RD(irat,idrug,:)             = [nanmean(rdfm.successful_small),nanmean(rdfm.successful_large)];
                    
                    beh.RTgo(irat,idrug,:)           = [nanmean(rt.successful_go1), nanmean(rt.successful_go2), nanmean(rt.wrong_lever_press1), nanmean(rt.wrong_lever_press2), nanmean(rt.cue_time_exceeded1), nanmean(rt.cue_time_exceeded2)];
                    beh.RTmediango(irat,idrug,:)     = [nanmedian(rt.successful_go1), nanmedian(rt.successful_go2), nanmedian(rt.wrong_lever_press1), nanmedian(rt.wrong_lever_press2), nanmedian(rt.cue_time_exceeded1), nanmedian(rt.cue_time_exceeded2)];
                    
                    beh.RTgo_noinvalid(irat,idrug,:) = [nanmean(rt.successful_go_noinvalid1), nanmean(rt.successful_go_noinvalid2)];
                    beh.RTmediango_noinvalid(irat,idrug,:) = [nanmedian(rt.successful_go_noinvalid1), nanmedian(rt.successful_go_noinvalid2)];
                    
                    beh.RTnogo(irat,idrug,:)         = [nanmean(rt.successful_nogo1), nanmean(rt.successful_nogo2)];
                    beh.RTmediannogo(irat,idrug,:)   = [nanmedian(rt.successful_nogo1), nanmedian(rt.successful_nogo2)];
                    
                    beh.TINnogo(irat,idrug,:)        = [nanmean(tin.successful_nogo1), nanmean(tin.successful_nogo2), nanmean(tin.failed_nogo1), nanmean(tin.failed_nogo2)];
                    beh.TINmediannogo(irat,idrug,:)  = [nanmedian(tin.successful_nogo1), nanmedian(tin.successful_nogo2), nanmedian(tin.failed_nogo1), nanmedian(tin.failed_nogo2)];
                    
                    % Travel time means & medians - from leaving nosepoke to first lever press
                    beh.TT(irat,idrug,:)             = [nanmean(tt.successful_go1 - rt.successful_go1), nanmean(tt.successful_go2 - rt.successful_go2), nanmean(tt.wrong_lever_press1 - rt.wrong_lever_press1), nanmean(tt.wrong_lever_press2 - rt.wrong_lever_press2)];
                    beh.TTmedian(irat,idrug,:)       = [nanmedian(tt.successful_go1 - rt.successful_go1), nanmedian(tt.successful_go2 - rt.successful_go2)];
                    
                    % Time from cue onset to successful trial completion
                    beh.cueCTgo(irat,idrug,:)        = [nanmean(ct.successful_go1), nanmean(ct.successful_go2)];
                    beh.cueCTnogo(irat,idrug,:)      = [nanmean(ct.successful_nogo1), nanmean(ct.successful_nogo2)];
                    
                    % Time from exit nosepoke to successful trial completion
                    beh.exitCTgo(irat,idrug,:)       = [nanmean(ct.successful_go1 - rt.successful_go1), nanmean(ct.successful_go2 - rt.successful_go2)];
                    beh.exitCTnogo(irat,idrug,:)     = [nanmean(ct.successful_nogo1 - tin.successful_nogo1), nanmean(ct.successful_nogo2 - tin.successful_nogo2)];
                    
                    % Time between first and second lever presses 
                    beh.LPgo(irat,idrug,:)           = [nanmean(lp.successful_go1), nanmean(lp.successful_go2)];
                    
                    % Time from successful trial to food tray means & medians
                    beh.CTFMgo(irat,idrug,:)         = [nanmean(ctfm.successful_go1), nanmean(ctfm.successful_go2)];
                    beh.CTFMmediango(irat,idrug,:)   = [nanmedian(ctfm.successful_go1), nanmedian(ctfm.successful_go2)];
                    
                    beh.CTFMnogo(irat,idrug,:)       = [nanmean(ctfm.successful_nogo1), nanmean(ctfm.successful_nogo2)];
                    beh.CTFMmediannogo(irat,idrug,:) = [nanmedian(ctfm.successful_nogo1), nanmedian(ctfm.successful_nogo2)];
                    
                    % Time from exit nosepoke to food tray means & medians (nogo)
                    beh.exitFMnogo(irat,idrug,:)     = [nanmean(exitfm.successful_nogo1), nanmean(exitfm.successful_nogo2)];
                    
                    %% CALCULATING SUCCESS RATES - NOGO
                    
                    % nogo
                    nogo1            = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE')));
                    successful_nogo1 = length(find((strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success'))))/nogo1*100;
                    nogo2            = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE')));
                    successful_nogo2 = length(find((strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,4),'success'))))/nogo2*100;
                    
                    beh.NG_success(irat,idrug,:) = [successful_nogo1, successful_nogo2];
                    
                    %% EARLY/LATE ERRORS IN SESSION - NOGO
                    % nogo - errors made throughout session split into quartiles  
                    nogo1_trials = cell2mat(num2cell(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE'))));
                    nogo1_outcomes = trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE')),4);
                    for outcomes = 1:length(nogo1_outcomes)
                        if strcmp(nogo1_outcomes(outcomes),'failed')
                            nogo1_outcomes{outcomes} = 1;
                        else
                            nogo1_outcomes{outcomes} = 0;
                        end
                    end
                    nogo1_outcomes = cell2mat(nogo1_outcomes);         
                    nogo1 = [nogo1_trials,nogo1_outcomes];                    
                    quartiles = round([0,nogo1_trials(end)/4,nogo1_trials(end)/2,(nogo1_trials(end)/2+nogo1_trials(end)/4),nogo1_trials(end)]);
                    for quarter = 1:length(quartiles)
                        [val(quarter),idx(quarter)] = min(abs(nogo1_trials-quartiles(quarter)));
                    end
                    cum_errors_quart = [sum(nogo1_outcomes(idx(1):idx(2))),sum(nogo1_outcomes(idx(2)+1:idx(3))),sum(nogo1_outcomes(idx(3)+1:idx(4))),sum(nogo1_outcomes(idx(4)+1:idx(5)))];
                    errors_quart(irat,idrug,:) = cum_errors_quart;

                    % same but double eward
                    nogo2_trials = cell2mat(num2cell(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE'))));
                    nogo2_outcomes = trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE')),4);
                    for outcomes2 = 1:length(nogo2_outcomes)
                        if strcmp(nogo2_outcomes(outcomes2),'failed')
                            nogo2_outcomes{outcomes2} = 1;
                        else
                            nogo2_outcomes{outcomes2} = 0;
                        end
                    end
                    nogo2_outcomes = cell2mat(nogo2_outcomes);         
                    nogo2 = [nogo2_trials,nogo2_outcomes];                    
                    quartiles2 = round([0,nogo2_trials(end)/4,nogo2_trials(end)/2,(nogo2_trials(end)/2+nogo2_trials(end)/4),nogo2_trials(end)]);
                    for quarter2 = 1:length(quartiles2)
                        [val(quarter2),idx2(quarter2)] = min(abs(nogo2_trials-quartiles(quarter2)));
                    end
                    cum_errors_quart2 = [sum(nogo2_outcomes(idx2(1):idx2(2))),sum(nogo2_outcomes(idx2(2)+1:idx2(3))),sum(nogo2_outcomes(idx2(3)+1:idx2(4))),sum(nogo2_outcomes(idx2(4)+1:idx2(5)))];
                    errors_quart2(irat,idrug,:) = cum_errors_quart2;

                    %% CALCULATING SUCCESS RATES - GO
                    % go - WITH invalid trials 
                    go_right = length(find(strcmp(trial_info{ifile}(:,2),'GO Right')));
                    go_left = length(find(strcmp(trial_info{ifile}(:,2),'GO Left')));
                    
                    if strcmp(variable.double,'right')
                        successful_go_all2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')))/go_right*100;
                        successful_go_all1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success')))/go_left*100;
                    elseif strcmp(variable.double,'left')
                        successful_go_all1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')))/go_right*100;
                        successful_go_all2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success')))/go_left*100;
                    end

                    % go - WITHOUT invalid trials 
                    if strcmp(variable.double,'right')
                        successful_go2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')))/go_right*100;
                        successful_go1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')))/go_left*100;
                    elseif strcmp(variable.double,'left')
                        successful_go1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')))/go_right*100;
                        successful_go2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success') & ~strcmp(trial_info{ifile}(:,11),'invalid successful go trial')))/go_left*100;
                    end
                    
                    beh.GO_ALLsuccess(irat,idrug,:) = [successful_go_all1, successful_go_all2];
                    beh.GO_success(irat,idrug,:)    = [successful_go1, successful_go2];
                    
                    %% EARLY/LATE ERRORS IN SESSION - GO
                    if strcmp(variable.double,'right')
                        go2_trials = cell2mat(num2cell(find(strcmp(trial_info{ifile}(:,2),'GO Right'))));
                        go2_outcomes = trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right')),4); 
                        go1_trials = cell2mat(num2cell(find(strcmp(trial_info{ifile}(:,2),'GO Left'))));
                        go1_outcomes = trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')),4);                  
                    elseif strcmp(variable.double,'left')
                        go1_trials = cell2mat(num2cell(find(strcmp(trial_info{ifile}(:,2),'GO Right'))));
                        go1_outcomes = trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right')),4); 
                        go2_trials = cell2mat(num2cell(find(strcmp(trial_info{ifile}(:,2),'GO Left'))));
                        go2_outcomes = trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')),4);  
                    end
                    for outcomes3 = 1:length(go2_outcomes)
                        if strcmp(go2_outcomes(outcomes3),'reaction time exceeded') %(strcmp(go2_outcomes(outcomes3),'incorrect lever press')|
                            go2_outcomes{outcomes3} = 1;
                        else
                            go2_outcomes{outcomes3} = 0;
                        end
                    end     
                    for outcomes4 = 1:length(go1_outcomes)
                        if strcmp(go1_outcomes(outcomes4),'reaction time exceeded')%(strcmp(go1_outcomes(outcomes4),'incorrect lever press')|
                            go1_outcomes{outcomes4} = 1;
                        else
                            go1_outcomes{outcomes4} = 0;
                        end
                    end   
                    go2_outcomes = cell2mat(go2_outcomes);         
                    go2 = [go2_trials,go2_outcomes];                    
                    quartiles3 = round([0,go2_trials(end)/4,go2_trials(end)/2,(go2_trials(end)/2+go2_trials(end)/4),go2_trials(end)]);
                    for quarter3 = 1:length(quartiles3)
                        [val(quarter3),idx3(quarter3)] = min(abs(go2_trials-quartiles(quarter3)));
                    end                    
                    go1_outcomes = cell2mat(go1_outcomes);         
                    go1 = [go1_trials,go1_outcomes];                    
                    quartiles4 = round([0,go1_trials(end)/4,go1_trials(end)/2,(go1_trials(end)/2+go1_trials(end)/4),go1_trials(end)]);
                    for quarter4 = 1:length(quartiles4)
                        [val(quarter4),idx4(quarter4)] = min(abs(go1_trials-quartiles(quarter4)));
                    end     
                    cum_errors_quart3 = [sum(go2_outcomes(idx3(1):idx3(2))),sum(go2_outcomes(idx3(2)+1:idx3(3))),sum(go2_outcomes(idx3(3)+1:idx3(4))),sum(go2_outcomes(idx3(4)+1:idx3(5)))];
                    errors_quart3(irat,idrug,:) = cum_errors_quart3;
                    cum_errors_quart4 = [sum(go1_outcomes(idx4(1):idx4(2))),sum(go1_outcomes(idx4(2)+1:idx4(3))),sum(go1_outcomes(idx4(3)+1:idx4(4))),sum(go1_outcomes(idx4(4)+1:idx4(5)))];
                    errors_quart4(irat,idrug,:) = cum_errors_quart4;      
                    
                    
                    %% CUE TIME EXCEEDED VS. INCORRECT LEVER PRESSES
                    % calculating proportions of each error type
                    
                    no.wrong_lever1                           = numel(rt.wrong_lever_press1);
                    no.wrong_lever2                           = numel(rt.wrong_lever_press2);
                    
                    no.cue_time_exceeded1                     = numel(rt.cue_time_exceeded1);
                    no.cue_time_exceeded2                     = numel(rt.cue_time_exceeded2);
                    
                    total_errors1                             = no.wrong_lever1 + no.cue_time_exceeded1;
                    total_errors2                             = no.wrong_lever2 + no.cue_time_exceeded2;
                    
                    % proportions
                    prop.wrong_lever1                         = no.wrong_lever1/total_errors1*100;
                    prop.wrong_lever2                         = no.wrong_lever2/total_errors2*100;
                    
                    prop.cue_time_exceeded1                   = no.cue_time_exceeded1/total_errors1*100;
                    prop.cue_time_exceeded2                   = no.cue_time_exceeded2/total_errors2*100;
                    
                    % proportions across all trials of that type
                    
                    if strcmp(variable.double,'right')
                        prop_across.wrong_lever1                  = no.wrong_lever1/go_left;
                        prop_across.wrong_lever2                  = no.wrong_lever2/go_right;
                    elseif strcmp(variable.double,'left')
                        prop_across.wrong_lever1                  = no.wrong_lever1/go_right;
                        prop_across.wrong_lever2                  = no.wrong_lever2/go_left;
                    end
                    
                    if strcmp(variable.double,'right')
                        prop_across.cue_time_exceeded1            = no.cue_time_exceeded1/go_left;
                        prop_across.cue_time_exceeded2            = no.cue_time_exceeded2/go_right;
                    elseif strcmp(variable.double,'left')
                        prop_across.cue_time_exceeded1            = no.cue_time_exceeded1/go_right;
                        prop_across.cue_time_exceeded2            = no.cue_time_exceeded2/go_left;
                    end
                    
                    
                    % average proportions
                    prop.mean_wrong_lever(irat,idrug,:)       = [nanmean(prop.wrong_lever1), nanmean(prop.wrong_lever2)];
                    prop.mean_cue_time_exceeded(irat,idrug,:) = [nanmean(prop.cue_time_exceeded1), nanmean(prop.cue_time_exceeded2)];
                    
                    % average proportions across all
                    prop_across.mean_wrong_lever(irat,idrug,:)       = [nanmean(prop_across.wrong_lever1), nanmean(prop_across.wrong_lever2)];
                    prop_across.mean_cue_time_exceeded(irat,idrug,:) = [nanmean(prop_across.cue_time_exceeded1), nanmean(prop_across.cue_time_exceeded2)];

                    % average numbers
                    no.mean_wrong_lever(irat,idrug,:)         = [nanmean(no.wrong_lever1), nanmean(no.wrong_lever2)];
                    no.mean_cue_time_exceeded(irat,idrug,:)   = [nanmean(no.cue_time_exceeded1), nanmean(no.cue_time_exceeded2)];
                    
                    %% INVALID GO TRIALS
                    % Animals stay in the nosepoke for >1.7s in a go trial
                    
                    % successful/failed invalid gos as proportion of all successful/failed go trials
                    if strcmp(variable.double,'right')
                        no.invalid_success1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,11),'invalid successful go trial')));
                        no.invalid_success2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,11),'invalid successful go trial')));
                        no.invalid_fail1    = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,11),'invalid unsuccessful go trial')));
                        no.invalid_fail2    = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,11),'invalid unsuccessful go trial')));
                        no_successful_go1   = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success')));
                        no_successful_go2   = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')));
                    elseif strcmp(variable.double,'left')
                        no.invalid_success1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,11),'invalid successful go trial')));
                        no.invalid_success2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,11),'invalid successful go trial')));
                        no.invalid_fail1    = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,11),'invalid unsuccessful go trial')));
                        no.invalid_fail2    = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,11),'invalid unsuccessful go trial')));
                        no_successful_go1   = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,4),'success')));
                        no_successful_go2   = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,4),'success')));
                    end
                    
                    prop.invalid_success1 = no.invalid_success1/no_successful_go1*100;
                    prop.invalid_success2 = no.invalid_success2/no_successful_go2*100;
                    prop.invalid_fail1    = no.invalid_fail1/(length(rt.wrong_lever_press1) + length(rt.cue_time_exceeded1))*100;
                    prop.invalid_fail2    = no.invalid_fail2/(length(rt.wrong_lever_press2) + length(rt.cue_time_exceeded2))*100;
                    
                    no.invalid_all1 = no.invalid_success1 + no.invalid_fail1;
                    no.invalid_all2 = no.invalid_success2 + no.invalid_fail2;
                    
                    % averages
                    no.invalid_success(irat,idrug,:)   = [nanmean(no.invalid_success1), nanmean(no.invalid_success2)]; 
                    no.invalid_fail(irat,idrug,:)      = [nanmean(no.invalid_fail1), nanmean(no.invalid_fail2)];
                    prop.invalid_success(irat,idrug,:) = [nanmean(prop.invalid_success1), nanmean(prop.invalid_success2)];
                    prop.invalid_fail(irat,idrug,:)    = [nanmean(prop.invalid_fail1), nanmean(prop.invalid_fail2)];
                    
                    %% DELAYED GO TRIALS 
                    % Animals lever press after nogo
                    
                    % delayed go after successful nogo, split by whether nogo was large or small
                    if strcmp(variable.double,'right')
                        no.delayed_success_doublelever1 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go right')));
                        no.delayed_success_singlelever1 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go left')));
                        no.delayed_success_doublelever2 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go right')));
                        no.delayed_success_singlelever2 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go left')));
                        
                        no.delayed_fail_doublelever1    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go right - unsuccessful nogo')));
                        no.delayed_fail_singlelever1    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go left - unsuccessful nogo')));
                        no.delayed_fail_doublelever2    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go right - unsuccessful nogo')));
                        no.delayed_fail_singlelever2    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go left - unsuccessful nogo')));
                        
                    elseif strcmp(variable.double,'left')
                        no.delayed_success_doublelever1 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go left')));
                        no.delayed_success_singlelever1 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go right')));
                        no.delayed_success_doublelever2 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go left')));
                        no.delayed_success_singlelever2 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go right')));
                        
                        no.delayed_fail_doublelever1    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go left - unsuccessful nogo')));
                        no.delayed_fail_singlelever1    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,11),'delayed go right - unsuccessful nogo')));
                        no.delayed_fail_doublelever2    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go left - unsuccessful nogo')));
                        no.delayed_fail_singlelever2    = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,11),'delayed go right - unsuccessful nogo')));
                    end
                    
                    prop.delayed_success_doublelever1 = no.delayed_success_doublelever1/length(rt.successful_nogo1)*100;
                    prop.delayed_success_doublelever2 = no.delayed_success_doublelever2/length(rt.successful_nogo2)*100;
                    prop.delayed_success_singlelever1 = no.delayed_success_singlelever1/length(rt.successful_nogo1)*100;
                    prop.delayed_success_singlelever2 = no.delayed_success_singlelever2/length(rt.successful_nogo2)*100;
                    
                    prop.delayed_fail_doublelever1 = no.delayed_fail_doublelever1/length(tin.failed_nogo1)*100;   
                    prop.delayed_fail_doublelever2 = no.delayed_fail_doublelever2/length(tin.failed_nogo2)*100; 
                    prop.delayed_fail_singlelever1 = no.delayed_fail_singlelever1/length(tin.failed_nogo1)*100; 
                    prop.delayed_fail_singlelever2 = no.delayed_fail_singlelever2/length(tin.failed_nogo2)*100;   
                    
                    % averages
                    no.delayed_success_doublelever(irat,idrug,:) = [nanmean(no.delayed_success_doublelever1),nanmean(no.delayed_success_doublelever2)];
                    no.delayed_success_singlelever(irat,idrug,:) = [nanmean(no.delayed_success_singlelever1),nanmean(no.delayed_success_singlelever2)];
                    no.delayed_fail_doublelever(irat,idrug,:)    = [nanmean(no.delayed_fail_doublelever1),nanmean(no.delayed_fail_doublelever2)];
                    no.delayed_fail_singlelever(irat,idrug,:)    = [nanmean(no.delayed_fail_singlelever1),nanmean(no.delayed_fail_singlelever2)];
                    
                    prop.delayed_success_doublelever(irat,idrug,:) = [nanmean(prop.delayed_success_doublelever1),nanmean(prop.delayed_success_doublelever2)];
                    prop.delayed_success_singlelever(irat,idrug,:) = [nanmean(prop.delayed_success_singlelever1),nanmean(prop.delayed_success_singlelever2)];
                    prop.delayed_fail_doublelever(irat,idrug,:)    = [nanmean(prop.delayed_fail_doublelever1),nanmean(prop.delayed_fail_doublelever2)];
                    prop.delayed_fail_singlelever(irat,idrug,:)    = [nanmean(prop.delayed_fail_singlelever1),nanmean(prop.delayed_fail_singlelever2)];
                    
                    %% FALSE EXPECTATION OF REWARD
                   
                    expect.all = length(find(strcmp(trial_info{ifile}(:,10), 'false expectation')));
                    expect.all_new = length(find(~isnan(cell2mat(trial_info{ifile}(:,18)))));

                    rt.successful_nogo1  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success')),3));
                     
                     if strcmp(variable.double,'right')
                         expect.go1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,10),'false expectation')),18));
                         expect.go2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,10),'false expectation')),18));
                     elseif strcmp(variable.double,'left')
                         expect.go1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,10),'false expectation')),18));
                         expect.go2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,10),'false expectation')),18));
                     end
                     
                     expect.go1(expect.go1 < 0.01) = NaN;
                     expect.no_go1 = length(expect.go1(~isnan(expect.go1)));
                     expect.go2(expect.go1 < 0.01) = NaN;
                     expect.no_go2 = length(expect.go2(~isnan(expect.go2)));
                     
                    % split by reward size and trial type
                    if strcmp(variable.double,'right')
                        expect.go1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,10),'false expectation')));
                        expect.go2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,10),'false expectation')));
                    elseif strcmp(variable.double,'left')
                        expect.go1 = length(find(strcmp(trial_info{ifile}(:,2),'GO Right') & strcmp(trial_info{ifile}(:,10),'false expectation')));
                        expect.go2 = length(find(strcmp(trial_info{ifile}(:,2),'GO Left') & strcmp(trial_info{ifile}(:,10),'false expectation')));
                    end
                    
                    expect.nogo1 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,10),'false expectation')));
                    expect.nogo2 = length(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,10),'false expectation')));
                    
                    expect.nogo1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,10),'false expectation')),18));
                    expect.nogo2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,10),'false expectation')),18));
                    
                    expect.nogo1(expect.nogo1 < 0.01) = NaN;
                    expect.no_nogo1 = length(expect.nogo1(~isnan(expect.nogo1)));
                    expect.nogo2(expect.nogo2 < 0.01) = NaN;
                    expect.no_nogo2 = length(expect.nogo2(~isnan(expect.nogo2)));
                    
                    % means and medians
                    expect.go(irat,idrug,:)   = [nanmean(expect.no_go1), nanmean(expect.no_go2)];
                    expect.nogo(irat,idrug,:) = [nanmean(expect.no_nogo1), nanmean(expect.no_nogo2)];
                    
                    % as proportion of error trials 
                    prop.expect_nogo1 = expect.no_nogo1/length(tin.failed_nogo1)*100;
                    prop.expect_nogo2 = expect.no_nogo2/length(tin.failed_nogo2)*100;
                    
                    prop.expect_nogo(irat,idrug,:) = [nanmean(prop.expect_nogo1), nanmean(prop.expect_nogo2)];

                    %% TRIAL RE-INITIATION LATENCIES
                    
                    reinit.all = cell2mat(trial_info{ifile}(:,9));
                    reinit.success = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success')),9)); % could be during ITI
                    reinit.failed  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'failed') | strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | ...
                        strcmp(trial_info{ifile}(:,4),'incorrect lever press')),9));

                    % split by reward size and trial type
                    if strcmp(variable.double,'right')
                        reinit.go_success1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Left')),9));
                        reinit.go_success2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Right')),9));
                        reinit.go_failed1  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Left')),9));
                        reinit.go_failed2  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Right')),9));
                    elseif strcmp(variable.double,'left')
                        reinit.go_success2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Left')),9));
                        reinit.go_success1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Right')),9));
                        reinit.go_failed2  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Left')),9));
                        reinit.go_failed1  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Right')),9));
                    end
                           
                    reinit.nogo_success1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'NO GO SINGLE')),9));
                    reinit.nogo_success2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'NO GO DOUBLE')),9));
                    reinit.nogo_failed1  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'failed') & strcmp(trial_info{ifile}(:,2), 'NO GO SINGLE')),9));
                    reinit.nogo_failed2  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'failed') & strcmp(trial_info{ifile}(:,2), 'NO GO DOUBLE')),9));
                    
                    % split only by reward size - after success
                    reinit.success1 = vertcat(reinit.go_success1,reinit.nogo_success1);
                    reinit.success2 = vertcat(reinit.go_success2,reinit.nogo_success2);
                    
                    
                    % means and medians
                    reinit.all_av(irat,idrug,:)         = nanmean(reinit.all);
                    reinit.all_median(irat,idrug,:)     = nanmedian(reinit.all);
                    
                    reinit.success_av(irat,idrug,:)     = nanmean(reinit.success);
                    reinit.success_median(irat,idrug,:) = nanmedian(reinit.success);
                    
                    reinit.success_rew_av(irat,idrug,:) = [nanmean(reinit.success1),nanmean(reinit.success2)];
                    
                    % remove anything < 1s from reinit.failed
                    for x = 1:length(reinit.failed)
                        if reinit.failed(x) < 1.0
                            reinit.failed(x) = NaN;
                        end
                    end
                    
%                     reinit.nogo_failed2(reinit.nogo_failed2 <1) = NaN;
%                     reinit.nogo_failed1(reinit.nogo_failed1 <1) = NaN;
%                     reinit.go_failed1(reinit.go_failed1 <1) = NaN;
%                     reinit.go_failed2(reinit.go_failed2 <1) = NaN;
                    
                    reinit.failed_av(irat,idrug,:)      = nanmean(reinit.failed);
                    reinit.failed_median(irat,idrug,:)  = nanmedian(reinit.failed);
                    
                    reinit.go_success(irat,idrug,:)     = [nanmean(reinit.go_success1), nanmean(reinit.go_success2)];
                    reinit.go_failed(irat,idrug,:)      = [nanmean(reinit.go_failed1), nanmean(reinit.go_failed2)];
                    reinit.nogo_success(irat,idrug,:)   = [nanmean(reinit.nogo_success1), nanmean(reinit.nogo_success2)];
                    reinit.nogo_failed(irat,idrug,:)    = [nanmean(reinit.nogo_failed1), nanmean(reinit.nogo_failed2)];
                    
                    %% ABORTED TRIALS - 102 MEASURE
                    
                    % using itrial,15 
                    oneotwomeasure_aborted = cell2mat(trial_info{ifile}(:,15));
                    oneotwomeasure_aborted = oneotwomeasure_aborted(end);
                    no_successful_nogo = length(find((strcmp(trial_info{ifile}(:,2),'NO GO SINGLE') & strcmp(trial_info{ifile}(:,4),'success')) | ...
                        (strcmp(trial_info{ifile}(:,2),'NO GO DOUBLE') & strcmp(trial_info{ifile}(:,4),'success'))));
                    oneotwomeasure = oneotwomeasure_aborted - no_successful_nogo;
                    all_oneotwomeasure(irat,idrug,:) = oneotwomeasure;
                    
                    abort.all           = cell2mat(trial_info{ifile}(:,15));
                    abort.after_success = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success')),15));
                    abort.after_failed  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'failed') | strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | ...
                        strcmp(trial_info{ifile}(:,4),'incorrect lever press')),15)); 
                    
                    % split by reward size and trial type 
                    if strcmp(variable.double,'right')
                        abort.go_success1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Left')),15));
                        abort.go_success2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Right')),15));
                        abort.go_failed1  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Left')),15));
                        abort.go_failed2  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Right')),15));
                    elseif strcmp(variable.double,'left')
                        abort.go_success2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Left')),15));
                        abort.go_success1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'GO Right')),15));
                        abort.go_failed2  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Left')),15));
                        abort.go_failed1  = cell2mat(trial_info{ifile}(find((strcmp(trial_info{ifile}(:,4),'reaction time exceeded') | strcmp(trial_info{ifile}(:,4),'incorrect lever press')) ...
                            & strcmp(trial_info{ifile}(:,2), 'GO Right')),15));
                    end
                    
                    abort.nogo_success1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'NO GO SINGLE')),15));
                    abort.nogo_success2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'success') & strcmp(trial_info{ifile}(:,2), 'NO GO DOUBLE')),15));
                    abort.nogo_failed1  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'failed') & strcmp(trial_info{ifile}(:,2), 'NO GO SINGLE')),15));
                    abort.nogo_failed2  = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,4),'failed') & strcmp(trial_info{ifile}(:,2), 'NO GO DOUBLE')),15));
                    
                    % means
                    
                    abort.all_av(irat,idrug,:)           = [nanmean(abort.all)];
                    abort.after_success_av(irat,idrug,:) = [nanmean(abort.after_success)];
                    abort.after_failed_av(irat,idrug,:)  = [nanmean(abort.after_failed)];
                    
                    abort.go_success(irat,idrug,:)   = [nanmean(abort.go_success1), nanmean(abort.go_success2)];
                    abort.go_failed(irat,idrug,:)    = [nanmean(abort.go_failed1), nanmean(abort.go_failed2)];
                    abort.nogo_success(irat,idrug,:) = [nanmean(abort.nogo_success1), nanmean(abort.nogo_success2)];
                    abort.nogo_failed(irat,idrug,:)  = [nanmean(abort.nogo_failed1), nanmean(abort.nogo_failed2)];
                    
                    %% ABORTED TRIALS - CORRECT!
                    
                    % after success
                    abort_during_ITI_after_reward = nansum(cell2mat(trial_info{ifile}(:,20)));
                    average_abort_during_ITI_after_reward = nanmean(cell2mat(trial_info{ifile}(:,20)));
                    
                    abort_after_ITI_after_reward = nansum(cell2mat(trial_info{ifile}(:,22)));
                    average_abort_after_ITI_after_reward = nanmean(cell2mat(trial_info{ifile}(:,22)));
                    
                    total_abort_after_reward = abort_during_ITI_after_reward + abort_after_ITI_after_reward;
                    
                    % after error
                    abort_during_error_after_error = nansum(cell2mat(trial_info{ifile}(:,24)));
                    average_abort_during_error_after_error = nanmean(cell2mat(trial_info{ifile}(:,24)));
                    
                    abort_during_ITI_after_error = nansum(cell2mat(trial_info{ifile}(:,25)));
                    average_abort_during_ITI_after_error = nanmean(cell2mat(trial_info{ifile}(:,25)));
                    
                    abort_after_ITI_after_error = nansum(cell2mat(trial_info{ifile}(:,26)));
                    average_abort_after_ITI_after_error = nanmean(cell2mat(trial_info{ifile}(:,26)));
                    
                    total_abort_after_error = abort_during_error_after_error + abort_during_ITI_after_error + abort_after_ITI_after_error;
                    total_abort_after_error_no_err_period = abort_during_ITI_after_error + abort_after_ITI_after_error;
                    
                    no_abort.after_reward_split(irat,idrug,:) = [nanmean(abort_during_ITI_after_reward), nanmean(abort_after_ITI_after_reward), nanmean(average_abort_during_ITI_after_reward), nanmean(average_abort_after_ITI_after_reward)];
                    no_abort.after_error_split(irat,idrug,:)  = [nanmean(abort_during_error_after_error), nanmean(abort_during_ITI_after_error), nanmean(abort_after_ITI_after_error),...
                        nanmean(average_abort_during_error_after_error), nanmean(average_abort_during_ITI_after_error), nanmean(average_abort_after_ITI_after_error)];
                    
                    no_abort.after_reward(irat,idrug,:)       = [nanmean(total_abort_after_reward)];
                    no_abort.after_error(irat,idrug,:)        = [nanmean(total_abort_after_error)];
                    no_abort.after_error_no_error_period(irat,idrug,:)        = [nanmean(total_abort_after_error_no_err_period)];
                    
                    % time in poke for an aborted trial - after success after ITI
                    abort_info_success = [trial_info{ifile}(1:end-1,28),trial_info{ifile}(1:end-1,22),trial_info{ifile}(1:end-1,27)]; % three columns: 1 = latencies, 2 = no of aborts, 3 = precue time
                    abort_info_success(cellfun(@(c) isnan(c), abort_info_success(:,2)),:) = []; % remove rows with nans in second column
                    abort_info_success(cellfun(@(c) c == 0, abort_info_success(:,2)),:) = []; % remove rows with zeros in second column 
                    
%                     aborts = [];
%                     for i = 1:length(abort_info_success)
%                         abort_all = abort_info_success{i,1};
%                         number_abort = abort_info_success{i,2};
%                         aborts{i,1} = abort_all(1:number_abort);
%                         aborts{i,2} = cell2mat(abort_info_success(i,3));
%                     end
%                     
%                     abort_success_latencies = [];
%                     for j = 1:length(aborts)
%                         split_doubles = cell2mat(aborts(j,1))'; 
%                         no_aborts = length(split_doubles);
%                         precue_time = cell2mat(aborts(j,2));
%                         precue_time = repelem(precue_time,no_aborts)';
%                         together = horzcat(split_doubles,precue_time);
%                         abort_success_latencies = [abort_success_latencies;together]; % left = time spent in poke for aborted trial, right = precue period 
%                     end
%                     
%                     for k = 1:length(abort_success_latencies)
%                         scale_factor = 1/abort_success_latencies(k,2); 
%                         norm_abort_latencies(k,1) = abort_success_latencies(k,1)*scale_factor;
%                     end

%                     abort_latencies(1:numel(abort_success_latencies(:,1)),irat,idrug) = abort_success_latencies(:,1);
%                     scale_abort_latencies(1:numel(norm_abort_latencies),irat,idrug) = norm_abort_latencies; 
                    
                   %% understanding relationship between precue time and time to leave poke after cue
                   precue_times = cell2mat(trial_info{ifile}((strcmp(trial_info{ifile}(:,2),'GO Right') | strcmp(trial_info{ifile}(:,2),'GO Left')),27));
                   head_exits = cell2mat(trial_info{ifile}((strcmp(trial_info{ifile}(:,2),'GO Right') | strcmp(trial_info{ifile}(:,2),'GO Left')),6));
                   
                   if length(head_exits) > length(precue_times)
                       head_exits = head_exits(1:end-1);
                   end

                   
                   precue_headexits = [precue_times,head_exits];

                    % separate those with precue times of less than 0.5 and those with times more than 0.5
                    short_precue_exits = [];
                    long_precue_exits = [];
                    for f = 1:length(precue_headexits)
                        if precue_headexits(f,1) <= 0.5
                            short_exit = precue_headexits(f,2);
                            short_precue_exits = [short_precue_exits,short_exit];
                        else
                            long_exit = precue_headexits(f,2);
                            long_precue_exits = [long_precue_exits,long_exit];
                        end
                    end
                    short_precue_exits = short_precue_exits';
                    long_precue_exits = long_precue_exits';
                    
                    mean_short_precue_exits(irat,idrug,:) = mean(short_precue_exits);
                    mean_long_precue_exits(irat,idrug,:) = mean(long_precue_exits);
                    
%                     %% SINGLE LEVER PRESSES IN CUE TIME EXCEEDED TRIALS
                    if strcmp(variable.double,'right')
                        single_lever_press1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')),31));
                        single_lever_press2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right')),31));
                    else
                        single_lever_press2 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Left')),31));
                        single_lever_press1 = cell2mat(trial_info{ifile}(find(strcmp(trial_info{ifile}(:,2),'GO Right')),31));   
                    end
                    
                    tot_single_lever_press1 = nansum(single_lever_press1);
                    tot_single_lever_press2 = nansum(single_lever_press2);
                    total_single_lever_press = tot_single_lever_press1 + tot_single_lever_press2;
                    prop_single_lever_press1 = tot_single_lever_press1/no.cue_time_exceeded1;
                    prop_single_lever_press2 = tot_single_lever_press2/no.cue_time_exceeded2;
                    total_cue_time_ex = no.cue_time_exceeded1 + no.cue_time_exceeded2; 
                    prop_total_single_press = total_single_lever_press/total_cue_time_ex; 
                    
                    all_single_press_both_rew(irat,idrug,:) = [prop_total_single_press];
                    all_single_lever_press(irat,idrug,:) = [prop_single_lever_press1, prop_single_lever_press2];
                    no_all_single_lever_press(irat,idrug,:) = [tot_single_lever_press1, tot_single_lever_press2];


                    %% LATENCY MATRICES
                    
                    % rts 
                    rt_go1(1:numel(rt.successful_go1),irat,idrug) = rt.successful_go1;
                    rt_go2(1:numel(rt.successful_go2),irat,idrug) = rt.successful_go2;
                    rt_go_noinvalid1(1:numel(rt.successful_go_noinvalid1),irat,idrug) = rt.successful_go_noinvalid1;
                    rt_go_noinvalid2(1:numel(rt.successful_go_noinvalid2),irat,idrug) = rt.successful_go_noinvalid2;
                    rt_nogo1(1:numel(rt.successful_nogo1),irat,idrug) = rt.successful_nogo1;
                    rt_nogo2(1:numel(rt.successful_nogo2),irat,idrug) = rt.successful_nogo2;
                    
                    rt_wrong_lever1(1:numel(rt.wrong_lever_press1),irat,idrug) = rt.wrong_lever_press1;
                    rt_wrong_lever2(1:numel(rt.wrong_lever_press2),irat,idrug) = rt.wrong_lever_press2;
                    
                    rt_cue_time_ex1(1:numel(rt.cue_time_exceeded1),irat,idrug) = rt.cue_time_exceeded1;
                    rt_cue_time_ex2(1:numel(rt.cue_time_exceeded2),irat,idrug) = rt.cue_time_exceeded2;

                    % tins
                    tin_failednogo1(1:numel(tin.failed_nogo1),irat,idrug) = tin.failed_nogo1;
                    tin_failednogo2(1:numel(tin.failed_nogo2),irat,idrug) = tin.failed_nogo2;
                    tin_successfulnogo1(1:numel(tin.successful_nogo1),irat,idrug) = tin.successful_nogo1;
                    tin_successfulnogo2(1:numel(tin.successful_nogo2),irat,idrug) = tin.successful_nogo2;
                    tin_nogo1(1:numel(tin.nogo1),irat,idrug) = tin.nogo1;
                    tin_nogo2(1:numel(tin.nogo2),irat,idrug) = tin.nogo2;
                    
                    % tts 
                    tt_go1(1:numel(tt.successful_go1),irat,idrug) = tt.successful_go1;
                    tt_go2(1:numel(tt.successful_go2),irat,idrug) = tt.successful_go2;
                    
                    % lps
                    lp_go1(1:numel(lp.successful_go1),irat,idrug) = lp.successful_go1;
                    lp_go2(1:numel(lp.successful_go2),irat,idrug) = lp.successful_go2;
                    
                    % fms
                    go_fm1(1:numel(ctfm.successful_go1),irat,idrug) = ctfm.successful_go1;
                    go_fm2(1:numel(ctfm.successful_go2),irat,idrug) = ctfm.successful_go2;
                    nogo_fm1(1:numel(exitfm.successful_nogo1),irat,idrug) = exitfm.successful_nogo1;
                    nogo_fm2(1:numel(exitfm.successful_nogo2),irat,idrug) = exitfm.successful_nogo2;
                    
                    % re-engagements
                    re_eng_success(1:numel(reinit.success),irat,idrug) = reinit.success;
                    re_eng_failed(1:numel(reinit.failed),irat,idrug) = reinit.failed;
                    
                    re_eng_nogo_success1(1:numel(reinit.nogo_success1),irat,idrug) = reinit.nogo_success1;
                    re_eng_nogo_success2(1:numel(reinit.nogo_success2),irat,idrug) = reinit.nogo_success2;
                    re_eng_nogo_failed1(1:numel(reinit.nogo_failed1),irat,idrug) = reinit.nogo_failed1;
                    re_eng_nogo_failed2(1:numel(reinit.nogo_failed2),irat,idrug) = reinit.nogo_failed2;
                    
                    re_eng_go_success1(1:numel(reinit.go_success1),irat,idrug) = reinit.go_success1;
                    re_eng_go_success2(1:numel(reinit.go_success2),irat,idrug) = reinit.go_success2;
                    re_eng_go_failed1(1:numel(reinit.go_failed1),irat,idrug) = reinit.go_failed1;
                    re_eng_go_failed2(1:numel(reinit.go_failed2),irat,idrug) = reinit.go_failed2;
                    
                end
            end
        end
    end
end

%% CORRELATIONS

if correlating
    [corr_coefficients, corr_pvalues] = correlate_rt_tt(rats,drugs,rt_go1,rt_go2,tt_go1,tt_go2);
end

%% HISTOGRAMS

if histogramming 
    [ av_prop_binned_values1, av_prop_binned_values2, cdf1, cdf2 ] = gonogo_histogram( rats,drugs,0,5,0.1,1,rt_cue_time_ex1,rt_cue_time_ex2,rt_go1,rt_go2,2,1)
end

%% VINCENTIZING

if vincentizing 
    [ind_vincentized_rts,av_vincentized_rts] = vincentize2(rats,drugs,10,rt_go1,rt_go2,1,1);
end