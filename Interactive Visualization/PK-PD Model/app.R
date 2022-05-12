###################################### Population Plot ######################################
# ==============================================================================
# LOAD PACKAGES

# Load necessary packages
library("R.matlab")
library("tidyverse")
library("patchwork")
library("plotly")
library("shiny")

# ==============================================================================
# DATA IMPORT

dd_C1 <- as.data.frame(readMat('pkpd_double_dose.mat')[2])
dd_C2 <- as.data.frame(readMat('pkpd_double_dose.mat')[3])
dd_E  <- as.data.frame(readMat('pkpd_double_dose.mat')[4])
time  <- as.data.frame(readMat('pkpd_double_dose.mat')[1])
di_C1 <- as.data.frame(readMat('pkpd_double_initial_dose.mat')[2])
di_C2 <- as.data.frame(readMat('pkpd_double_initial_dose.mat')[3])
di_E  <- as.data.frame(readMat('pkpd_double_initial_dose.mat')[4])
ds_C1 <- as.data.frame(readMat('pkpd_double_second_dose.mat')[2])
ds_C2 <- as.data.frame(readMat('pkpd_double_second_dose.mat')[3])
ds_E  <- as.data.frame(readMat('pkpd_double_second_dose.mat')[4])
ss_C1   <- as.data.frame(readMat('pkpd_normal_dose.mat')[2])
ss_C2   <- as.data.frame(readMat('pkpd_normal_dose.mat')[3])
ss_E   <- as.data.frame(readMat('pkpd_normal_dose.mat')[4])

# double_dose  <- cbind(dd_C1,dd_C2,dd_E,time)
# double_idose <- cbind(di_C1,di_C2,di_E,time)
# double_sdose <- cbind(ds_C1,ds_C2,ds_E,time)
# single_dose  <- cbind(ss_C1,ss_C2,ss_E,time)

central <- cbind(time, dd_C1, di_C1, ds_C1, ss_C1)
periph  <- cbind(time, dd_C2, di_C2, ds_C2, ss_C2)
effect  <- cbind(time, dd_E, di_E, ds_E, ss_E)


# col_names <- c("Central Compartment","Peripheral Compartment", "Effect Level")
col_names <- c("Time", "Double Bolus +\nDouble Maintenance\n", "Double Bolus +\nSingle Maintenance\n",
               "Single Bolus +\nDouble Maintenance\n","Single Bolus +\nSingle Maintenance\n")
colnames(central) <- col_names
colnames(periph)  <- col_names
colnames(effect)  <- col_names

central <- reshape2::melt(central, id.var = "Time")
periph  <- reshape2::melt(periph, id.var = "Time")
effect  <- reshape2::melt(effect, id.var = "Time")

# ==============================================================================
# PLOTTING

# Create a reusable theme
my_theme <- theme_classic() +
  theme(
    text = element_text(size = 22),
    plot.title = element_text(hjust = 1),
    legend.position = "right",
    axis.title.x = element_text(margin = margin(10,0,0,0)),
    axis.title.y = element_text(margin = margin(0,10,10,10)),
    axis.text.x = element_text(margin = margin(5,0,0,0)),
    axis.text.y = element_text(margin = margin(0,5,0,0)),
    legend.title = element_blank()
  )


