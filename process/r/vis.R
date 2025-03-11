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

plot_data <- function(data_dict, use_scatter = FALSE, output_dir = tempdir()) {

  plot_df <- data.frame(
    obs = data_dict$obs,
    fcst = data_dict$fcst,
    index = 1:length(data_dict$obs)
  )
  
  if (use_scatter) {
    # Scatter plot version
    p <- ggplot(plot_df, aes(x = obs, y = fcst)) +
      geom_point(color = "blue", alpha = 0.6) +
      labs(x = "Observed", y = "Forecast", title = "Observed vs Forecast") +
      theme_minimal()
  } else {
    p <- ggplot(plot_df) +
      geom_line(
        aes(x = index, y = obs, color = "Observed"), 
        linewidth = 1.5,              # Thicker line
        lineend = "round"        # Rounded line ends
      ) +
      geom_line(
        aes(x = index, y = fcst, color = "Forecast"), 
        linewidth = 1.5,              # Thicker line
        lineend = "round"        # Rounded line ends
      ) +
      labs(x = "Index", y = "Value", title = "Observed and Forecast",
           color = "Data Type") +
      scale_color_manual(values = c("Observed" = "blue", "Forecast" = "red")) +
      theme_minimal()
  }
  
  p <- p +
    theme(
      panel.background = element_rect(fill = "white", colour = "white"),
      plot.background = element_rect(fill = "white", colour = "white"),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 1)
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