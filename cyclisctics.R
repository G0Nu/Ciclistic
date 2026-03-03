# Installing all the neccesary libraries and packages
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("skim")
install.packages("Janitor")
library(skimr)
library(tidyverse)
library(ggplot2)
library(janitor)
#Importing the data so we can work on it in R
data2019 <- read.csv('C:/Users/diego/Downloads/Case Study_Cyclistic/Divvy_Trips_2019_Q1_copy.csv')
data2020 <- read.csv('C:/Users/diego/Downloads/Case Study_Cyclistic/Divvy_Trips_2020_Q1_copy.csv')
#Getting a sneak peak to understand the data
head(data2019)
head(data2020)
colnames(data2019)
colnames(data2020)
#Cleaning the data
skim_without_charts(data2019)
data2019 %>%
  select(gender)
clean_names(data2019)
colnames(data2019)
data2019 %>% arrange(-birthyear) # to see the youngest person
data2019 %>% arrange(birthyear) # to see the oldest person 
colnames(data2019)
data2019 %>% arrange(tripduration)
head(data2019)
data2019 %>%
  select(gender)
#removing white spaces from all the columns
drop_na(data2019)
colnames(data2019)
data2019 %>% arrange(tripduration)