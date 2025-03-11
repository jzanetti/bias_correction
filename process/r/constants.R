
TMP_DIR <- "/tmp/bias_correction"

# Check if directory exists and create it if it doesn't
if (!dir.exists(TMP_DIR)) {
  dir.create(TMP_DIR, recursive = TRUE)
}

TEST_DATA <- "examples/etc/test_data.csv"