# Load necessary packages
library("R.matlab")
library("tidyverse")
library("plotly")

# Load data into a dataframe
data <- readMat("results_baseline.mat")
df1 <- as.data.frame(data)
data <- readMat("results_infusion_10.mat")
df2 <- as.data.frame(data)
data <- readMat("results_infusion_20.mat")
df3 <- as.data.frame(data)
data <- readMat("results_infusion_30.mat")
df4 <- as.data.frame(data)
data <- readMat("results_infusion_60.mat")
df5 <- as.data.frame(data)
data <- readMat("results_infusion_120.mat")
df6 <- as.data.frame(data)

# rename columns
names(df1) <- c("C1", "C2", "E", "Time")
names(df2) <- c("C1", "C2", "E", "Time")
names(df3) <- c("C1", "C2", "E", "Time")
names(df4) <- c("C1", "C2", "E", "Time")
names(df5) <- c("C1", "C2", "E", "Time")
names(df6) <- c("C1", "C2", "E", "Time")

comp1 = data.frame(df1$Time, df1$C1, df2$C1, df3$C1, df4$C1, df5$C1, df6$C1)
comp2 = data.frame(df1$Time, df1$C2, df2$C2, df3$C2, df4$C2, df5$C2, df6$C2)
effect = data.frame(df1$Time, df1$E, df2$E, df3$E, df4$E, df5$E, df6$E)

# rename columns
names(comp1) <- c("Time", "C1_0", "C1_10", "C1_20", "C1_30", "C1_60", "C1_120")
names(comp2) <- c("Time", "C2_0", "C2_10", "C2_20", "C2_30", "C2_60", "C2_120")
names(effect) <- c("Time", "E_0", "E_10", "E_20", "E_30", "E_60", "E_120")

library("tidyverse")
df1 <- comp1 %>% gather(key = "missed", value = "value", -Time)
df2 <- comp2 %>% gather(key = "missed", value = "value", -Time)
df3 <- effect %>% gather(key = "missed", value = "value", -Time)

# save theme
my_theme <- theme_classic() + 
  theme(text = element_text(size = 20),
        plot.title = element_text(hjust = 0.5),
        axis.title.x = element_text(margin = margin(10,0,0,0)),
        axis.title.y = element_text(margin = margin(0,10,0,0)),
        axis.text.x = element_text(margin = margin(5,0,0,0)),
        axis.text.y = element_text(margin = margin(0,5,0,0)))


# plot concentration of drug in the blood
p1 <- ggplot(data = df1, aes(x = Time, y=value)) + 
  geom_line(aes(color = missed), size=2) +
  xlab('Time (min)') +
  ylab('[D] (mg/mL)') +
  my_theme

p1 + scale_colour_discrete(name  ="Duration of Missed Infusion",
                      breaks=c("C1_0", "C1_10", "C1_20", "C1_30", "C1_60", "C1_120"),
                      labels=c("Baseline", "10 mins", "20 mins", "30 mins", "60 mins", "120 mins")) + 
  ggtitle('Effect of Missing Infusion on Levodopa Concentration in Central Compartment') +
  theme(legend.position="bottom")

# plot concentration of drug in the blood
p2 <- ggplot(data = df2, aes(x = Time, y=value)) + 
  geom_line(aes(color = missed), size=2) +
  xlab('Time (min)') +
  ylab('[D] (mg/mL)') +
  my_theme


p2 + scale_colour_discrete(name  ="Duration of Missed Infusion",
                           breaks=c("C2_0", "C2_10", "C2_20", "C2_30", "C2_60", "C2_120"),
                           labels=c("Baseline", "10 mins", "20 mins", "30 mins", "60 mins", "120 mins")) + 
  ggtitle('Effect of Missing Infusion on Levodopa Concentration in Peripheral Compartment') +
  theme(legend.position="bottom")


# plot concentration of drug in the blood
p3 <- ggplot(data = df3, aes(x = Time, y=value)) + 
  geom_line(aes(color = missed), size=2) +
  xlab('Time (min)') +
  ylab('Effect Level') +
  my_theme


p3 + scale_colour_discrete(name  ="Duration of Missed Infusion",
                           breaks=c("E_0", "E_10", "E_20", "E_30", "E_60", "E_120"),
                           labels=c("Baseline", "10 mins", "20 mins", "30 mins", "60 mins", "120 mins")) + 
  ggtitle('Effect of Missing Infusion on Levodopa Effect') +
  theme(legend.position="bottom")
