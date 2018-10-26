**Author**: Hannah Weller  
**Email**: hannahiweller@gmail.com  
**GitHub**: https://github.com/hiweller  

An R package that counts colors within color range(s) in images, and
    provides a masked version of the image with targeted pixels
    changed to a different color. Output includes the locations
    of the pixels in the images, and the proportion of the image
    within the target color range with optional background masking.
    Users can specify multiple color ranges for masking.

## About countcolors

This package is the result of a collaboration between  [Sarah
Hooper](https://scholar.google.com/citations?user=gaUr5yEAAAAJ&hl=en),
[Sybill Amelon](https://www.nrs.fs.fed.us/people/Amelon), and me
([Hannah
Weller](https://scholar.google.com/citations?user=rjI5wpEAAAAJ&hl=en)),
with the goal of quantifying the area of white-nose syndrome infection
of bat wings.

Countcolors allows users to quantify regions of an image by color(s).
It's a companion package to
[colordistance](https://CRAN.R-project.org/package=colordistance), which
provides quantitative color comparisons of images. While both of these
packages borrow techniques from image processing, they don't use any
machine learning, adaptive thresholding, or object detection. This makes
them reliable and easy to use, but limited in application.

Countcolors is best suited for images where the color(s) of interest are
reasonably different from the rest of the image – so if you've got an
image of some treetops, it can quantify the amount of green tree cover,
but it wouldn't necessarily be able to distinguish a species with leaves
of one slightly different shade of green from all the others due to
variations in lighting (among other sources of variation). If this is
the kind of specificity you need, you're better off just eating the big
rat and using real image processing. I recommend the [OpenCV
library](https://opencv.org/) for C++ or Python.

## Installation instructions

1. Install the `devtools` package (`install.packages("devtools")`).
2. Install `countcolors` using the `install_github` function:
```{r}
devtools::install_github("hiweller/countcolors")
```

## Questions or feedback?

Email me: <hannahiweller@gmail.com>