plot1 <- ggplot(data = central, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
  scale_color_brewer(palette = 'Dark2') + my_theme +
  labs(title = 'Levodopa Concentration in Central Compartment v.s. Time', x = 'Time (min)', y = '[D] (mg/L)') +
  theme(text = element_text(size = 15), plot.title = element_text(size=20, hjust = 0.2),)

plot2 <- ggplot(data = periph, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
  scale_color_brewer(palette = 'Dark2') + my_theme + 
  labs(title = 'Levodopa Concentration in Peripheral Compartment v.s. Time', x = 'Time (min)', y = '[D] (mg/L)')

plot3 <- ggplot(data = effect, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
  scale_color_brewer(palette = 'Dark2') + my_theme + 
  labs(title = 'Levodopa Effect Level v.s. Time', x = 'Time (min)', y = 'Effect Level')

# Save graphs
ggsave(filename = 'plot1.png', plot = plot1, width = 8, height = 6)
ggsave(filename = 'plot2.png', plot = plot2, width = 8, height = 6)
ggsave(filename = 'plot3.png', plot = plot3, width = 8, height = 6)

# ==============================================================================
# APP UI

# Design UI for app
ui <- fluidPage(
  
  # App title
  titlePanel(strong("PK-PD Model Dose Optimization for Levodopa")),
  h4(p("A basic dose regimen optimization is performed for the proposed Levodopa 
  PKPD model to get the most consistent effectiveness of levodopa at reducing 
       symptoms of Parkinson’s disease in an individual.")),
  h5(p("App by Group 6 - Levodopa (Daniel, Heena, Liza, Syed Yusuf, Matthew) for ", 
       em("Systems Pharmacology and Personalized Medicine Spring 2022"))),
  # Spacing for aesthetics
  br(),
  
  # Add a sidebar panel to the UI with the check boxes
  # inputId needs to match how the input is called in the server section,
  # label gives the text accompanying the boxes, choices are the choices
  # on the buttons (first text is button text, second is how it will be
  # stored in R), selected is the default when the app is loaded
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      # Add a sidebar panel to the UI with the check boxes
      # inputId needs to match how the input is called in the server section,
      # label gives the text accompanying the boxes, choices are the choices
      # on the buttons (first text is button text, second is how it will be
      # stored in R), selected is the default when the app is loaded
      fluidRow(checkboxGroupInput(
        inputId = "dose",
        label = "Please select Dose:",
        choices = c(
          "Double Bolus + Double Maintenance" = "Double Bolus +\nDouble Maintenance\n",
          "Double Bolus + Single Maintenance" = "Double Bolus +\nSingle Maintenance\n",
          "Single Bolus + Double Maintenance" = "Single Bolus +\nDouble Maintenance\n",
          "Single Bolus + Single Maintenance" = "Single Bolus +\nSingle Maintenance\n"
        ),
        selected = c("Double Bolus +\nDouble Maintenance\n", "Double Bolus +\nSingle Maintenance\n",
               "Single Bolus +\nDouble Maintenance\n","Single Bolus +\nSingle Maintenance\n")
      ), 
      br())),
      
    # Display the Plotly plot in the main panel
    mainPanel(
      width = 9,
      fluidRow(column(9,plotlyOutput(outputId = "plot_1", width = 1000, height = 500))), 
      fluidRow(column(9,plotlyOutput(outputId = "plot_2", width = 1000, height = 500))), 
      fluidRow(column(9,plotlyOutput(outputId = "plot_3", width = 1000, height = 500)))
    )
  ))



# ==============================================================================
# APP SERVER

# Create R code for app functions
server <- function(input, output) {
  
  
        # Create reactive Plotly plot for app
        output$plot_1 <- renderPlotly({
          
          # Filter data to only include selected datapoints
          central_filtered <- filter(central, variable %in% c(input$dose,"Time"))
          # Add lines and points with filtered data
          plot1 <- ggplot(data = central_filtered, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
            scale_color_brewer(palette = 'Dark2') + my_theme +
            labs(title = 'Levodopa Concentration in Central Compartment v.s. Time', x = 'Time (min)', y = '[D] (mg/L)') +
            scale_y_continuous(limit = c(0,80))
          # Convert ggplot to Plotly plot
          plotly_build(plot1)
          gp <- ggplotly(plot1) 
          gp[['x']][['layout']][['title']][['font']][['size']]  <- 26
          gp[['x']][['layout']][['legend']][['title']][['text']]  <- NULL
          gp %>% layout(margin = list(b = 0, l =200, t = 50, r = 50))
        })
        
        # Create reactive Plotly plot for app
        output$plot_2 <- renderPlotly({
          
          # Filter data to only include selected datapoints
          periph_filtered <- filter(periph, variable %in% c(input$dose,"Time"))
          # Add lines and points with filtered data
          plot2 <- ggplot(data = periph_filtered, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
            scale_color_brewer(palette = 'Dark2') + my_theme + 
            labs(title = 'Levodopa Concentration in Peripheral Compartment v.s. Time', x = 'Time (min)', y = '[D] (mg/L)') +
            scale_y_continuous(limit = c(0,120))
          
          # Convert ggplot to Plotly plot
          plotly_build(plot2)
          gp <- ggplotly(plot2) 
          gp[['x']][['layout']][['title']][['font']][['size']]  <- 26
          gp[['x']][['layout']][['legend']][['title']][['text']]  <- NULL
          gp %>% layout(margin = list(b = 0, l =200, t = 50, r = 50))
        })
        
        # Create reactive Plotly plot for app
        output$plot_3 <- renderPlotly({
          
          # Filter data to only include selected datapoints
          effect_filtered <- filter(effect, variable %in% c(input$dose,"Time"))
          # Add lines and points with filtered data
          plot3 <- ggplot(data = effect_filtered, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
            scale_color_brewer(palette = 'Dark2') + my_theme + 
            labs(title = 'Levodopa Effect Level v.s. Time', x = 'Time (min)', y = 'Effect Level') + 
            scale_y_continuous(limit = c(-1.5,1))
          # Convert ggplot to Plotly plot
          plotly_build(plot3)
          gp <- ggplotly(plot3) 
          gp[['x']][['layout']][['title']][['font']][['size']]  <- 26
          gp[['x']][['layout']][['legend']][['title']][['text']]  <- NULL
          gp %>% layout(margin = list(b = 0, l =200, t = 50, r = 50))
  })
  
  
}

# ==============================================================================
# BUILD APP

# Knit UI and Server to create app
shinyApp(ui = ui, server = server)


