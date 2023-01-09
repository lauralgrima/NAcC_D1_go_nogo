function [av_prop_binned_values1, av_prop_binned_values2, base_histogram1, base_histogram2] = gonogo_histogram( rats, drugs ,start_bin, end_bin, bin_size,action,rts_1, rts_2, alt_rts_1,alt_rts_2,histogram_type,toggle_histogram)
%
%   INPUTS: 
%
%   rats                  = rats to be included
%   drugs                 = drugs to be included 
%   start_bin             = first bin
%   end_bin               = last bin
%   bin_size              = size of bins
%   action                = whether 'go' or 'nogo' trial type - if nogo, 0, if go, 1
%   rts_1                 = measure of interest e.g. reaction times - successful low reward
%   rts_2                 = measure of interest - high reward
%   alt_rts_1             = alternative measure (e.g. failed low reward)
%   alt_rts_2             = alternative measure 2 
%   histogram_type        = 0 = probability within own trial type, 1 = pdf within own trial type, 2 = probability across all trial types, 3 = pdf across all trial types 
%   toggle_histogram      = if wanting to plot histogram, set to 1
%   toggle_cdf            = if wanting to plot cdf, set to 1
%
%   OUTPUTS:
% 
%   av_prop_binned_values = Average proportion of responses for each bin
%                           for each drug - for low (1) and high (2) reward sizes
%-------------------------------------------------------------------------------------------------------------------

%clear base_histogram1 base_histogram2

bins       = [start_bin:bin_size:end_bin];
bins_extra = [bins,1000]; % this allows the last bin to be all of the values not included in the range defined
bins_plot  = [bins,end_bin+bin_size];

% calculate bin centres
for ibin = 1:length(bins(1:end-1))
    bin_centres(:,ibin) = (bins(ibin) + bins(ibin+1)) / 2;
end

rewards = {'1','2'};

for idrug = 1:length(drugs)
    for irat = 1:length(rats)
        
        not_nans_idxs1 = ~isnan(rts_1(:,irat,idrug)); % extract only data, remove NaNs from trial type of interest
        rts_1_non_nans = rts_1(not_nans_idxs1,irat,idrug);
        not_nans_idxs2 = ~isnan(rts_2(:,irat,idrug));
        rts_2_non_nans = rts_2(not_nans_idxs2,irat,idrug);
        
        no_trials1 = length(rts_1_non_nans);
        no_trials2 = length(rts_2_non_nans);
        
        alt_not_nans_idxs1 = ~isnan(alt_rts_1(:,irat,idrug));
        alt_rts_1_non_nans = alt_rts_1(alt_not_nans_idxs1,irat,idrug);
        alt_not_nans_idxs2 = ~isnan(alt_rts_2(:,irat,idrug));
        alt_rts_2_non_nans = alt_rts_2(alt_not_nans_idxs2,irat,idrug);
        
        no_other_trials1 = length(alt_rts_1_non_nans);
        no_other_trials2 = length(alt_rts_2_non_nans);
        
        all_trials1 = no_trials1 + no_other_trials1;
        all_trials2 = no_trials2 + no_other_trials2;
         
        
        % probability distribution - dividing only by OWN trial type
        if histogram_type == 0
            
            base_histogram1(:,irat,idrug)     = histcounts(rts_1_non_nans,bins_extra,'Normalization','probability');
            base_histogram2(:,irat,idrug)     = histcounts(rts_2_non_nans,bins_extra,'Normalization','probability');
            
            % probability density function - dividing only by OWN trial type
        elseif histogram_type == 1
            
            base_histogram1(:,irat,idrug)     = histcounts(rts_1_non_nans,bins_extra,'Normalization','pdf');
            base_histogram2(:,irat,idrug)     = histcounts(rts_2_non_nans,bins_extra,'Normalization','pdf');
            
            % probability distribution - dividing across sum of ALL trials
        elseif histogram_type == 2
            
            base_histogram_pre1               = histcounts(rts_1_non_nans,bins_extra);
            base_histogram1(:,irat,idrug)     = base_histogram_pre1./all_trials1;
            base_histogram_pre2               = histcounts(rts_2_non_nans,bins_extra);
            base_histogram2(:,irat,idrug)     = base_histogram_pre2./all_trials2;
            
        end
    end
end

av_prop_binned_values1      = squeeze(nanmean(base_histogram1,2));
av_prop_binned_values2      = squeeze(nanmean(base_histogram2,2));
av_prop_binned_values_list  = [av_prop_binned_values1; av_prop_binned_values2];
rounded_value               = 0.01*(ceil(av_prop_binned_values_list/0.01));
biggest_value               = max(rounded_value(:));

av_prop_binned_values(:,:,1) = av_prop_binned_values1;
av_prop_binned_values(:,:,2) = av_prop_binned_values2;

