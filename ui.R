fluidPage(
    includeCSS("www/pipeline.css"),
    
    # Application title
    titlePanel("Pipeline"),
    
    tabsetPanel(
        type = "pills",
        
        ## Data tab ----
        tabPanel(
            title = "Data",
            
            sidebarLayout(
                
                ### Upload ----
                
                sidebarPanel(
                    width = 3,
                    h3("Upload"),
                    
                    # Radio buttons for the data source
                    radioButtons("data_source", "Data source",
                                 choices = c("DARLA", "new-fave", "sample"),
                                 selected = "DARLA",
                                 inline = TRUE,
                                 width = '100%'),
                    
                    # Upload instructions are in the server.R file. 
                    # This makes it so that there's only one `file_upload_ui` file at a time. 
                    uiOutput("file_upload_ui"),
                    hr(),
                    

                    ### Process ----    
                   
                    h3("Process"),
                    actionButton(width = "100%", "process_uploaded_button", "Process data"),
                    p("You'll know the data loaded correctly when a table appears on the right."),
                    hr(),
                    
                    ### Manage datasets ----
                    
                    h3("Manage datasets"),
                    fluidRow(
                        column(width = 6, uiOutput("loaded_datasets_list")),
                        column(
                            width = 6,
                            br(), 
                            actionButton("remove_data_button", "Remove selected", width = "100%")
                        )
                    ),
                    hr(),
                    
                    ### Download ----
                    
                    h3("Download"),
                    p("Click the button below to download this processed version of the data. It is your same data but it has been cleaned and gone through a pipeline of processing steps already."),
                    downloadButton("export_processed", "Export this processed data", width = "30%")
                ),
                
                ### Main panel ----
                mainPanel(
                    uiOutput("splash"),
                    DT::dataTableOutput("show_all_data")
                )
            )
        ),
        
        ## Main vowel plot ----
        tabPanel(
            title = "Main vowel plot",
            
            sidebarLayout(
                sidebarPanel(
                    style = "height: 90vh; overflow-y: auto;", # https://www.r-bloggers.com/2022/06/scrollbar-for-the-shiny-sidebar/
                    width = 4,
                    tabsetPanel(
                        type = "tabs",
                        
                        ### Speaker selection ----
                        tabPanel(
                            title = "Speakers",
                            selectInput("speaker_selection",
                                        label = h4("Speaker"),
                                        choices = "no speaker",
                                        multiple = TRUE,
                                        selectize = FALSE,
                                        size = 20,
                            )
                        ),
                        
                        
                        ### Processing ----
                        tabPanel(
                            title = "Processing",
                            fluidRow(
                                column(12,
                                       radioButtons("norm_method", "Normalization method",
                                                    choices = list("none" = "n",
                                                                   "Nearey" = "lm",
                                                                   "Watt & Fabricius" = "wf",
                                                                   "ΔF" = "df",
                                                                   "Lobanov" = "z"),
                                                    selected = "n",
                                                    inline = FALSE,
                                                    width = '100%')
                                )
                            )
                        ),
                        
                        
                        ### Vowel selection ----
                        tabPanel(
                            title = "Vowels",
                            selectInput("vowels",
                                        label = h4("Vowel"),
                                        choices = c("FLEECE", "KIT", "FACE", "DRESS", "TRAP", "LOT", "THOUGHT", "STRUT", "GOAT", "FOOT", "GOOSE", "PRICE", "MOUTH", "CHOICE", "NURSE"),
                                        selected = c("FLEECE", "KIT", "FACE", "DRESS", "TRAP", "LOT", "THOUGHT", "STRUT", "GOAT", "FOOT", "GOOSE"),
                                        multiple = TRUE,
                                        selectize = FALSE,
                                        size = 16
                            ),
                            
                            selectInput("environments",
                                        label = h4("Environments"),
                                        choices = c("prelateral", "prerhotic", "prevelar", "prenasal", "prevelarnasal", "prevoiceless", "post-Y", "postcoronal", "elsewhere"),
                                        selected = c("elsewhere"),
                                        multiple = TRUE,
                                        selectize = FALSE,
                                        size = 10
                            )
                            # See GSV for code on stress, normalization, and transcription
                        ),
                        
                        # Tab for words will go here eventually. (See GSV for how to do that.)
                        
                        
                        ### Plot elements ----
                        tabPanel(
                            title = "Plot",

                            fluidRow(
                                column(6,
                                       h3("Tokens"),
                                       selectInput("tokens_type",
                                                   label    = NULL,
                                                   choices  = c("None"   = "none",
                                                                "Points" = "points",
                                                                "Words"  = "words"),
                                                   selected = "points",
                                                   multiple = FALSE,
                                                   selectize = FALSE),
                                       conditionalPanel(
                                           condition = "input.tokens_type == 'points'",
                                           sliderInput("points_alpha", "Opacity",
                                                       min = 0, max = 1, value = 1, width = "100%"),
                                           sliderInput("points_size", "Size",
                                                       min = 0.01, max = 10, value = 0.25,
                                                       round = 1, width = "100%")
                                       ),
                                       conditionalPanel(
                                           condition = "input.tokens_type == 'words'",
                                           sliderInput("words_alpha", "Opacity",
                                                       min = 0, max = 1, value = 1, width = "100%"),
                                           sliderInput("words_size", "Size",
                                                       min = 0.01, max = 10, value = 3, width = "100%")
                                       )
                                ),
                                column(6,
                                       h3("Vowel Space"),
                                       checkboxInput("main_vowel_space",
                                                     label = "Hull", value = FALSE),
                                       conditionalPanel(
                                           condition = "input.main_vowel_space",
                                           sliderInput("hull_alpha", "Opacity",
                                                       min = 0, max = 1, value = 1, width = "100%"),
                                           sliderInput("hull_linewidth", "Line width",
                                                       min = 0.1, max = 3, value = 0.5,
                                                       step = 0.1, width = "100%")
                                       ),
                                       checkboxInput("main_reference_points",
                                                     label = "Reference points", value = FALSE),
                                       conditionalPanel(
                                           condition = "input.main_reference_points",
                                           sliderInput("ref_size", "Label size",
                                                       min = 2, max = 20, value = 10, width = "100%"),
                                           sliderInput("ref_alpha", "Opacity",
                                                       min = 0, max = 1, value = 1, width = "100%")
                                       )
                                )
                            ),

                            hr(),

                            fluidRow(
                                column(6,
                                       h3("Centers"),
                                              selectInput("centers_type",
                                                          label    = NULL,
                                                          choices  = c("None"    = "none",
                                                                       "Means"   = "means",
                                                                       "Medians" = "medians"),
                                                          selected = "means",
                                                          multiple = FALSE,
                                                          selectize = FALSE),
                                              conditionalPanel(
                                                  condition = "input.centers_type != 'none'",
                                                  selectInput("label_variable",
                                                              label    = "One label per...",
                                                              choices  = c("phoneme", "allophone"),
                                                              selected = "allophone",
                                                              multiple = FALSE, selectize = TRUE),
                                                  sliderInput(inputId = "means_alpha",
                                                              label = "Opacity",
                                                              min = 0, max = 1, value = 1,
                                                              width = "100%"),
                                                  sliderInput(inputId = "means_size",
                                                              label = "Size",
                                                              min = 2, max = 20, value = 10,
                                                              width = "100%"),
                                                  conditionalPanel(
                                                      condition = "input.centers_type == 'means'",
                                                      checkboxInput(inputId = "show_ci",
                                                                    label   = "95% CI crosshairs",
                                                                    value   = FALSE),
                                                      conditionalPanel(
                                                          condition = "input.show_ci",
                                                          sliderInput(inputId = "ci_alpha",
                                                                      label = "CI opacity",
                                                                      min = 0, max = 1, value = 0.5,
                                                                      width = "100%")
                                                      )
                                                  )
                                              )
                                       ),
                                       column(6,
                                              h3("Distribution"),
                                              selectInput("distribution_type",
                                                          label    = NULL,
                                                          choices  = c("None"         = "none",
                                                                       "Ellipses"     = "ellipses",
                                                                       "KDE contours" = "kde"),
                                                          selected = "ellipses",
                                                          multiple = FALSE,
                                                          selectize = FALSE),
                                              # Grouping selector — label updated server-side
                                              # based on distribution_type
                                              conditionalPanel(
                                                  condition = "input.distribution_type != 'none'",
                                                  selectInput("ellipse_variable",
                                                              label    = "One ellipse per...",
                                                              choices  = c("phoneme", "allophone"),
                                                              selected = "allophone",
                                                              multiple = FALSE, selectize = TRUE)
                                              ),
                                              conditionalPanel(
                                                  condition = "input.distribution_type == 'ellipses'",
                                                  sliderInput(inputId = "ellipses_alpha",
                                                              label = "Opacity",
                                                              min = 0, max = 1, value = 1,
                                                              width = "100%"),
                                                  sliderInput(inputId = "ellipses_size",
                                                              label = "Size",
                                                              min = 1, max = 100, value = 67,
                                                              post = "%", width = "100%")
                                              ),
                                              conditionalPanel(
                                                  condition = "input.distribution_type == 'kde'",
                                                  sliderInput(inputId = "kde_alpha",
                                                              label = "Opacity",
                                                              min = 0, max = 1, value = 0.8,
                                                              width = "100%"),
                                                  sliderInput(inputId = "kde_bins",
                                                              label = "Contour lines",
                                                              min = 2, max = 15, value = 5,
                                                              step = 1, width = "100%")
                                              )
                                       )
                            ),

                        ),
                        
                        ### Aesthetics ----
                        tabPanel(
                            title = "Aesthetics",

                            h4("Labels"),
                            fluidRow(
                                column(6, textInput("title",    label = "Title",    value = "")),
                                column(6, textInput("subtitle", label = "Subtitle", value = ""))
                            ),
                            fluidRow(
                                column(6, textInput("x_label", label = "x-axis", value = "F2")),
                                column(6, textInput("y_label", label = "y-axis", value = "F1"))
                            ),

                            hr(),
                            h4("Typography"),
                            fluidRow(
                                column(6,
                                       sliderInput("base_size", label = "Base font size",
                                                   min = 0, max = 48, value = 16,
                                                   step = 1, round = TRUE, width = "100%")
                                ),
                                column(6,
                                       selectInput("base_family", label = "Font family",
                                                   choices  = c("Avenir", "Courier", "Helvetica",
                                                                "Palatino", "Times"),
                                                   selected = "Avenir",
                                                   multiple = FALSE, selectize = TRUE)
                                )
                            ),

                            hr(),
                            h4("Color"),
                            fluidRow(
                                column(6,
                                       selectInput("color_variable", label = "One color per...",
                                                   choices  = c("phoneme", "allophone"),
                                                   selected = "phoneme",
                                                   multiple = FALSE, selectize = TRUE)
                                ),
                                column(6,
                                       selectInput("color_palette", label = "Palette",
                                                   choices  = c("Paul Tol" = "tol",
                                                                "Kelly"    = "kelly",
                                                                "Glasbey"  = "glasbey",
                                                                "Alphabet" = "alphabet"),
                                                   selected = "kelly",
                                                   multiple = FALSE, selectize = TRUE)
                                )
                            ),
                            checkboxInput("show_legend", label = "Show legend", value = FALSE),

                            hr(),
                            h4("Theme"),
                            selectInput("plot_theme", label = NULL,
                                        choices  = c("Minimal"       = "minimal",
                                                     "Classic"       = "classic",
                                                     "Black & white" = "bw",
                                                     "Void"          = "void"),
                                        selected = "minimal",
                                        multiple = FALSE, selectize = FALSE),

                            hr(),
                            h4("Display size"),
                            fluidRow(
                                column(4, numericInput("plot_width_in",  label = "Width (in)",
                                                       value = 10, min = 1, max = 20, step = 0.5)),
                                column(4, numericInput("plot_height_in", label = "Height (in)",
                                                       value = 7,  min = 1, max = 20, step = 0.5)),
                                column(4, numericInput("plot_dpi",       label = "DPI",
                                                       value = 150, min = 72, max = 300, step = 1))
                            )
                        ),
                        
                        ### Download plot ----
                        tabPanel(
                            title = "Download",
                            fluidRow(
                                column(6,
                                       numericInput("fig_height",
                                                    label = h4("Height (inches)"),
                                                    value = 7,
                                                    step = 0.1),
                                       numericInput("fig_width",
                                                    label = h4("Width (inches)"),
                                                    value = 7,
                                                    step = 0.1),
                                       numericInput("fig_dpi",
                                                    label = h4("DPI"),
                                                    value = 300,
                                                    step = 50)
                                ),
                                column(6,
                                       textInput("fig_filename",
                                                 label = h4("File name"),
                                                 value = "vowel_plot"),
                                       selectInput("fig_filetype",
                                                   label = h4("File type"),
                                                   choices = c("JPG", "PNG", "PDF"),
                                                   selected = "JPG",
                                                   width = "100%")
                                )
                            ),
                            hr(),
                            downloadButton("fig_download", "Download")
                        )
                    ) # end sidebarLayout
                    
                    ### The main plot itself ----
                ),
                mainPanel(
                    width = 8,
                    
                    shinycssloaders::withSpinner(
                        imageOutput("midpoints_plot", width = "auto", height = "auto"),
                        color = PIPE_BROWN,
                        type  = 6
                    )
                )
            )
        ),
        
        # TODO (possibly) : A dedicated trajectory tab

        ## Acoustic Analysis ----
        tabPanel(
            title = "Acoustic analysis",
            tabsetPanel(
                
                ### Vowel overlap ----
                tabPanel(
                    title = "vowel overlap",
                    sidebarLayout(
                        sidebarPanel(
                            width = 3,
                            
                            selectInput("vowel_pair",
                                        label    = h4("Vowel pair"),
                                        choices  = lapply(vowel_pair_groups, names),
                                        selected = "feel-fill",
                                        multiple = FALSE,
                                        selectize = TRUE),
                            
                            uiOutput("pillai_validation_message"),
                            
                            # TODO: Add an explanation of what the selected vowel pair means?
                            
                            tableOutput("pillai_pairs_summary"),
                            
                            hr(),
                            h4("Plot options"),
                            checkboxInput("pillai_reference_points", label = "Show reference points", value = 1),
                            checkboxInput("pillai_vowel_space",      label = "Show vowel space", value = 1)
                        ),
                        mainPanel(
                            fluidRow(
                                column(3,
                                       p("Total tokens", class = "pillai-label"),
                                       div(class = "pillai-stat", textOutput("pillai_total_n")),
                                       p("Number of tokens used to calculate the Pillai score.", class = "pillai-label")),
                                column(3,
                                       p("Threshold", class = "pillai-label"),
                                       div(class = "pillai-stat", textOutput("pillai_threshold")),
                                       p("A Pillai score below this value suggests an underlying merger.", class = "pillai-label")),
                                column(3,
                                       p("Pillai score", class = "pillai-label"),
                                       div(class = "pillai-stat", textOutput("pillai_score")),
                                       p("0 = complete overlap; ", br(), "1 = complete separation.", class = "pillai-label")),
                                column(3,
                                       p("p-value", class = "pillai-label"),
                                       div(class = "pillai-stat", textOutput("pillai_p")),
                                       p("Values below 0.05 indicate a statistically significant difference between vowel classes.", class = "pillai-label"))
                            ),
                            
                            shinycssloaders::withSpinner(
                                plotOutput("vowel_pair_plot", width = "100%", height = "600px"),
                                color = PIPE_BROWN,
                                type  = 6           # spinner style, 1-8
                            )
                        )
                    )
                )
                # tabPanel("vowel shifts")
            )
        )
        
        
    )
)