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

AUC_central_arr1 <- as.data.frame(readMat('popPK_data.mat')[1])
AUC_central_arr2 <- as.data.frame(readMat('popPK_data.mat')[2])
AUC_central_arr3 <- as.data.frame(readMat('popPK_data.mat')[3])
AUC_central_arr4 <- as.data.frame(readMat('popPK_data.mat')[4])
AUC_central_arr5 <- as.data.frame(readMat('popPK_data.mat')[5])
AUC_periphl_arr1 <- as.data.frame(readMat('popPK_data.mat')[6])
AUC_periphl_arr2 <- as.data.frame(readMat('popPK_data.mat')[7])
AUC_periphl_arr3 <- as.data.frame(readMat('popPK_data.mat')[8])
AUC_periphl_arr4 <- as.data.frame(readMat('popPK_data.mat')[9])
AUC_periphl_arr5 <- as.data.frame(readMat('popPK_data.mat')[10])


AUC_central <- cbind(AUC_central_arr1,AUC_central_arr2,AUC_central_arr3,AUC_central_arr4,AUC_central_arr5)
AUC_periphl <- cbind(AUC_periphl_arr1,AUC_periphl_arr2,AUC_periphl_arr3,AUC_periphl_arr4,AUC_periphl_arr5)

col_names <- c('CL Only', 'Vc Only', 'Vp Only', 'Q Only', 'Varied All')
colnames(AUC_central) <- col_names
colnames(AUC_periphl) <- col_names

AUC_central <- reshape2::melt(AUC_central)
AUC_periphl <- reshape2::melt(AUC_periphl)

# colnames(AUC_central) <- c('CL only Central', 'Vc only Central', 'Vp only Central', 'Q only Central', 'Varied all Central')
# colnames(AUC_periphl) <- c('CL only Periphral', 'Vc only Periphral', 'Vp only Periphral', 'Q only Periphral', 'Varied all Periphral')
# 
# df <- reshape2::melt(cbind(AUC_central,AUC_periphl))

# ==============================================================================
# PLOTTING

# Create a reusable theme
my_theme <- theme_classic() +
  theme(
    text = element_text(size = 22),
    plot.title = element_text(hjust = 0.5)
  )



# ==============================================================================
# APP UI

# Design UI for app
ui <- fluidPage(
  
      # App title
      titlePanel(strong("Population Pharmacokinetics of Levodopa Model")),
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
          fluidRow(radioButtons(
            inputId = "log_option",
            label = "Plot on log scale or not:",
            choices = c(
              "Yes" = "Yes",
              "No" = "No"
            ),
            selected = c("No")
          ),
          checkboxGroupInput(
            inputId = "variable_option",
            label = "Chose which simulation you would like to see:",
            choices = c(
              "CL Only" = "CL Only",
              "Vc Only" = "Vc Only",
              "Vp Only" = "Vp Only",
              "Q Only"  = "Q Only",
              "Varied All" = "Varied All"
            ),
            selected = c("CL Only","Vc Only","Vp Only","Q Only","Varied All")
          ),
          br(),
          h4(p("Panel 1: Violin plot of AUC for central compartment representing
               distribution of cases for popoluation variability in Clearance CL (L/min), Volume of Distribution
               of Central Compartment Vc (L), Volume of Distribution of Periphereal Compartment Vp (L), and
               Intercompartmental Clearance Q (L/min) was varied individually, and a case where these parameters
               were varied all together.")
          ), 
          br(),br(),br(),br(),
          h4(p("Panel 2: Violin plot of AUC for peripheral compartment representing
               distribution of cases for popoluation variability in Clearance CL (L/min), Volume of Distribution
               of Central Compartment Vc (L), Volume of Distribution of Periphereal Compartment Vp (L), and
               Intercompartmental Clearance Q (L/min) was varied individually, and a case where these parameters
               were varied all together.")
          )
          ),
          br(),br(),br(),br(),br(),br(),br(), br()),
        
        # Display the Plotly plot in the main panel
        mainPanel(
          width = 9,
          fluidRow(plotlyOutput(outputId = "plot_1", width = 1000)), 
          br(),  br(),  br(),br(),br(),
          fluidRow(plotlyOutput(outputId = "plot_2", width = 1000)), 
          br(),br()
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
  
      AUCc_filtered <- reactive({
        filter(AUC_central, variable %in% input$variable_option)
      })
      AUCp_filtered <- reactive({
        filter(AUC_periphl, variable %in% input$variable_option)
      })
      
  
      # Create reactive Plotly plot for app
      output$plot_1 <- renderPlotly({
        
        # Add lines and points with filtered data
        plot1 <- ggplot(data = AUCc_filtered(), aes(x = variable, y = value, fill = variable)) +
          geom_violin(trim = FALSE, scale = 'width') +
          geom_boxplot(fill = "white", width = 0.25) + my_theme + coord_flip() + theme(legend.position = "none") +
          labs(title = 'Violin Plot of AUC for Central Compartment', x = 'Parameter', y = 'AUC Value (mg*h/L)')

        if (input$log_option == 'Yes'){
        plot_out1 <- plot1 + scale_y_continuous(trans = "log10") + 
          labs(title = 'Violin Plot of AUC for Central Compartment', x = 'Parameter', y = 'Log AUC Value (mg*h/L)')  
        } else {
        plot_out1 <- plot1
        }
        # Convert ggplot to Plotly plot
        plotly_build(plot_out1)
      })
      
      # Create reactive Plotly plot for app
      output$plot_2 <- renderPlotly({
        # Add lines and points with filtered data
        plot2 <- ggplot(data = AUCp_filtered(), aes(x = variable, y = value, fill = variable)) +
          geom_violin(trim = FALSE, scale = 'width') +
          geom_boxplot(fill = "white", width = 0.25) + my_theme + coord_flip() + theme(legend.position = "none") +
          labs(title = 'Violin Plot of AUC for Peripheral Compartment', x = 'Parameter', y = 'AUC Value (mg*h/L)')

        # Add lines and points with filtered data
        if (input$log_option == 'Yes'){
          plot_out2 <- plot2 + scale_y_continuous(trans = "log10") + 
            labs(title = 'Violin Plot of AUC for Peripheral Compartment', x = 'Parameter', y = 'Log AUC Value (mg*h/L)')  
        } else {
          plot_out2 <- plot2
        }
        # Convert ggplot to Plotly plot
        plotly_build(plot_out2)
      })
  
}

# ==============================================================================
# BUILD APP

# Knit UI and Server to create app
shinyApp(ui = ui, server = server)