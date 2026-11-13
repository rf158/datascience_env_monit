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
  hh_name <- grep("FLUXMET_HH",
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
nrow(hh_all)

# Check which sites were included
unique(hh_all$site)

# Number of observations per site
hh_all |>
  count(site)

# Check time range
range(hh_all$time)

# Share of measured NEE
mean(hh_all$NEE_VUT_REF_QC == 0, na.rm = TRUE)
