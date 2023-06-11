#############################################################
# Case Studies in Experimental Psychology: Dementia dataset #
#############################################################
# This is an R-script for the further statistical analyses of the data, including
# calculating means per ROI, hypothesis testing and visualisation


#clear working memory
rm(list = ls())
#load packages
library(dplyr)
library(vroom)
library(stringr)
library(reshape2)
library(tidyr)
library(lme4)
library(car)
library(emmeans)
library(yarrr)



############ CREATE DATAFRAME FOR Analysis of EEGdata (n = 88) ###########

# import dataset with EEG data for each participant, acquired by the Matlab script 
setwd("Path_to_folder") # set working directory to folder with separate data files
# make a list of all txt files in folder
list_of_files <- list.files(path = ".", recursive = TRUE,
                            pattern = "\\.txt$", 
                            full.names = TRUE)
# Read all the files and create a FileName column to store filenames
psd_data <- vroom(list_of_files, id = "FileName", col_names = c("Channel", "Power"))

#split column FileName to create column with participant number
psd_data$participant_id<- factor(str_split_fixed(psd_data$FileName, '_',4 )[,4])
psd_data$participant_id<- factor(str_split_fixed(psd_data$participant_id, '.txt',2)[,1])


# import dataset with demographics and MMSE scores, can be downloaded from: https://openneuro.org/datasets/ds004504/versions/1.0.5
participants <- read.delim("Path_to_folder/participants.txt") #set path to location of participants file
# change lables of paricipant ID's to match labels of EEG dataset
participants$participant_id <- factor(str_split_fixed(participants$participant_id, '-',2 )[,2])

#combine EEG and demographics datasets
all_data <- right_join(psd_data, participants, by= c('participant_id'))


#visual inspection of outliers of EEG data
plot(all_data$Power) #There seem to be some outliers

#remove outliers
all_data <- all_data%>%
  mutate(mean=mean(Power),
         sd = sd(Power),
         min = mean - 2.5*sd,
         max = mean + 2.5*sd,
         remove = ifelse(Power<max&Power>min,'N','Y'))
table(all_data$remove, all_data$Group)

all_data <- all_data%>%
  filter(!remove=='Y')

#more outliers visible?
plot(all_data$Power) #it's looking better!



############ CALCULATE MEANS PER ROI ###########

# create new dataframe 'ROIs' with demographics + MMSE
ROIs<-data.frame("Participant"=unique(all_data$participant_id))
ROIs$Group<-all_data$Group[match(ROIs$Participant, all_data$participant_id)]
ROIs$Gender<-all_data$Gender[match(ROIs$Participant, all_data$participant_id)]
ROIs$Age<-all_data$Age[match(ROIs$Participant, all_data$participant_id)]
ROIs$MMSE<-all_data$MMSE[match(ROIs$Participant, all_data$participant_id)]

#define ROI's by electrodes
anterior <- c('Channel1:', 'Channel2:','Channel4:', 'Channel5:', 'Channel6:') # Fp1, F3, Fz, Fp2, F4
central <- c('Channel9:', 'Channel10:', 'Channel11:') # C3, Cz, C4
left_temp <- c('Channel8:', 'Channel13:', 'Channel3:') # T3, T5, F7
right_temp <- c('Channel12:', 'Channel17:', 'Channel7:') # T4, T6, F8
posterior <- c('Channel14:', 'Channel18:', 'Channel15:', 'Channel16:', 'Channel19:') # P3, O1, Pz, P4, O2

#calculate mean power per ROI per participant and add to dataframe
mean_anterior <- tapply(all_data$Power[which(all_data$Channel%in%anterior)], all_data$participant_id[which(all_data$Channel%in%anterior)], mean)
ROIs$anterior<-mean_anterior[match(ROIs$Participant, names(mean_anterior))]

mean_central <- tapply(all_data$Power[which(all_data$Channel%in%central)], all_data$participant_id[which(all_data$Channel%in%central)], mean)
ROIs$central<-mean_central[match(ROIs$Participant, names(mean_central))]

mean_left_temp <- tapply(all_data$Power[which(all_data$Channel%in%left_temp)], all_data$participant_id[which(all_data$Channel%in%left_temp)], mean)
ROIs$left_temp<-mean_left_temp[match(ROIs$Participant, names(mean_left_temp))]

mean_right_temp <- tapply(all_data$Power[which(all_data$Channel%in%right_temp)], all_data$participant_id[which(all_data$Channel%in%right_temp)], mean)
ROIs$right_temp<-mean_right_temp[match(ROIs$Participant, names(mean_right_temp))]

mean_posterior <- tapply(all_data$Power[which(all_data$Channel%in%posterior)], all_data$participant_id[which(all_data$Channel%in%posterior)], mean)
ROIs$posterior<-mean_posterior[match(ROIs$Participant, names(mean_posterior))]


##############################################
#                  ANALYSIS                  #
##############################################


#reshape data to long format for linear mixed model
data_long <-ROIs%>%
  pivot_longer(cols= c('anterior','central','left_temp','right_temp','posterior'), names_to = "ROI", values_to = "Mean_Power")
data_long$ROI <- factor(data_long$ROI, levels = c('anterior', 'central', 'left_temp', 'right_temp', 'posterior'))
data_long <- na.omit(data_long)

#descriptives: extract mean power and SD per group per ROI
Table_Power <- data_long%>%
  group_by(Group, ROI)%>%
  summarise(mean = mean(Mean_Power), sd = sd(Mean_Power))


#set contrasts to sum coding for ANOVA
options(contrasts = c("contr.sum", "contr.poly"))

#write linear mixed model
me_model <- lmer(Mean_Power ~ Group + ROI + Group*ROI + (1|Participant), data = data_long)
summary(me_model)
Anova(me_model, type = "III", test = "F")

#check residuals to see if normally distributed
hist(resid(me_model))
qqnorm(resid(me_model))

# estimated marginal means on the model to check which part of interaction is significant. 
emmeans(me_model, ~ Group*ROI)
pairs(emmeans(me_model, ~Group*ROI), simple = "each")


##############################################
#                Visualisation               #
##############################################

#set levels of groups and change labels for visualisation
data_long$Group <- factor(data_long$Group, levels = c('A', 'F', 'C'))
levels(data_long$Group) <- c('AD', 'FTD', 'CON')

#create pirate plot
pirateplot(formula = Mean_Power~Group + ROI, data = data_long, main = 'Mean Power of Alpha Waves', ylab = 'Mean Power')



