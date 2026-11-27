# Previous part
library(readr)
library(dplyr)

keep <- c("TIMESTAMP_START", "TIMESTAMP_END", "TA_F", "SW_IN_F", "VPD_F", "P_F",
          "NETRAD", "G_F_MDS", "H_F_MDS", "H_F_MDS_QC", "LE_F_MDS", "LE_F_MDS_QC",
          "NEE_VUT_REF", "NEE_VUT_REF_QC", "GPP_NT_VUT_REF", "RECO_NT_VUT_REF")

zip_file <- list.files("data/raw", pattern = "\\.zip$", full.names = TRUE)[1]
hh_name  <- grep("FLUXMET_DD", unzip(zip_file, list = TRUE)$Name, value = TRUE)
unzip(zip_file, files = hh_name, exdir = "data/raw/unzipped")

hh <- read_csv(file.path("data/raw/unzipped", hh_name),
               na = "-9999",
               col_select = any_of(keep),
               col_types = cols(TIMESTAMP_START = "c", TIMESTAMP_END = "c", .default = "d")) |>
  mutate(time = as.POSIXct(TIMESTAMP_START, format = "%Y%m%d%H%M", tz = "UTC"))

nrow(hh)
range(hh$time)
mean(hh$NEE_VUT_REF_QC == 0, na.rm = TRUE)   # share of measured NEE


# Function
library(readr)
library(dplyr)

# Create function
read_hh <- function(zip_file) {

  keep <- c("TIMESTAMP_START", "TIMESTAMP_END", "TA_F", "SW_IN_F",
            "VPD_F", "P_F", "NETRAD", "G_F_MDS",
            "H_F_MDS", "H_F_MDS_QC", "LE_F_MDS",
            "LE_F_MDS_QC", "NEE_VUT_REF", "NEE_VUT_REF_QC",
            "GPP_NT_VUT_REF", "RECO_NT_VUT_REF")

  # Extract site ID from ZIP filename
  site <- tools::file_path_sans_ext(basename(zip_file))

  # Find the half-hourly file inside the ZIP
  hh_name <- grep("FLUXMET_DD",
                  unzip(zip_file, list = TRUE)$Name,
                  value = TRUE)

  # Extract the file into the unzipped folder
  unzip(zip_file, files = hh_name,
        exdir = "data/raw/unzipped")

  # Read the half-hourly data
  hh <- read_csv(
    file.path("data/raw/unzipped", hh_name),
    na = "-9999",
    col_select = any_of(keep),
    col_types = cols(
      TIMESTAMP_START = "c",
      TIMESTAMP_END = "c",
      .default = "d"
    )
  ) |>
    mutate(
      time = as.POSIXct(TIMESTAMP_START,
                        format = "%Y%m%d%H%M",
                        tz = "UTC"),
      site = site
    )

  return(hh)
}

# All files in one table
zip_files <- list.files(
  "data/raw",
  pattern = "\\.zip$",
  full.names = TRUE
)

# Apply function to every ZIP file
hh_data <- lapply(zip_files, read_hh) |>
  bind_rows()

# Do checks
# Number of observations
nrow(hh_data)

# Check which sites were included
unique(hh_data$site)

# Number of observations per site
hh_data |>
  count(site)

# Check time range
range(hh_data$time)

# Share of measured NEE
mean(hh_data$NEE_VUT_REF_QC == 0, na.rm = TRUE)

# unzip daily files:

library(readr)
library(dplyr)

read_dd <- function(zip_file, exdir = "data/raw/unzipped") {

  keep <- c("TIMESTAMP", "TA_F", "SW_IN_F", "VPD_F", "P_F", "NETRAD",
            "G_F_MDS", "H_F_MDS", "H_F_MDS_QC", "LE_F_MDS", "LE_F_MDS_QC",
            "NEE_VUT_REF", "NEE_VUT_REF_QC", "GPP_NT_VUT_REF", "RECO_NT_VUT_REF")

  # Site ID from ZIP filename, e.g. "FLX_DE-Hai_FLUXNET..." -> "DE-Hai"
  site <- sub("^[A-Za-z]+_([A-Z]{2}-[A-Za-z0-9]+)_.*$", "\\1",
              basename(zip_file))

  # Find the daily file inside the ZIP (first match only)
  dd_name <- grep("FLUXMET_DD",
                  unzip(zip_file, list = TRUE)$Name,
                  value = TRUE)[1]

  if (is.na(dd_name)) {
    warning("No FLUXMET_DD file in ", basename(zip_file))
    return(NULL)
  }

  unzip(zip_file, files = dd_name, exdir = exdir)

  read_csv(
    file.path(exdir, dd_name),
    na = "-9999",
    col_select = any_of(keep),
    col_types = cols(TIMESTAMP = "c", .default = "d")
  ) |>
    mutate(
      date = as.Date(TIMESTAMP, format = "%Y%m%d"),
      site = site
    )
}

# All ZIP files -> one table
zip_files <- list.files("data/raw", pattern = "\\.zip$", full.names = TRUE)

dd_data <- lapply(zip_files, read_dd) |>
  bind_rows()

# Checks
nrow(dd_data)                 # number of daily observations
unique(dd_data$site)          # sites included
count(dd_data, site)          # observations per site
range(dd_data$date)           # time range

# Share of days with mostly measured NEE (>= 80% measured/good-quality records)
mean(dd_data$NEE_VUT_REF_QC >= 0.8, na.rm = TRUE)

