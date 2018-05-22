**Author**: Hannah Weller  
**Email**: hannahiweller@gmail.com  
**GitHub**: https://github.com/hiweller  

An R package that counts colors within color range(s) in images, and
    provides a masked version of the image with targeted pixels
    changed to a different color. Output includes the locations
    of the pixels in the images, and the proportion of the image
    within the target color range with optional background masking.
    Users can specify multiple color ranges for masking.

## Planned edits before CRAN release

* Testing
* ~~1D indexing in range functions~~
* ~~Explanatory vignette~~
* Rcpp for speed?

## Installation instructions

1. Install the `devtools` package (`install.packages("devtools")`).
2. Install `countcolors` using the `install_github` function:
```{r}
devtools::install_github("hiweller/countcolors")
```

## Questions or feedback?

Email me: <hannahiweller@gmail.com>
