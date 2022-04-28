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

dd_C1 <- as.data.frame(readMat('pkpd_double_dose.mat')[1])
dd_C2 <- as.data.frame(readMat('pkpd_double_dose.mat')[2])
dd_E  <- as.data.frame(readMat('pkpd_double_dose.mat')[3])
time  <- as.data.frame(readMat('pkpd_double_dose.mat')[4])
di_C1 <- as.data.frame(readMat('pkpd_double_initial_dose.mat')[1])
di_C2 <- as.data.frame(readMat('pkpd_double_initial_dose.mat')[2])
di_E  <- as.data.frame(readMat('pkpd_double_initial_dose.mat')[3])
ds_C1 <- as.data.frame(readMat('pkpd_double_second_dose.mat')[1])
ds_C2 <- as.data.frame(readMat('pkpd_double_second_dose.mat')[2])
ds_E  <- as.data.frame(readMat('pkpd_double_second_dose.mat')[3])
ss_C1   <- as.data.frame(readMat('pkpd_normal_dose.mat')[1])
ss_C2   <- as.data.frame(readMat('pkpd_normal_dose.mat')[2])
ss_E   <- as.data.frame(readMat('pkpd_normal_dose.mat')[3])

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
    plot.title = element_text(hjust = 0.5),
    legend.position = "right",
    axis.title.x = element_text(margin = margin(10,0,0,0)),
    axis.title.y = element_text(margin = margin(0,10,10,10)),
    axis.text.x = element_text(margin = margin(5,0,0,0)),
    axis.text.y = element_text(margin = margin(0,5,0,0)),
    legend.title = element_blank()
  )


plot1 <- ggplot(data = central, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
  scale_color_brewer(palette = 'Dark2') + my_theme + 
  labs(title = 'Levodopa Concentration in Central Compartment v.s. Time', x = 'Time (min)', y = '[D] (mg/L)')

plot2 <- ggplot(data = periph, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
  scale_color_brewer(palette = 'Dark2') + my_theme + 
  labs(title = 'Levodopa Concentration in Peripheral Compartment v.s. Time', x = 'Time (min)', y = '[D] (mg/L)')

plot3 <- ggplot(data = effect, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
  scale_color_brewer(palette = 'Dark2') + my_theme + 
  labs(title = 'Levodopa Effect Level v.s. Time', x = 'Time (min)', y = 'Effect Level')

# ==============================================================================
# APP UI

# Design UI for app
ui <- fluidPage(
  
  # App title
  titlePanel(strong("Weight-Based Population Pharmacokinetics of Vancomycin Model")),
  h5(p("App by Heena Saqib for Systems Pharmacology and Personalized Medicine Spring 2022")),
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
        inputId = "IIV_option",
        label = "idk what to do here yet",
        choices = c(
          "Hi" = "Without_IIV",
          "Have a good day" = "With_IIV"
        ),
        selected = c("Without_IIV","With_IIV")
      ), 
      br())),
      
    # Display the Plotly plot in the main panel
    mainPanel(
      width = 9,
      fluidRow(plotlyOutput(outputId = "plot_1", width = 1000, height = 500)), 
      br(),
      fluidRow(plotlyOutput(outputId = "plot_2", width = 1000, height = 500)), 
      br(),
      fluidRow(plotlyOutput(outputId = "plot_3", width = 1000, height = 500)),br(),br()
    )
  ))



# ==============================================================================
# APP SERVER

# Create R code for app functions
server <- function(input, output) {
  
          # Filter data to only include selected datapoints
          # data_filtered <- reactive({
          #   filter(df_Q6, IIV %in% input$IIV_option)
          # })
          # AUCc_filtered <- reactive({
          #   filter(AUC_central, IIV %in% input$IIV_option)
          # })
          # AUCp_filtered <- reactive({
          #   filter(AUC_periphl, IIV %in% input$IIV_option)
          # })
          # 
        # Create reactive Plotly plot for app
        output$plot_1 <- renderPlotly({
          
          # Add lines and points with filtered data
          plot1 <- plot1
          # Convert ggplot to Plotly plot
          plotly_build(plot1)
          gp <- ggplotly(plot1) 
          gp[['x']][['layout']][['title']][['font']][['size']]  <- 26
          gp[['x']][['layout']][['legend']][['title']][['text']]  <- NULL
          gp %>% layout(margin = list(b = 0, l =200, t = 50, r = 50))
        })
        
        # Create reactive Plotly plot for app
        output$plot_2 <- renderPlotly({
          
          # Add lines and points with filtered data
          plot2 <- plot2
          
          # Convert ggplot to Plotly plot
          plotly_build(plot2)
          gp <- ggplotly(plot2) 
          gp[['x']][['layout']][['title']][['font']][['size']]  <- 26
          gp[['x']][['layout']][['legend']][['title']][['text']]  <- NULL
          gp %>% layout(margin = list(b = 0, l =200, t = 50, r = 50))
        })
        
        # Create reactive Plotly plot for app
        output$plot_3 <- renderPlotly({
          
          # Add lines and points with filtered data
          plot3 <- plot3 + scale_y_continuous(limit = c(-1.5,1))
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


