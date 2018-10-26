# Functions for visualizing pixel count output

#' Plot a 3D array as an RGB image
#'
#' Plots a 3D array as an RGB image in the plot window.
#'
#' @param rgb.array 3D RGB array with R, G, and B channels (pixel rows x pixel
#'   columns x color channels) to be plotted in the plot window as an actual
#'   image.
#'
#' @param main Optional title to display for image.
#'
#' @examples
#' # Read in image
#' flowers <- jpeg::readJPEG(system.file("extdata", "flowers.jpg", package =
#' "countcolors"))
#'
#' # Plot
#' plotArrayAsImage(flowers, main = "flowers!")
#'
#' @export
plotArrayAsImage <- function(rgb.array, main = "") {

    # Make sure the array is 3-dimensional

    # If there are more than 3 channels/slices in the 3rd dimension (i.e. an
    # alpha channel as 4th), only use the first 3
    if (length(dim(rgb.array)) != 3) {
        stop("RGB_array must be an array of three dimensions (pixel rows,
             pixel columns, and color channels)")
    } else if (dim(rgb.array)[3] != 3) {
      warning("Provided array has more than 3 channels; using only the
                first 3 as R, G, and B channels")
    }

    # Change graphical parameters for image display
    op <- graphics::par(mar = c(0, 0, 2, 0))
    asp <- dim(rgb.array)[1] / dim(rgb.array)[2]

    # Initialize empty plot window
    graphics::plot(0:1, 0:1, type = "n", ann = F, axes = F, asp = asp)

    # Use rasterImage to actually plot the image
    graphics::rasterImage(rgb.array, 0, 0, 1, 1)
    graphics::title(main, line = 0)

    # Return to original graph window settings
    graphics::par(op)
}



#' Change all specified pixels to a new color
#'
#' Changes pixels in an image to a different color and displays and/or returns
#' the re-colored image.
#'
#' @param pixel.array An image represented as a 3D array (as read in by
#'   \code{\link[jpeg]{readJPEG}}, \code{\link[png]{readPNG}}, or
#'   \code{\link[colordistance]{loadImage}}) in which to change pixel colors.
#'
#' @param pixel.idx An n x 2 matrix of index coordinates specifying which pixels
#'   to change, where rows are pixels and columns are X and Y coordinates in the
#'   image.
#'
#' @param target.color Color with which to replace specified pixels. Can be
#'   either a an RGB triplet or one of the colors listed by
#'   \code{\link[grDevices]{colors}}.
#'
#' @param return.img Logical. Should RGB array with swapped colors be returned?
#'
#' @param plotting Logical. Should output be plotted in the plot window?
#'
#' @param main Optional title to display for image.
#'
#' @return Raster array with indicated pixels changed to target color, if
#'   \code{return.img = TRUE}.
#'
#' @examples
#' # Change a rectangle in the center to black
#' flowers <- jpeg::readJPEG(system.file("extdata", "flowers.jpg", package =
#' "countcolors"))
#'
#' sinister.object <- expand.grid(c(114:314), c(170:470))
#'
#' countcolors::changePixelColor(flowers, sinister.object, target.color = "black")
#'
#'\dontrun{
#' # Change all the white flowers to magenta
#' indicator.img <- countcolors::sphericalRange(flowers, center = c(1, 1, 1),
#' radius = 0.1, color.pixels = TRUE, plotting = FALSE)
#'
#' countcolors::changePixelColor(flowers, indicator.img$pixel.idx,
#' target.color="magenta")
#' }
#' @export
changePixelColor <- function(pixel.array, pixel.idx, target.color = "green",
                             return.img = FALSE, plotting = TRUE, main = "") {

    # Make sure target color is or can be coerced to an RGB triplet
    if (is.character(target.color)) {
        target.color <- as.vector(grDevices::col2rgb(target.color) / 255)
    }

    # Check that vector is of appropriate length and has a 0-1 (not 0-255) range
    if (length(target.color) != 3) {
        stop("'target.color' must be a numeric vector of length 3 with
             values between 0 and 1 or one of the colors listed by colors()")
    } else if (range(target.color)[2] > 1) {
        target.color <- target.color / 255
    }

    # Change specified pixels to target color
    for (i in 1:nrow(pixel.idx)) {
        pixel.array[pixel.idx[i, 1], pixel.idx[i, 2], ] <- target.color
    }

    # Plot if plotting = TRUE
    if (plotting) {
        countcolors::plotArrayAsImage(pixel.array, main = main)
    }

    # Return image with changed pixel colors if return.img = TRUE
    if (return.img) {
        return(pixel.array)
    }

}
