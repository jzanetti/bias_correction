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

plot_data <- function(
    data_dict, 
    use_scatter = TRUE, 
    output_dir = tempdir(), 
    x_name = "obs", 
    y_names = c("fcst"), 
    title = "Data comparison", 
    filename = "data_comparison.png"
) {
  # Convert data_dict to data frame
  plot_df <- as.data.frame(data_dict)
  
  # Add index for line plots
  if (!use_scatter) {
    plot_df$index <- 1:nrow(plot_df)
  }
  
  # Initialize ggplot
  p <- ggplot(plot_df)
  
  if (use_scatter) {
    # Reshape to long format for scatter plot
    plot_df_long <- pivot_longer(plot_df, cols = all_of(y_names), names_to = "variable", values_to = "value")
    
    # Calculate the overall min and max across x and y values
    x_values <- plot_df[[x_name]]
    y_values <- plot_df_long$value
    overall_range <- range(c(x_values, y_values), na.rm = TRUE)  #
    
    p <- p + geom_point(data = plot_df_long, 
                        aes(x = .data[[x_name]], y = value, color = variable), 
                        alpha = 0.6) +
      geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
      labs(x = x_name, y = "Value", title = title, color = "Data Type") +
      scale_color_manual(values = rainbow(length(y_names))) +
      xlim(overall_range) +  # Set x-axis limits to the overall range
      ylim(overall_range)    # Set y-axis limits to the overall range
  } else {
    plot_df_long <- pivot_longer(plot_df, cols = c(x_name, y_names), 
                                 names_to = "variable", values_to = "value")
    p <- p + geom_line(data = plot_df_long, 
                       aes(x = index, y = value, color = variable), 
                       linewidth = 1.5, lineend = "round") +
      labs(x = "Index", y = "Value", title = title, color = "Data Type") +
      scale_color_manual(values = rainbow(length(y_names) + 1))
  }
  
  # Apply theme
  p <- p + 
    theme_minimal() +
    theme(
      panel.background = element_rect(fill = "white", colour = "white"),
      plot.background = element_rect(fill = "white", colour = "white"),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 1)
    )
  
  # Create output directory
  if (!dir.exists(output_dir) && nchar(output_dir) > 0) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Save plot
  output_path <- file.path(output_dir, filename)
  ggsave(output_path, plot = p, width = 8, height = 6, dpi = 300, bg = "white")
  cat(sprintf("The data figure is saved in %s\n", output_path))
  
  return(p)
}