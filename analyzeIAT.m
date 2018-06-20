function analyzeIAT 
 
%20 practice trials (DEATH LIFE)
%20 practice trials (ME NOT ME)
%20 practice 4 group trials
%40 TEST trials (congruent hypothesis group=1)
%20 practice trials (LIFE DEATH)
%20 practice 4 group trials
%40 TEST trials (opposite of the other test trials)
 
%computes d-scores across subject
%programmed and last updated 11/27/16 by TH
 
d.sn={'XX','XX'} %manually input subject ID here or...
textfile=fopen('columnofsubjectIDs.txt','rt');
text=textscan(textfile,'%s');
fclose(textfile)
d.sn=text{1};
  
root=[pwd,'\Subject Data\'];
subjects=cellstr(d.sn);
     
%informing on scoring algorithm found here:
%https://faculty.washington.edu/agg/IATmaterials/Summary%20of%20Improved%20Scoring%20Algorithm.pdf

results.numlong=[];
results.numguesses=[];
results.diff1=[];
results.diff2=[];
results.d=[];
results.group=[];
badsubj=[];
results.badsubj=ones(length(d.sn),1);

%block 1 is 20 trials of sorting one category
%block 2 is 20 trials of sorting another category
%block 3 is 20 practice (equiv of stage 3 in Greenwald) and 40 test (equiv of stage 4 in Greenwald)
%block 4 is switch (20 trials; equiv of stage 5 in Greenwald)
%block 5 is 20 practice (equiv of stage 6 in Greenwald) and 40 test (equiv
%of stage 7 in Greenwald)
 
%subject loop
for ss=1:length(d.sn)
    f = dir([root, char(subjects(ss)),'_IAT1.mat']);
    numBlks = length(f);
    load([root,f.name]);
    d.rt=p.rt'; 
    d.correct=p.correct'; 
    d.group=p.group;
    results.group=[results.group;p.group]
     %p.group determines if block3 is DEATH-ME pairing (1) or LIFE-ME
    %pairing (2)
     
%delete any trials greater than 10 s or < 300 ms
    
 %   badind = find(d.rt>10 || d.rt<0.03);
    results.numlong(ss,:)=length(find(d.rt>10));
    d.rt(d.rt>5)=NaN;
    results.numguesses(ss,:)=length(find(d.rt<.03)); 
        if results.numguesses(ss,:)>8 %if more than 8 trials are "bad" then the subj shouldn't be included
            d.sn(ss)
        badsubj=[badsubj;d.sn(ss)] %prints out subjects who should be excluded
        results.badsubj(ss)=0; %0=bad, 1=good
        end
    d.rt(d.rt<0.03)=NaN;

    inclusive_std1=nanstd([d.rt(41:60); d.rt([121:140])]); %stage 3 & 6 (practice trials)
    inclusive_std2=nanstd([d.rt(61:100);d.rt(141:180)]); %stage 4 & 7   (test trials)
    stage3_rt=nanmean(d.rt(41:60));
    stage4_rt=nanmean(d.rt(61:100));
    stage6_rt=nanmean(d.rt(121:140));
    stage7_rt=nanmean(d.rt(141:180));
    
    if d.group==1
        results.diff1(ss,:)=(stage6_rt-stage3_rt)/inclusive_std1;
        results.diff2(ss,:)=(stage7_rt-stage4_rt)/inclusive_std2;
      elseif d.group==2
        results.diff1(ss,:)=(stage3_rt-stage6_rt)/inclusive_std1;
        results.diff2(ss,:)=(stage4_rt-stage7_rt)/inclusive_std2;
    end
    
   results.d(ss,:)=mean([results.diff1(ss,:),results.diff2(ss,:)]); %using regular mean because no NaNs should be present by this stage
   results.subj=d.sn';
   
   %if you want d-score based on the standard IAT scoring algorithm only
   %use results.diff2...that is what we used for the paper
  
end
% 
%results
 save('yourfilename.mat','results')