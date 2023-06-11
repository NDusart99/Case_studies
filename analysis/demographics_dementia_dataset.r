########################################################################
# Case Studies in Experimental Psychology: Analysis of Dementia dataset#
# Analysis of demographic variables                                    #
########################################################################
#R-script for the descriptive measures of the demographics per group of the dataset of 
#Miltiadous et al. (2023), 'A dataset of EEG recordings from: Alzheimer's disease, Frontotemporal dementia and Healthy subjects'

#clear working memory
rm(list = ls())
#load packages
library(dplyr)
library(reshape2)



#import dataset (set path to location of file), can be downloaded from: https://openneuro.org/datasets/ds004504/versions/1.0.5
participants <- read.delim("Path_to_folder/participants.txt")


#create dataset with sample size, gender, and mean and SD of age and MMSE scores per group (A = Alzheimer Disease, F = Frontotemporal Dementia, C = Control)
demographics <- participants%>%
  group_by(Group)%>%
  summarise(n = n(),n_males = sum(Gender == "M"), n_females = sum(Gender == "F"), mean_age = mean(Age), sd_age = sd(Age), mean_MMSE = mean(MMSE), sd_MMSE = sd(MMSE))



#test if groups are not significantly different based on demographics? 
#split datasets into groups
AD <- participants[participants$Group == "A",] # Alzheimer desease group
FTD <- participants[participants$Group == "F",] # Frontotemporal Dementia group
C <- participants[participants$Group == "C",] # Control group

#between AD and FTD group
t.test(AD$Age, FTD$Age, paired = FALSE) #not significanlty different
t.test(AD$MMSE, FTD$MMSE, paired = FALSE) #significanlty different

#between AD and C group
t.test(AD$Age, C$Age, paired = FALSE) #not significanlty different
t.test(AD$MMSE, C$MMSE, paired = FALSE) #significanlty different

#between FTD and C group
t.test(FTD$Age, C$Age, paired = FALSE) #significanlty different
t.test(FTD$MMSE, C$MMSE, paired = FALSE) #significanlty different

