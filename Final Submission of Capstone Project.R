# Bike Data Analysis

# Load the libraries needed for this analysis

library(tidyverse)
library(purrr)
library(lubridate)
library(ggplot2)
library(janitor)


#Load the dataset

bike_data <- dir('cyclistdata', full.names = T)%>% map_df(read_csv)

head(bike_data)
summary(bike_data)
str(bike_data)
names(bike_data)


#Cleaning and organizing data

bike_data <- bike_data%>% select(ride_id, rideable_type, started_at, ended_at, start_station_name, member_casual)
View(bike_data)

#rename column to personal preference

bike_data <- bike_data%>% rename(id= ride_id, type=rideable_type, membership= member_casual)

# remove empty rows

bike_data <- na.omit(bike_data)

# Data manipulation
# Let's create columns for trip_duration, date, month, day_of_week, day, and hour.

bike_data$trip_duration <-  difftime(bike_data$ended_at,bike_data$started_at)

# Convert trip duration to numeric

is.numeric(bike_data$trip_duration)
bike_data$trip_duration <- as.numeric(bike_data$trip_duration)
is.numeric(bike_data$trip_duration)

# To create a date column
bike_data$date <- format(as.Date(bike_data$started_at))
# To create a month column
bike_data$month <- format(as.Date(bike_data$date), "%m")

# To convert the month number into text i.e January, February etc

is.numeric(bike_data$month)
bike_data$month <- as.numeric(bike_data$month)
is.numeric(bike_data$month)
bike_data$month <- month.name[bike_data$month]
bike_data$month <- factor(bike_data$month, levels = c("January", "February", "March", "April", "May", "June",
                                                      "July", "August", "October", "November", "December"))

# To create a day column
bike_data$day <- format(as.Date(bike_data$date), "%d")

#To create a hour column

bike_data$hour <- format(as_datetime(bike_data$started_at), "%H")

#To create day of week column

bike_data$day_of_week <- format(as.Date(bike_data$date), "%A")
# To create an ordered day of the week

bike_data$day_of_week <- ordered(bike_data$day_of_week, levels=c("Monday", "Tuesday",
                                                                 "Wednesday", "Thursday", "Friday",
                                                                 "Saturday", "Sunday"))

bike_data <- bike_data%>% filter(trip_duration >= 0)

# Data aggregation
summary_data <- bike_data%>% group_by(membership)%>%
  summarise(avg_ride_length = mean(trip_duration),
            median_ride_length = median(trip_duration),
            max_ride_length = max(trip_duration),
            min_ride_length = min(trip_duration))
# Analyse and Share phase

# Create a basic column chart to visualize number of rides by month

bike_data%>%
  group_by(month)%>%
  drop_na()%>%
  summarise(number_of_rides = n())%>%
  ggplot(aes(month, number_of_rides, fill= month)) + geom_col()+
  scale_y_continuous(labels = scales::comma) +
  labs(x= "Month", y="Number of Rides", title = "Number of Rides by Month")+
  theme_bw()

#Create a basic column chart to visualize number of rides by month across members

bike_data%>%
  group_by(month, membership)%>%
  drop_na()%>%
  summarise(no_of_rides= n())%>%
  ggplot(aes(month,no_of_rides, fill=membership )) + geom_col(position= "dodge")+
  scale_y_continuous(labels = scales::comma)+
  labs(x="Month", y="Number of Rides", title="Number of Rides by month across Members")+
  theme_bw()

#Create a basic column chart to visualize number of rides by hour

bike_data%>%
  group_by(hour)%>%
  summarise(number_of_rides= n())%>%
  ggplot(aes(hour, number_of_rides, fill=hour))+
  geom_col()+ scale_y_continuous(labels= scales::comma)+
  labs(x="Hour", y="Number of Rides", title="Number of Rides by Hour")
  
#Create a basic column chart to visualize number of rides by hour across members

bike_data%>%
  group_by(hour, membership)%>%
  summarise(number_of_rides= n())%>%
  ggplot(aes(hour, number_of_rides, fill=membership))+
  geom_col(position="dodge")+ scale_y_continuous(labels= scales::comma)+
  labs(x="Hour", y="Number of Rides", title="Number of Rides by Hour across members")+
  theme_bw()

#Create a basic column chart to visualize number of rides by week day
bike_data%>%
  group_by(day_of_week)%>%
  summarise(number_of_rides= n())%>%
  ggplot(aes(day_of_week, number_of_rides, fill= day_of_week))+
  geom_col()+ scale_y_continuous(labels= scales::comma)+
  labs(x="Day of Week", y="Number of Rides", title="Number of Rides by Week Day")+
  theme_bw()

 #Create a basic column chart to visualize number of rides by week day across members
bike_data%>%
  group_by(day_of_week, membership)%>%
  summarise(number_of_rides= n())%>%
  ggplot(aes(day_of_week, number_of_rides, fill= membership))+
  geom_col(position="dodge")+ scale_y_continuous(labels= scales::comma)+
  labs(x="Day of Week", y="Number of Rides", title="Number of Rides by Week Day across members")+
  theme_bw()

# Create a basic column chart that shows which type of rides member prefer

bike_data%>%
  group_by(type, membership)%>%
  summarise(no_of_rides = n())%>%
  ggplot(aes(type, no_of_rides, fill=membership))+ geom_col(position="dodge")+
  scale_y_continuous(labels= scales::comma)+
  labs(x= "Bike Type", y="Number of Rides", title="Number of Rides by bike type across members")

# Create a basic column chart that shows which average number of rides by day between members

bike_data%>%
  group_by(day_of_week, membership)%>%
  summarise(avg_bike_rides = mean(trip_duration))%>%
  ggplot(aes(day_of_week, avg_bike_rides, fill=membership)) +
  geom_col(position= "dodge") + scale_y_continuous(labels= scales::comma) +
  labs(x="Week Day", y="Average number of Rides", title="Average number of rides per weekday between members")+
  theme_bw()

tabyl(bike_data$membership)

# Create a basic column chart that shows which average number of rides by hour between members

bike_data%>%
  group_by(hour, membership)%>%
  summarise(avg_bike_rides= mean(trip_duration))%>%
  ggplot(aes(hour, avg_bike_rides, fill= membership))+
  geom_col(position="dodge")+ scale_y_continuous(labels= scales::comma)+
  labs(x= "Hour", y="Average Number of Rides", title="Average number of rides by hour across members")+
  theme_bw()

bike_data%>%
  group_by(hour, membership)%>%
  summarise(no_of_rides = n())%>%
  ggplot(aes(hour, no_of_rides, fill= membership)) + geom_line() + scale_y_continuous(labels= scales::comma)
  