% calculating median
sorted1 = sort(rts_1);
sorted2 = sort(rts_2);
for idrug = 1:length(drugs)
    for irat = 1:length(rats)
        rt1_median(irat,idrug,:) = nanmedian(sorted1(:,irat,idrug));
        rt2_median(irat,idrug,:) = nanmedian(sorted2(:,irat,idrug));
    end
end

mean_rt1_median       = nanmean(rt1_median);
mean_rt2_median       = nanmean(rt2_median);
mean_rt_median(:,:,1) = mean_rt1_median;
mean_rt_median(:,:,2) = mean_rt2_median;

%% PLOT HISTOGRAMS

if toggle_histogram
    for ireward = 1:length(rewards)
        for idrug = 1:length(drugs)
            
            figure
            if length(drugs) == 1 % just plotting saline 
                
                if action == 0
                    
                    % saline
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); 
                    line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)
                    
                    legend('vehicle','median - vehicle');
                    xlabel('Time in nose poke (s)');
                    
                elseif action == 1
                    
                    % saline
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward));                    
                    line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0.2 0.1 0],'Linestyle','-.','LineWidth',2) 
                    
                    legend('vehicle','median - vehicle');
                    
                end
            
            
            elseif length(drugs) == 2
                
                if action == 0
                    
                    % drug
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.9,'FaceColor',[1.0 0.4100 0.1700],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
                    
                    % saline
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
                    
                    line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 biggest_value+0.05],'Color',[0.8 0 0],'Linestyle','-.','LineWidth',2)
                    line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)
                    
                    
                    
                    %                 % drug
                    %                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0.8 0.2 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
                    %
                    %                 % saline
                    %                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward));
                    %
                    %                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 biggest_value+0.05],'Color',[0.7 0.2 0.7],'Linestyle','-.','LineWidth',2)
                    %                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)
                    
                    %                 histogram('BinEdges',bins,'FaceAlpha',0.5,'FaceColor',[0 0.5 0.9],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
                    %                 histogram('BinEdges',bins,'FaceAlpha',0.7,'FaceColor',[0 0.2 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
                    
                    legend('0.1 mg/kg','vehicle','median - 0.1 mg/kg','median - vehicle');
                    
                elseif action == 1
                    
                    % drug
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0.8 0.8],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
                    
                    % saline
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward));
                    
                    line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 biggest_value+0.05],'Color',[0 1.0 0.9],'Linestyle','-.','LineWidth',2)
                    line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0.2 0.1 0],'Linestyle','-.','LineWidth',2)
                    
                    legend('SB 242084','vehicle','median - SB 242084','median - vehicle');
                    
                end
                
            elseif length(drugs) == 3
                
                if action == 0
                    
                    histogram_colour        = {[0 0 0.5]   [0.5 0.2 0] [1.0 0 0]};
                    median_line_colour      = {[0 0.1 0.2] [0.5 0 0] [0.8 0 0]};
                    drug_legend             = {['vehicle'] ['low dose'] ['high dose']};
                    
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',histogram_colour{idrug},'LineWidth',2,'BinCounts',av_prop_binned_values(:,idrug,ireward));
                    line([mean_rt_median(:,idrug,ireward),mean_rt_median(:,idrug,ireward)],[0 1],'Color',median_line_colour{idrug},'Linestyle','-.','LineWidth',2)
                    
                    
                elseif action == 1
                    
                    histogram_colour        = {[0 0 0.5]   [0 0.5 0] [0 1.0 0]};
                    median_line_colour      = {[0.2 0.1 0] [0 0.5 0] [0 0.8 0]};
                    drug_legend             = {['vehicle'] ['low dose'] ['high dose']};
                    
                    histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',histogram_colour{idrug},'LineWidth',2,'BinCounts',av_prop_binned_values(:,idrug,ireward));
                    line([mean_rt_median(:,idrug,ireward),mean_rt_median(:,idrug,ireward)],[0 1],'Color',median_line_colour{idrug},'Linestyle','-.','LineWidth',2)
                    
                    
                    
%                 % drug
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.7,'FaceColor',[0.5 0.2 0.8],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0.8 0.2 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                 
%                 % saline
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                 
%                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 1],'Color',[0.5 0.2 0.8],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 1],'Color',[0.7 0.2 0.7],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 1],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)
                    
                end
                
                %set legend
                hLeg = legend(drug_legend{idrug});
                
                if ireward == 1
                    legend(drug_legend{idrug},'Location','northwest');
                else
                    set(hLeg,'visible','off');
                end
                
            end
            
            set(gca,'FontName','Arial','FontSize',16);
            ax = gca;
            ax.LineWidth = 1.5;
            
            if idrug == 3
                xlabel('Time in nose poke (s)');
            end
            

            xlabel('Re-initiation latency (s)');

            
            if ireward == 1
                ylabel('Average probability'); 
            end
            
            ylim([0 biggest_value]);
            
            box off, legend boxoff
            
            if rewards{ireward} == '1'
                title('Low reward - NoGo failed');
            elseif rewards{ireward} == '2'
                title('High reward - NoGo failed');
            end
            
            set(gca,'FontName','Arial','FontSize',18); %fontsize 14 for smaller histograms, 18 for larger
            % set(gcf,'Position',[500 500 700 210]);
            set(gcf,'Position',[800 800 500 200]);
            
            
            
        end
    end
