# Installing all the neccesary libraries and packages
install.packages("tidyverse")
install.packages("ggplot2")
library(tidyverse)
library(ggplot2)
#Importing the data so we can work on it in R
data2019 <- read.csv('C:/Users/diego/Downloads/Case Study_Cyclistic/Divvy_Trips_2019_Q1_copy.csv')
data2020 <- read.csv('C:/Users/diego/Downloads/Case Study_Cyclistic/Divvy_Trips_2020_Q1_copy.csv')
#Getting a sneak peak to understand the data
head(data2019)
head(data2020)
colnames(data2019)
colnames(data2020)
#Cleaning the data
