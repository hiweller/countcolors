#' Count the number of pixels within a color range or ranges
#'
#' Counts the pixels within a color range; ranges can be spherical (see
#' \code{\link{sphericalRange}}) or rectangular
#' (\code{\link{rectangularRange}}). If multiple ranges are specified, each one
#' is colored using a different indicator color.
#'
#' @param path Path to the image (JPEG or PNG).
#'
#' @param color.range Type of range being specified. Must be either "spherical"
#'   or "rectangular".
#'
#' @param center A vector or n x 3 matrix of color centers (RGB triplets) around
#'   which to search using spherical color range. RGB range 0-1 (not 0-255). See
#'   details.
#'
#' @param radius Values between 0 and 1 specifying the size of the area around
#'   \code{center} to search. The same number of centers and radii must be
#'   specified.
#'
#' @param lower,upper  RGB triplet(s) specifying the bounds of color space
#'   to search. Must be the same length. See details.
#'
#' @param bg.lower,bg.upper RGB triplets specifying the bounds of color space to
#'   ignore as background, or \code{NULL} to use the entire image.
#'
#' @param target.color If an indicator image is created, the color with which to
#'   replace specified pixels. Can be either an RGB triplet or one of the
#'   colors listed by \code{\link[grDevices]{colors}}.
#'
#' @param plotting Logical. Should output be plotted in the plot window?
#'
#' @param save.indicator Logical. If TRUE,
#'   saves image to the same directory as the original image as
#'   'originalimagename_masked.png'; if a path is provided, saves it to that
#'   directory/name instead, also as a PNG.
#'
#' @param dpi Resolution (dots per image) for saving indicator image.
#'
#' @param return.indicator Logical. Should an indicator image (RGB array with
#'   targeted pixels changed to indicator color) be returned?
#'
#' @return A list with the following attributes:
#' \itemize{
#'   \item \code{pixel.idx}: Unique coordinates of pixels within color range(s).
#'   \item \code{pixel.fraction}: Proportion of the non-background image within
#'   color range(s), found by dividing the number of pixels in \code{pixel.idx}
#'   by the number of non-background pixels in the image.
#'   \item \code{indicator.img}: If \code{return.indicator = TRUE}, RGB array with
#'   color-swapped pixels.
#' }
#'
#' @seealso \code{\link{countColorsInDirectory}}
#'
#' @examples
#'
#' # Try out a few different radii for white pelicans
#' pelicans <- system.file("extdata", "pelicans.jpg", package = "countcolors")
#'
#' white.ctr <- rep(0.9, 9)
#' white.radii <- c(0.5, 0.3, 0.1)
#'
#' # Magenta = 50% threshold, cyan = 30% threshold, yellow = 10% threshold
#' pelican.example <- countcolors::countColors(pelicans, center = white.ctr,
#' radius = white.radii, bg.lower = NULL, plotting = TRUE)
#'
#' @details More than one set of ranges can be specified for the color search
#'   space, but the same number of arguments must be provided in each case (so
#'   the number of pixels and centers must be the same if using a spherical
#'   range, and the number of upper and lower bounds must be the same if using a
#'   rectangular one).
#'
#' For \code{center}, \code{upper}, and \code{lower}, which call for RGB
#' triplets, provide either a vector of RGB triplets in RGB order, i.e. c(R1,
#' G1, B1, R2, G2, B2, etc) or a 3-column matrix with one row per RGB triplet.
#' If a vector is provided, it is coerced to a 3-column matrix, and must
#' therefore be a multiple of 3.
#'
#'
#' @export
countColors <- function(path, color.range = "spherical",
                       center, radius, lower, upper,
                       bg.lower = rep(0.8, 3), bg.upper = rep(1, 3),
                       target.color = c("magenta", "cyan", "yellow"),
                       plotting = FALSE, save.indicator = FALSE, dpi=72,
                       return.indicator = FALSE) {

  # Takes a path to an image and loads it
  img <- colordistance::loadImage(path, lower = bg.lower, upper = bg.upper)
  original <- img$original.rgb

  # If saving is on but no path was specified, set it to same directory as
  # original image
  if (isTRUE(save.indicator)) {
    destination <- paste(tools::file_path_sans_ext(path),
                         "_masked.png", sep = "")
  } else if (is.character(save.indicator)) {
    # If save.indicator is a filepath, save as a png and set save.indicator to a
    # logical value
    if (dir.exists(save.indicator)) {
      destination <- paste(save.indicator, tools::file_path_sans_ext(path),
                           ".png", sep = "")
    } else {
      destination <- paste(tools::file_path_sans_ext(save.indicator),
                           ".png", sep = "")
    }
    save.indicator <- TRUE
  }

  # If any output that requires colored indicator image is flagged, set
  # get.indicator to TRUE
  if (plotting | return.indicator | save.indicator) {
    get.indicator <- TRUE

    # Convert target.color to hex codes for indicator image
    # If target.color is color names, convert to RGB matrix
    if (is.character(target.color)) {
      # convert color names to RGB triplets
      target.color <- t(grDevices::col2rgb(target.color)) / 255
      # If vector or matrix, convert to/check for 3-column matrix
    } else if (is.numeric(target.color)) {
      # If a vector, convert to a matrix
      if (is.vector(target.color)) {
        if (length(target.color) %% 3 == 0) {
          target.color <- matrix(target.color, ncol = 3, byrow = TRUE)
        } else {
          stop(paste("Target.color must be a vector of color names",
                     "a vector of RGB triplets (multiple of 3)",
                     "or a matrix with target.colors as rows",
                     sep = ", "))
          # If already a matrix, check that it has 3 columns
        }
      } else if (is.matrix(target.color)) {
        if (ncol(target.color) != 3) {
          stop("target.colors matrix must have 3 columns, 1 per channel")
        }
      }
    }

    # Convert to hex colors
    target.color <- apply(target.color, 1,
                    function(i) grDevices::rgb(i[1], i[2], i[3]))
  } else {
    get.indicator <- FALSE
  }

  # If range = "spherical", check that center and radius are specified and are
  # coercible to appropriate formats
  if (tolower(color.range) == "spherical") {

    # Check that center and radius were specified and are of appropriate types
    if (!exists("center") | !exists("radius")) {
      stop("Center and radius must be specified for a spherical color range")
    }

    # Make sure that center is of appropriate format (divisible by 3/matrix with
    # 3 columns)
    if (is.vector(center)) {
      if (length(center) %% 3 == 0) {
        center <- matrix(center, ncol = 3, byrow = TRUE)
      } else {
        stop("Center must be a vector with length a multiple of 3 or a matrix
             of centers")
      }
    } else if (is.matrix(center)) {
      if (ncol(center) != 3) {
        stop("Centers matrix must have 3 columns, 1 per channel")
      }
    }

    # And make sure everything is in the 0-1 range; if not, assume 0-255 and
    # divide by 255
    if (range(center)[2] > 1) {
      center <- center / 255
    }

    # Make sure that an appropriate number of radii were provided
    if (nrow(center) != length(radius)) {
      stop("Number of centers and radii differ")
    }

    # If everything checks out, print the centers/radii being screened
    message("Using spherical range(s):")
    for (i in 1:nrow(center)) {
      message(paste("Center: ", paste(center[i, ], collapse = ", "),
                    " +/- ", radius[i] * 100, "%", sep = ""))
    }

    # Make sure there are enough colors to use for color indexing; if not, just
    # repeat color vector
    if (length(target.color) < nrow(center)) {
      target.color <- rep(target.color, round(nrow(center) /
                                                length(target.color)) + 1)
    }

    # Get range using first color
    filtered.img <- sphericalRange(pixel.array = original, center = center[1, ],
                                   radius = radius[1], plotting = FALSE,
                                   color.pixels = get.indicator,
                                   target.color = target.color[1])
    idx <- filtered.img$pixel.idx

    # Keep the indicator image (color inside pixel range changed to indicator
    # color) and pixel indices for later display
    if (get.indicator) {
      indicator.img <- filtered.img$indicator.img
    }


    # If more than one center/radius pair were specified, screen for each color
    # in turn, but do the color indexing on the same image so we can see
    # everything that is being counted
    if (nrow(center) > 1) {
      for (i in 2:nrow(center)) {
        filtered.img <- sphericalRange(pixel.array = original,
                                       center = center[i, ], radius = radius[i],
                                       plotting = FALSE, color.pixels = FALSE)
        if (get.indicator) {
          indicator.img <- changePixelColor(indicator.img,
                                            filtered.img$pixel.idx,
                                            target.color = target.color[i],
                                            return.img = TRUE, plotting = FALSE)
        }
        idx <- rbind(idx, filtered.img$pixel.idx)
      }
    }

  } else if (tolower(color.range) == "rectangular") {
    # If range is set to rectangular, perform similar checks

    # Check that lower and upper ranges were specified
    if (!exists("lower") | !exists("upper")) {
      stop("Lower and upper ranges must be specified for
           a rectangular color range")
    }

    # Make sure that lower bounds are of appropriate format (divisible by
    # 3/matrix with 3 columns)
    if (is.vector(lower)) {
      if (length(lower) %% 3 == 0) {
        lower <- matrix(lower, ncol = 3, byrow = TRUE)
      } else {
        stop("Lower must be a vector with length a multiple of 3
             or a matrix of lower bounds")
      }
    } else if (is.matrix(lower)) {
      if (ncol(lower) != 3) {
        stop("Lower bounds matrix must have 3 columns, 1 per channel")
      }
    }

    # Same with upper; there is probably a more elegant way to do this than just
    # doing both separately... probably with quote/eval, but the variable
    # reassignment makes me itchy
    if (is.vector(upper)) {
      if (length(upper) %% 3 == 0) {
        upper <- matrix(upper, ncol = 3, byrow = TRUE)
      } else {
        stop("Upper must be a vector with length a multiple of 3
             or a matrix of lower bounds")
      }
    } else if (is.matrix(upper)) {
      if (ncol(upper) != 3) {
        stop("Upper bounds matrix must have 3 columns, 1 per channel")
      }
    }

    # Make sure that the same number of upper and lower bounds were provided
    if (nrow(lower) != nrow(upper)) {
      stop("Number of lower and upper bounds differs")
    }

    # And make sure everything is in the 0-1 range; if not, assume 0-255 and
    # divide by 255
    if (range(lower)[2] > 1 | range(upper)[2] > 1) {
      lower <- lower / 255
      upper <- upper / 255
    }

    message("Using rectangular bound(s):")
    for (i in 1:nrow(lower)) {
      message(paste("R: ", paste(lower[i, 1], "-", upper[i, 1], sep = ""),
                    "; G: ", paste(lower[i, 2], "-", upper[i, 2], sep = ""),
                    "; B: ", paste(lower[i, 3], "-", upper[i, 3], sep = ""),
                    sep = ""))
    }

    # Get range using first color
    filtered.img <- rectangularRange(pixel.array = original, lower = lower[1, ],
                                     upper = upper[1, ], plotting = FALSE,
                                     color.pixels = get.indicator,
                                     target.color = target.color[1])
    idx <- filtered.img$pixel.idx

    if (get.indicator) {
      indicator.img <- filtered.img$indicator.img
    }

    # If more than one lower/upper bound pair were specified, repeat the process
    # over increasingly filtered images
    if (nrow(lower) > 1) {
      for (i in 2:nrow(lower)) {
        filtered.img <- rectangularRange(pixel.array = original,
                                         lower = lower[i, ], upper = upper[i, ],
                                         plotting = FALSE, color.pixels = FALSE)
        if (get.indicator) {
          indicator.img <- changePixelColor(indicator.img,
                                            filtered.img$pixel.idx,
                                            target.color = target.color[i],
                                            return.img = TRUE, plotting = FALSE)
        }
        idx <- rbind(idx, filtered.img$pixel.idx)
      }
    }



  }
  else {
    stop("color.range must be either 'spherical' or 'rectangular'")
  }

  # Plot if indicated
  if (plotting) {
    countcolors::plotArrayAsImage(indicator.img)
  }

  # If destination specified (save.indicator was either TRUE or a path), save a
  # comparison image with original and masked images
  if (exists("destination")) {
    png::writePNG(indicator.img, target = destination, dpi = dpi)
    message(paste("Output image written to", destination))
  }

  return.list <- list(pixel.idx = unique(idx),
                      pixel.fraction =
                        nrow(unique(idx)) / nrow(img$filtered.rgb.2d))

  if (return.indicator) {
    return.list$indicator.img <- indicator.img
  }

  return(return.list)

}

# countColorInDirectory: wrapper for countColor, applies to every picture in a
# folder and returns a dataframe with % cover by image
#
# folder: folder with images (JPG/PNG) in it
# ... : arguments passed to 'countColor' for each image
#'
#' Count colors within range(s) in every image in a directory
#'
#' A wrapper for \code{\link{countColors}} that finds every image (JPEG or PNG) in a #' folder and counts colors in each image.
#'
#' @param folder Path to a folder containing images.
#'
#' @inheritParams countColors
#'
#' @return A list of \code{\link{countColors}} lists, one for each image.
#'
#' @seealso \code{\link{countColors}}
#'
#' @examples
#' \dontrun{
#' folder <- system.file("extdata", package = "countcolors")
#'
#' # Screen out white in both the flower image and the pelican image
#' upper <- c(1, 1, 1)
#' lower <- c(0.8, 0.8, 0.8)
#'
#' white.screen <- countcolors::countColorsInDirectory(folder, color.range =
#' "rectangular", upper = upper, lower = lower, bg.lower = NULL, plotting =
#' TRUE, target.color = "turquoise")
#'}
#' @export
countColorsInDirectory <- function(folder,
                                   color.range = "spherical",
                                   center, radius, lower, upper,
                                   bg.lower = rep(0.8, 3), bg.upper = rep(1, 3),
                                   target.color = c("magenta", "cyan", "yellow"),
                                   plotting = FALSE, save.indicator = FALSE, dpi=72,
                                   return.indicator = FALSE) {

  # Get a list of all the images
  images <- colordistance::getImagePaths(folder)

  # For each image, run countColors function and store the result
  output <- vector("list", length = length(images))

  # Run the first one without suppressing messages to screen for color ranges
  message(length(images), " images \n")
  output[[1]] <-
    countcolors::countColors(images[1], color.range = color.range,
      center = center, radius = radius,
      lower = lower, upper = upper,
      bg.lower = bg.lower, bg.upper = bg.upper,
      target.color = target.color, plotting = plotting,
      save.indicator = save.indicator, dpi = dpi,
      return.indicator = return.indicator)

  message("\n Image: ", basename(images[1]))

  for (i in 2:length(images)) {
    message("Image: ", basename(images[i]))
    output[[i]] <-suppressMessages(countcolors::countColors(images[i],
                      color.range = color.range,
                      center = center, radius = radius,
                      lower = lower, upper = upper,
                      bg.lower = bg.lower, bg.upper = bg.upper,
                      target.color = target.color, plotting = plotting,
                      save.indicator = save.indicator, dpi = dpi,
                      return.indicator = return.indicator))
  }

  names(output) <- tools::file_path_sans_ext(basename(images))

  return(output)

}
