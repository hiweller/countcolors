Introduction to countcolors package
================
Hannah Weller
2018-05-21

What does this package do?
--------------------------

The `countcolors` package finds pixels by color range in an image. It started as a collaboration between [Sarah Hooper](https://scholar.google.com/citations?user=gaUr5yEAAAAJ&hl=en), [Sybill Amelon](https://www.nrs.fs.fed.us/people/Amelon), and me ([Hannah Weller](https://scholar.google.com/citations?user=rjI5wpEAAAAJ&hl=en)), in order to quantify the area of white-nose syndrome infection on bat wings. In general, it's meant to substitute for manual region-of-interest selection, which can be time-consuming and inconsistent.

How it works
------------

`countcolors` deals primarily with RGB color space. You're probably familiar with the fact that digital images are stored with three color layers: red, green, and blue. We can think of these like the dimensions of a three-dimensional color space<sup>[1](#colorspace)</sup>

<a name="colorspace">1</a>: Of course, there are many color spaces besides RGB, such as HSV (probably familiar), CMYK (maybe familiar), and CIELab (probably only familiar if you've worked with color spaces before, in which case you definitely don't need my explanation). RGB is actually considered quite a poor representation of how human beings perceive color, but for our purposes it works fine, not to mention that converting to a perceptually uniform color space like CIELab is computationally expensive.

Example
-------

Finding the right color range
-----------------------------

Counting the pixels
-------------------

Checking the answer
-------------------

Multiple images
---------------

Vignette Info
-------------

Note the various macros within the `vignette` section of the metadata block above. These are required in order to instruct R how to build the vignette. Note that you should change the `title` field and the `\VignetteIndexEntry` to match the title of your vignette.

Styles
------

The `html_vignette` template includes a basic CSS theme. To override this theme you can specify your own CSS in the document metadata as follows:

    output: 
      rmarkdown::html_vignette:
        css: mystyles.css

Figures
-------

The figure sizes have been customised so that you can easily put two images side-by-side.

``` r
plot(1:10)
plot(10:1)
```

![](Introduction_files/figure-markdown_github/unnamed-chunk-1-1.png)![](Introduction_files/figure-markdown_github/unnamed-chunk-1-2.png)

You can enable figure captions by `fig_caption: yes` in YAML:

    output:
      rmarkdown::html_vignette:
        fig_caption: yes

Then you can use the chunk option `fig.cap = "Your figure caption."` in **knitr**.

More Examples
-------------

You can write math expressions, e.g. *Y* = *X**β* + *ϵ*, footnotes[1], and tables, e.g. using `knitr::kable()`.

|                   |   mpg|  cyl|   disp|   hp|  drat|     wt|   qsec|   vs|   am|  gear|  carb|
|-------------------|-----:|----:|------:|----:|-----:|------:|------:|----:|----:|-----:|-----:|
| Mazda RX4         |  21.0|    6|  160.0|  110|  3.90|  2.620|  16.46|    0|    1|     4|     4|
| Mazda RX4 Wag     |  21.0|    6|  160.0|  110|  3.90|  2.875|  17.02|    0|    1|     4|     4|
| Datsun 710        |  22.8|    4|  108.0|   93|  3.85|  2.320|  18.61|    1|    1|     4|     1|
| Hornet 4 Drive    |  21.4|    6|  258.0|  110|  3.08|  3.215|  19.44|    1|    0|     3|     1|
| Hornet Sportabout |  18.7|    8|  360.0|  175|  3.15|  3.440|  17.02|    0|    0|     3|     2|
| Valiant           |  18.1|    6|  225.0|  105|  2.76|  3.460|  20.22|    1|    0|     3|     1|
| Duster 360        |  14.3|    8|  360.0|  245|  3.21|  3.570|  15.84|    0|    0|     3|     4|
| Merc 240D         |  24.4|    4|  146.7|   62|  3.69|  3.190|  20.00|    1|    0|     4|     2|
| Merc 230          |  22.8|    4|  140.8|   95|  3.92|  3.150|  22.90|    1|    0|     4|     2|
| Merc 280          |  19.2|    6|  167.6|  123|  3.92|  3.440|  18.30|    1|    0|     4|     4|

Also a quote using `>`:

> "He who gives up \[code\] safety for \[code\] speed deserves neither." ([via](https://twitter.com/hadleywickham/status/504368538874703872))

[1] A footnote here.
