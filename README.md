## USA SCADA Check how to use

The SCADA Check is ran in R using the R Shiny web applications. This
will make it easy and user friendly for all to use. This readme file
will walk you through these items:

-   How to access and where its located.
-   What is needed to run, what R packages will need to be loaded.
-   Steps to fill out the web SCADA Check.

### <u>Packages needed to have installed</u>

The R program as written should automatically load the packages needed,
but just in case you need to manually here are the steps:

R packages need:

```         
  library(shiny)
  library(shinyWidgets)
  library(shinyjs)
  library(shinyalert)
  library(rmarkdown)
  library(zip)
  library(dplyr)
  library(lubridate)
  library(anytime)
  library(leaflet)
  library(tidyr)
```

1.  Install a package run: `install.packages()` (e.g. `library(shiny)`
    is `install.packages('shiny')`)

    -   Enter the package name in between the parentheses with single
        quotes `'shiny'`
    -   if you need here is the code to load them all at once:

    ```{r, eval=FALSE}
    # Define the list of packages to install
    packages_to_install <- c("shiny", "shinyWidgets", "shinyjs", "shinyalert", "rmarkdown", "zip", "dplyr", "lubridate", "anytime", "leaflet", "tidyr")

    # Check if the packages are already installed, install if not, then load them
    installed_packages <- installed.packages()[, "Package"]
    packages_to_install <- packages_to_install[!packages_to_install %in% installed_packages]
    if (length(packages_to_install)) {
     install.packages(packages_to_install, dependencies = TRUE)
    }

    # Load the installed packages into the R session
    lapply(packages_to_install, require, character.only = TRUE)
    ```

2.  Follow all direction from R after that.

### <u>Steps to fill out the web SCADA Check.</u>

This section will walk you through on how to fill out the SCADA Check.

1.  After you have complete the steps above.

2.  You will need to run this file to start: `RunApp_Scada_Check.R`.
    click to open

    -   ![](./run.PNG) <br><br>
    -   Next on top right of wind that just opened click on Run App
    -   ![](./runapp.PNG) <br><br>

3.  This will open a new web page on your default web browser.

    -   Preferably use Chrome or MS Edge. <br><br>

#### <u>The SCADA Check is in 3 different sections and 1 optional section</u>

-   ***1.*** <u>Site Information</u>
    -   This section is where you will enter information about your
        site.
    -   Please read and understand the Disclaimer
        -   ![](./sitediscalim.PNG)
    -   Steps:
        -   Enter Site Name
        -   Enter Turbine Count
        -   Enter Manufacturer Type. (try to keep this format if
            possible GE 1.62 MW)
        -   Enter WTG Rating (enter the kW numbers,
            `kW = mW x 1000 or kW = 1.62 x 1000`, kW = 1620)
        -   If you make a mistake and need to re-enter data click on:
            *Clear Site Information Data* button <br><br>
-   ***2.*** <u>External Data Upload</u>
    -   Stop and read Disclaimer again.
        -   ![](./DataDisclaim.PNG) <br><br>\
    -   If you need a template to upload you data please use the
        download template:
    -   Please make sure that the data file you upload is in this format
        ONLY.
        -   ![](./download.PNG) <br><br>
-   ***3.*** <u>Upload External Data</u>
    -   Click on the Browse button
        -   ![](./upload.PNG) <br><br>
-   ***4.*** <u>Optional Section. Additional WTG Ratings (if needed)</u>
    -   <code style="color : red">**NOTE**:</code> Use if site has two
        or more manufacturers and/or rating types;
        <code style="color : red">**IF NOT SKIP**:</code>
    -   Please read the Note:
        -   ![](./addwtgs.PNG)
        -   ***How to use:***
            -   First you will need to upload your external data file.
            -   Click the `Select One or Multiple turbines` button
            -   Select the number of WTG's by their names. You can
                choose more than one.
            -   ![](./select%20wtg.PNG)
            -   Then enter the kW number. (enter the kW numbers,
                `kW = mW x 1000 or kW = 2.62 x 1000`, kW = 2620)
            -   ![](./add%20wtg%20kw.PNG)
            -   Finally, click ***Add Row***.
            -   If you make a mistake and need to re-enter data click
                on: *Clear Additional Rating Data* button.

<br><br> - ***5.*** <u>Create SCADA Report</u> - Once all the above
sections are filled out click on the `Create SCADA Check Report`. -
![](./create.PNG) <br> - <code style="color : red">**NOTE**:</code> -
You will get a pop-up error if you forget to fill out these 2 sections:
***"Site Information", "External Data Upload"***

### <u>Final Report and Download</u>

When you have filled out all the information properly the SCADA report
will be showing within the web page you have open.

Example: ![](./report.PNG) <br><br>

If you want to download the SCADA Report click on ***Download SCADA
Report***

![](./downL.PNG) <br><br>

That is how you run the SCADA Report and download the report.

If you have any question please contact:

-   Bently Bartee
-   [barteec\@gmail.com](mailto:barteec@gmail.com){.email}
