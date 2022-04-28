#######################################################################################################
# PACKAGES

# Load necessary packages
library('R.matlab') 
library('tidyverse') 
library('patchwork')

#######################################################################################################
# BASE HEATMAP
heatmap_theme <- theme_minimal() + 
  theme(text = element_text(size = 20), plot.title = element_text(hjust = 0.5), axis.ticks = element_blank(),
        panel.grid = element_blank(), legend.key.size = unit(0.5,'inch'),
        axis.title.x = element_text(margin = margin(10,0,0,0)),
        axis.title.y = element_text(margin = margin(0,12,0,0)))

#######################################################################################################
## LOCAL SENSITIVITY - AUC

local_AUC <- readMat('local_bivariate_auc.mat')
local_AUC <- as.data.frame(local_AUC)

parameters <- c('V1', 'V2', 'CL', 'Q', 'ka', 'kEO', 'BIO', 'RSyn', 'inf')
local_AUC <- cbind(parameters,local_AUC)
names(local_AUC) <- c('Parameter_1',parameters)

local_AUC <- pivot_longer(local_AUC, !Parameter_1, names_to = 'Parameter_2', values_to = 'Sensitivity')
local_AUC$Parameter_1 <- factor(local_AUC$Parameter_1, levels = c('V1', 'V2', 'CL', 'Q', 'ka', 'kEO', 'BIO', 'RSyn', 'inf'))
#view(local_AUC)

local_AUC_plot <- ggplot(data = local_AUC, aes(x = Parameter_1, y = Parameter_2, fill = Sensitivity)) +
  geom_tile() +
  scale_fill_distiller(name = 'Sensitivity ', palette = 'PiYG') +
  labs(title = 'Local Bivariate Sensitivity of AUC') +
  heatmap_theme

ggsave(filename = 'local_AUC.png', plot = local_AUC_plot, width = 12, height = 8)

#######################################################################################################
## LOCAL SENSITIVITY - VAR

local_Var <- readMat('local_bivariate_var.mat')
local_Var <- as.data.frame(local_Var)

parameters <- c('V1', 'V2', 'CL', 'Q', 'ka', 'kEO', 'BIO', 'RSyn', 'inf')
local_Var <- cbind(parameters,local_Var)
names(local_Var) <- c('Parameter_1',parameters)

local_Var <- pivot_longer(local_Var, !Parameter_1, names_to = 'Parameter_2', values_to = 'Sensitivity')
local_Var$Parameter_1 <- factor(local_Var$Parameter_1, levels = c('V1', 'V2', 'CL', 'Q', 'ka', 'kEO', 'BIO', 'RSyn', 'inf'))
#view(local_Var)

local_Var_plot <- ggplot(data = local_Var, aes(x = Parameter_1, y = Parameter_2, fill = Sensitivity)) +
  geom_tile() +
  scale_fill_distiller(name = 'Sensitivity ', palette = 'PiYG') +
  labs(title = 'Local Bivariate Sensitivity of Variance') +
  heatmap_theme

ggsave(filename = 'local_Var.png', plot = local_Var_plot, width = 12, height = 8)

#######################################################################################################
## GLOBAL SENSITIVITY - AUC
CL <- readMat('CL.mat')
Rsyn <- readMat('Rsyn.mat')
CL <- as.data.frame(CL)
Rsyn <- as.data.frame(Rsyn)

global_AUC <- readMat('global_sensitivity_AUC.mat')
global_AUC <- as.data.frame(global_AUC)
#view(global_AUC)

range <- c('0.1', '0.167', '0.278', '0.464', '0.774', '1.292', '2.154', '3.594', '5.995', '10')

global_AUC <- cbind(range,global_AUC)
names(global_AUC) <- c('Rsyn',range)
#view(global_AUC)

global_AUC <- pivot_longer(global_AUC, !Rsyn, names_to = 'CL', values_to = 'Sensitivity')
global_AUC$Rsyn <- factor(global_AUC$Rsyn, levels = range)
#view(global_AUC)

global_AUC_plot <- ggplot(data = global_AUC, aes(x = Rsyn, y = CL, fill = Sensitivity)) +
  geom_tile() +
  scale_fill_distiller(name = 'Sensitivity ', palette = 'PiYG') +
  labs(title = 'Global Sensitivity of AUC over a Range of CL and Rsyn') +
  heatmap_theme

ggsave(filename = 'global_AUC.png', plot = global_AUC_plot, width = 12, height = 8)


#######################################################################################################
## GLOBAL SENSITIVITY - Var

global_Var <- readMat('global_sensitivity_var.mat')
global_Var <- as.data.frame(global_Var)
#view(global_Var)

range <- c('0.1', '0.167', '0.278', '0.464', '0.774', '1.292', '2.154', '3.594', '5.995', '10')

global_Var <- cbind(range,global_Var)
names(global_Var) <- c('Rsyn',range)
#view(global_Var)

global_Var <- pivot_longer(global_Var, !Rsyn, names_to = 'CL', values_to = 'Sensitivity')
global_Var$Rsyn <- factor(global_Var$Rsyn, levels = range)
#view(global_Var)

global_Var_plot <- ggplot(data = global_Var, aes(x = Rsyn, y = CL, fill = Sensitivity)) +
  geom_tile() +
  scale_fill_distiller(name = 'Sensitivity ', palette = 'PiYG') +
  labs(title = 'Global Sensitivity of Variance over a Range of CL and Rsyn') +
  heatmap_theme

ggsave(filename = 'global_Var.png', plot = global_Var_plot, width = 12, height = 8)

