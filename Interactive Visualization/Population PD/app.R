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

E_EC50 <- as.data.frame(readMat('popPD_data.mat')[1])
E_gamm <- as.data.frame(readMat('popPD_data.mat')[2])
E_norm <- as.data.frame(readMat('popPD_data.mat')[3])
time   <- as.data.frame(readMat('popPD_data.mat')[4])

E_EC50_mean <- rowMeans(E_EC50)
E_gamm_mean <- rowMeans(E_gamm)

df_E     <- cbind(E_norm, E_EC50_mean, E_gamm_mean, time)
df_EC50  <- cbind(E_EC50, time)
df_gamm  <- cbind(E_gamm, time)

colnames(df_E) <- c("No Population Variability","Varied EC50","Varied Hill Parameter","Time")

df_E    <- reshape2::melt(df_E, id.var = 'Time')
df_EC50 <- reshape2::melt(df_EC50, id.var = 'T')
df_gamm <- reshape2::melt(df_gamm, id.var = 'T')

colnames(df_EC50) <- c('Time','variable','value')
colnames(df_gamm) <- c('Time','variable','value')

df_EC50 <- subset(df_EC50, select = -variable)
df_gamm <- subset(df_gamm, select = -variable)
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


plot1 <- ggplot(data = df_E, aes(x = Time, y = value, color = variable)) + geom_line(size = 1.2) + 
                scale_color_brewer(palette = 'Dark2') + my_theme + 
                scale_y_continuous(limits = c(-1.5,1)) +
                labs(title = 'Mean Effect Level With Varied Population Pharmacodynamic', x = 'Time (min)', y = 'Effect Level')


# ==============================================================================
# APP UI

# Design UI for app
ui <- fluidPage(
  
        # App title
        titlePanel(strong("Population Pharmacodynamic of Levodopa Model")),
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
              inputId = "simulation_option",
              label = "Show 500 patient data simulated for population variability:",
              choices = c(
                "EC50" = "EC50",
                "Hill Parameter" = "Hill Parameter",
                "None" = "None"
              ),
              selected = c("None")
            ),
            br(),
            h4(p("Panel 1: Line plot of effect level of Levodopa therapy on 500 simulated patient with population
                 variability in PD parameters including EC50 and Hill function parameter. User can opt to display
                 500 patient simulated data. The default of this app doesn't show simulated data for clarity;
                 instead, it shows the mean of simulated data for EC50 and Hill parameter variation.")
            )
            ),
            br(),br(),br(),br(),br(),br(),br(), br()),
          
          # Display the Plotly plot in the main panel
          mainPanel(
            width = 9,
            fluidRow(plotlyOutput(outputId = "plot_1", width = 1000)), 
            br(), br()
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
          #   filter(AUC_central, variable %in% input$variable_option)
          # })
          # AUCp_filtered <- reactive({
          #   filter(AUC_periphl, variable %in% input$variable_option)
          # })
          
          
          # Create reactive Plotly plot for app
          output$plot_1 <- renderPlotly({
            
            if (input$simulation_option == 'EC50'){
              plot_out1 <- plot1 +
                           geom_line(data = df_EC50, aes(x = Time, y = value), color = "#D95F02", alpha = 0.2) 
            } else if (input$simulation_option == 'Hill Parameter') {
              plot_out1 <- plot1 + 
                       geom_line(data = df_gamm, aes(x = Time, y = value), color = "#7570B3", alpha = 0.2) 
            } else if (input$simulation_option == c('EC50','Hill Parameter')){
              plot_out1 <- plot1 +
                geom_line(data = df_EC50, aes(x = Time, y = value, color = "#D95F02"), alpha = 0.2) +
                geom_line(data = df_gamm, aes(x = Time, y = value, color = "#7570B3"), alpha = 0.2)
            } else{
              plot_out1 <- plot1
            }
            # Convert ggplot to Plotly plot
            plotly_build(plot_out1)
            gp <- ggplotly(plot_out1) 
            gp[['x']][['layout']][['title']][['font']][['size']]  <- 26
            gp[['x']][['layout']][['legend']][['title']][['text']]  <- NULL
            gp %>% layout(margin = list(b = 0, l =200, t = 50, r = 50))
            
          })
          
}

# ==============================================================================
# BUILD APP

# Knit UI and Server to create app
shinyApp(ui = ui, server = server)