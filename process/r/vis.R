#' Generate and save plots for observed and forecast data.
#'
#' This function creates visualization plots for both observed ('obs') and
#' forecast ('fcst') data from the input list and saves them to the
#' specified output directory using ggplot2.
#'
#' @param data_dict A named list containing data to plot with elements 'obs' and
#'   'fcst' representing observed and forecast data respectively.
#' @param output_dir Character string specifying the directory path where
#'   plots will be saved. Defaults to tempdir().
#' @return Nothing is returned; the function saves plot files to disk and
#'   prints their locations.
#' @note Requires ggplot2 and dplyr packages.
#' 
#' @export
#' 

plot_data <- function(data_dict, output_dir = tempdir()) {

  plot_data <- data.frame(
    value = c(data_dict$obs, data_dict$fcst),
    type = rep(c("obs", "fcst"), 
    times = c(length(data_dict$obs), length(data_dict$fcst)))
  )
 
  ggplot(plot_data, aes(x = 1:nrow(plot_data)/2, y = value, color = type)) +
    geom_line() +  # Use geom_line for lines, or geom_point for points
    labs(x = "Index", y = "Value", title = "Column1 vs Column2") +
    theme_minimal()
  
  # Create the plot
  p <- ggplot(plot_data, aes(x = rep(1:length(data_dict$obs), times=2), y = value, color = type)) +
    geom_line() +
    labs(
      title = "Obs and Fcst",
      x = "Index",
      y = "Value",
      color = "Data Type"
    ) +
    theme_minimal() +
    theme(
      panel.background = element_rect(fill = "white", colour = "white"),
      plot.background = element_rect(fill = "white", colour = "white")
    )

  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir) && nchar(output_dir) > 0) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Define output path
  output_path <- file.path(output_dir, "bc_data.png")
  
  # Save the plot
  ggsave(output_path, plot = p, width = 8, height = 6, dpi = 300)
  
  # Print confirmation
  cat(sprintf("The makeup data figure is saved in %s\n", output_path))
}