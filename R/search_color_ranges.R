# Find pixels in an image that fall inside of a color range

# rectangularRange: find pixels within a target range defined by boundaries in
# each channel

#' Find pixels within a target color range defined by boundaries in each channel
#'
#' Searches for pixels within a set of upper and lower limits for each color
#' channel. Essentially draws a 'box' around a region of color space in which to
#' search for pixels.
#'
#' @param pixel.array An image represented as a 3D array (as read in by
#'   \code{\link[jpeg]{readJPEG}}, \code{\link[png]{readPNG}}, or
#'   \code{\link[colordistance]{loadImage}}) in which to change pixel colors.
#'
#' @param upper,lower RGB triplet specifying the bounds of color space search.
#'   See details.
#'
#' @param target.color Color with which to replace specified pixels. Can be
#'   either an RGB triplet or one of the colors listed by
#'   \code{\link[grDevices]{colors}}.
#'
#' @param main Optional title to display for image.
#'
#' @param plotting Logical. Should output be plotted in the plot window?
#'
#' @param color.pixels Logical. Should a diagnostic image with pixels changed to
#'   \code{target.color} be returned?
#'
#' @return A list with the following elements:
#' \itemize{
#'   \item \code{pixel.idx}: Coordinates of pixels within color range.
#'   \item \code{img.fraction}: Proportion of the image within color range.
#'   \item \code{original.img}: The original RGB array.
#'   \item \code{indicator.img}: If \code{color.pixels = TRUE}, RGB array with
#'   color-swapped pixels.
#' }
#'
#' @examples
#' flowers <- jpeg::readJPEG(system.file("extdata", "flowers.jpg", package =
#' "countcolors"))
#'
#' # Define upper and lower bounds for white
#' lower <- rep(0.8, 3)
#' upper <- rep(1, 3)
#'
#' white.flowers <- countcolors::rectangularRange(flowers, rep(1, 3), rep(0.85,
#' 3), target.color = "turquoise")
#'
#' @details
#' \code{lower} and \code{upper} should be vectors of length 3 in a 0-1 range,
#' in the order R-G-B. For example, the upper bounds for white would be c(1, 1,
#' 1), and the lower bounds might be c(0.8, 0.8, 0.8). This would search for all
#' pixels where the red value, blue value, AND green value are all between 0.8
#' and 1.
#'
#' @export
rectangularRange <- function(pixel.array, upper, lower,
                             target.color = "green", main = "",
                             color.pixels = TRUE, plotting = TRUE) {

  # Find all pixels within target range + get their locations
  idx <- which( (lower[1] <= pixel.array[, , 1] &
                  pixel.array[, , 1] <= upper[1]) &
                 (lower[2] <= pixel.array[, , 2] &
                    pixel.array[, , 2] <= upper[2]) &
                 (lower[3] <= pixel.array[, , 3] &
                    pixel.array[, , 3] <= upper[3]),
               arr.ind = TRUE)

  # Create list to return, including index of pixels within range, number of
  # pixels in range, fraction of image in range, and original image
  return.list <- list(pixel.idx = idx, pixel.count = nrow(idx),
                      img.fraction =
                        nrow(idx) / (nrow(pixel.array) * ncol(pixel.array)),
                      original.img = pixel.array)

  # If color.pixels is TRUE, create a version of the image with the pixels
  # changed to a diagnostic color and add indicator image onto returned list
  if (color.pixels | plotting) {
    indicator.img <-
      countcolors::changePixelColor(pixel.array = pixel.array,
                                      pixel.idx = idx,
                                      target.color = target.color,
                                      plotting = FALSE, return.img = TRUE)
    return.list$indicator.img <- indicator.img

    # If plotting = TRUE, plot indicator.img in the plot window
    if (plotting) {
      countcolors::plotArrayAsImage(indicator.img, main = main)
    }

  }

  return(return.list)

}



