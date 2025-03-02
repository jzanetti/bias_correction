
#' Generate synthetic data following normal distributions for observation and forecast.
#'
#' @param data_size Integer number of data points to generate for each data type. Defaults to 1000.
#' @param normal_cfg Named list containing mean and standard deviation for each data type.
#'   Expected structure: list("obs" = list("mean" = float, "std" = float),
#'                           "fcst" = list("mean" = float, "std" = float)).
#'   Defaults to observation mean=100.0, std=5.0 and forecast mean=105.0, std=6.3.
#' @param create_plot Logical indicating whether to create plots for the data using ggplot2. Defaults to FALSE.
#'
#' @return A named list containing vectors of generated data with names "obs" and "fcst",
#'   where each vector has length equal to data_size.
#' 
#' @note Requires ggplot2 package for plotting functionality when create_plot = TRUE
#' 
makeup_data <- function(
    data_size = 1000,
    normal_cfg = list(
      "obs" = list("mean" = 100.0, "std" = 5.0),
      "fcst" = list("mean" = 105.0, "std" = 6.3)
    ),
    create_plot = FALSE
) {
  # Initialize output list
  output <- list()
  
  # Generate normal random data for each type
  for (data_type in c("obs", "fcst")) {
    output[[data_type]] <- rnorm(
      n = data_size,
      mean = normal_cfg[[data_type]][["mean"]],
      sd = normal_cfg[[data_type]][["std"]]
    )
  }
  
  # Create plots if requested using ggplot2
  if (create_plot) {
    # Create a data frame for ggplot
    plot_data <- data.frame(
      Index = rep(1:data_size, 2),
      Value = c(output[["obs"]], output[["fcst"]]),
      Type = rep(c("obs", "fcst"), each = data_size)
    )
    
    # Create the plot
    p <- ggplot(plot_data, aes(x = Index, y = Value, color = Type)) +
      geom_line() +
      labs(
        title = "Observation and Forecast Data",
        x = "Index",
        y = "Value"
      ) +
      scale_color_manual(values = c("obs" = "blue", "fcst" = "red")) +
      theme_minimal()
    
    ggsave(file.path(TMP_DIR, "data_plot.png"), plot = p)
  }
  
  return(output)
}