end
    
end

 % legend('4.0 \mug/\mul','0.4 \mug/\mul','saline','median - 4.0 \mug/\mul','median - 0.4 \mug/\mul','median - saline','Location','northwest');
% BLUES
%                  % drug
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0.5 0.9],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.7,'FaceColor',[0 0.2 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                 
%                 % saline
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                 
%                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 biggest_value+0.05],'Color',[0 0.6 1.0],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 biggest_value+0.05],'Color',[0 0.3 0.8],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0.2 0.1 0],'Linestyle','-.','LineWidth',2)

% GREENS
%                 % drug
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 1.0 0],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0.5 0],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                 
%                 % saline
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                 
%                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 biggest_value+0.05],'Color',[0 0.8 0],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 biggest_value+0.05],'Color',[0 0.5 0],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0.2 0.1 0],'Linestyle','-.','LineWidth',2)

% REDS
%                 % drug
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[1.0 0 0],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0.5 0 0],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                 
%                 % saline
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                 
%                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 1],'Color',[0.8 0 0],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 1],'Color',[0.5 0 0],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 1],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)

% SB NOGO

%                 % drug
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.9,'FaceColor',[1.0 0.4100 0.1700],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0.5 0.2 0],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                 
%                 % saline
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                 
%                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 1],'Color',[0.8 0 0],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 1],'Color',[0.5 0 0],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 1],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)
% 
%   

%SB GO
% drug
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0.8 0.8],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.7,'FaceColor',[0 0.3 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                 
%                 % saline
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                 
%                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 biggest_value+0.05],'Color',[0 0.8 0.8],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 biggest_value+0.05],'Color',[0 0.5 0.7],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0.2 0.1 0],'Linestyle','-.','LineWidth',2)


%                 % drug
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.7,'FaceColor',[0.5 0.2 0.8],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0.8 0.2 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                 
%                 % saline
%                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                 
%                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 1],'Color',[0.5 0.2 0.8],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 1],'Color',[0.7 0.2 0.7],'Linestyle','-.','LineWidth',2)
%                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 1],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)
% 
%                 legend('0.5 mg/kg','0.1 mg/kg','vehicle','median - 0.5 mg/kg','median - 0.1 mg/kg','median - vehicle','Location','northwest');


%-------------------------------------------------------------------------------------------------------------------

                    %
                    %                  % drug
                    %                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0.5 0.9],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
                    %                 histogram('BinEdges',bins_plot,'FaceAlpha',0.7,'FaceColor',[0 0.2 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
                    %
                    %                 % saline
                    %                 histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
                    %
                    %                 line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 biggest_value+0.05],'Color',[0 0.6 1.0],'Linestyle','-.','LineWidth',2)
                    %                 line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 biggest_value+0.05],'Color',[0 0.3 0.8],'Linestyle','-.','LineWidth',2)
                    %                 line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 biggest_value+0.05],'Color',[0.2 0.1 0],'Linestyle','-.','LineWidth',2)
                    
%                     histogram('BinEdges',bins_plot,'FaceAlpha',0.7,'FaceColor',[0.2 0.2 0.8],'LineWidth',2,'BinCounts',av_prop_binned_values(:,3,ireward)); hold on
%                     histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0.8 0.2 0.7],'LineWidth',2,'BinCounts',av_prop_binned_values(:,2,ireward)); hold on
%                     
%                     % saline
%                     histogram('BinEdges',bins_plot,'FaceAlpha',0.5,'FaceColor',[0 0 0.5],'LineWidth',2,'BinCounts',av_prop_binned_values(:,1,ireward)); hold on
%                     
%                     line([mean_rt_median(:,3,ireward),mean_rt_median(:,3,ireward)],[0 1],'Color',[0.5 0.2 0.8],'Linestyle','-.','LineWidth',2)
%                     line([mean_rt_median(:,2,ireward),mean_rt_median(:,2,ireward)],[0 1],'Color',[0.7 0.2 0.7],'Linestyle','-.','LineWidth',2)
%                     line([mean_rt_median(:,1,ireward),mean_rt_median(:,1,ireward)],[0 1],'Color',[0 0.1 0.2],'Linestyle','-.','LineWidth',2)
%                     
%                     legend('0.5 mg/kg','0.1 mg/kg','saline','median - 0.5 mg/kg','median - 0.1 mg/kg','median - saline','Location','northwest');
%                     