#' Find pixels within a target color range defined by a center and search radius
#'
#' Searches for pixels within a radius of a single color. Draws a sphere around
#' a region of color space in which to search for pixels.
#'
#' @param pixel.array An image represented as a 3D array (as read in by
#'   \code{\link[jpeg]{readJPEG}}, \code{\link[png]{readPNG}}, or
#'   \code{\link[colordistance]{loadImage}}) in which to change pixel colors.
#'
#' @param center A single color (RGB triplet) around which to search. RGB range
#'   0-1 (not 0-255).
#'
#' @param radius A value between 0 and 1 specifying the size of the area around
#'   \code{center} to search.
#'
#' @param target.color Color with which to replace specified pixels. Can be
#'   either a an RGB triplet or one of the colors listed by
#'   \code{\link[grDevices]{colors}}.
#'
#' @param main Optional title to display for image.
#'
#' @param plotting Logical. Should output be plotted in the plot window?
#'
#' @param color.pixels Logical. Should a diagnostic image with pixels changed to
#'   \code{target.color} be returned?
#'
#' @return A list with the following elements:
#' \itemize{
#'   \item \code{pixel.idx}: Coordinates of pixels within color range.
#'   \item \code{img.fraction}: Proportion of the image within color range.
#'   \item \code{original.img}: The original RGB array.
#'   \item \code{indicator.img}: If \code{color.pixels = TRUE}, RGB array with
#'   color-swapped pixels.
#' }
#'
#' @examples
#' # Target color: change all of the red flowers to turquoise
#' flowers <- jpeg::readJPEG(system.file("extdata", "flowers.jpg", package =
#' "countcolors"))
#'
#' # Red:
#' center <- c(255, 75, 75) / 255
#'
#' # Setting the radius too low:
#' red.flowers <- countcolors::sphericalRange(flowers, center = center, radius =
#' 0.05, target.color = "turquoise")
#'
#' # Setting the radius too high:
#' red.flowers <- countcolors::sphericalRange(flowers, center = center, radius =
#' 0.4, target.color = "turquoise")
#'
#' # Setting the radius just right:
#' red.flowers <- countcolors::sphericalRange(flowers, center = center, radius =
#' 0.2, target.color = "turquoise")
#'
#' @details
#' \code{lower} and \code{upper} should be vectors of length 3 in a 0-1 range,
#' in the order R-G-B. For example, the upper bounds for white would be c(1, 1,
#' 1), and the lower bounds might be c(0.8, 0.8, 0.8). This would search for all
#' pixels where the red value, blue value, AND green value are all between 0.8
#' and 1.
#'
#' @export
sphericalRange <- function(pixel.array, center, radius,
                           target.color = "green", main = "",
                           color.pixels = TRUE, plotting = TRUE) {

  # Assuming RGB, change radius percent to fraction of maximum distance in RGB
  # space
  radius <- radius * sqrt(sum( (rep(0, 3) - rep(1, 3)) ^ 2))

  pixel.distances <- matrix(NA, nrow = dim(pixel.array)[1],
                            ncol = dim(pixel.array)[2])

  # For every pixel, calculate distance from center
  for (i in 1:dim(pixel.array)[1]) {
    for (j in 1:dim(pixel.array)[2]) {
      pixel.distances[i, j] <- sqrt(sum( (pixel.array[i, j, ] - center) ^ 2))
    }
  }

  # Index every pixel with distance <= radius
  idx <- which(pixel.distances <= radius, arr.ind = TRUE)

  # Provide warning if no pixels were indexed at all
  if (nrow(idx) == 0) {
    warning("No pixels within color range in provided image")
  }

  # Create list to return, including index of pixels within range, number of
  # pixels in range, fraction of image in range, and original image
  return.list <- list(pixel.idx = idx,
                      pixel.count = nrow(idx),
                      img.fraction = nrow(idx) /
                        (nrow(pixel.array) * ncol(pixel.array)),
                      original.img = pixel.array)

  # If color.pixels is TRUE, create a version of the image with the pixels
  # changed to a diagnostic color and add indicator image onto returned list
  if (color.pixels | plotting) {
    indicator.img <-
      countcolors::changePixelColor(pixel.array = pixel.array,
                                      pixel.idx = idx,
                                      target.color = target.color,
                                      plotting = FALSE, return.img = TRUE)
    return.list$indicator.img <- indicator.img

    # If plotting = TRUE, plot indicator.img in the plot window
    if (plotting) {
      countcolors::plotArrayAsImage(indicator.img)
    }

  }

  return(return.list)

}
