# cp ~/Documents/Projects/WHO/coronavirus/covid19-dashboard/data/wom/* output/snapshots

# tmp %>%
#   group_by(dt) %>%
#   tally() %>%
#   ggplot(aes(dt, n)) +
#   geom_point() +
#   theme_minimal()
# # updates on average every <10 minutes

library(dplyr)

# suppressPackageStartupMessages({
#   library(rvest)
#   library(tibble)
#   library(snakecase)
#   library(dplyr)
# })

url <- "https://www.worldometers.info/coronavirus/"

page <- xml2::read_html(url)

table <- rvest::html_node(page, "#main_table_countries_today")

# get timestamp before getting content
timestamp <- format(Sys.time(), "%Y-%m-%d_%H%M%S_%Z", tz = "UTC")

# parse html table into data.frame
data <- table %>%
  rvest::html_table() %>%
  dplyr::as_tibble()

# if (!ncol(data) == 8)
#   stop("Format of table has changed. ",
#     "Expecting a column of sources in column 8.")

nms <- names(data)
nms <- snakecase::to_snake_case(nms)

expected <- c("country_other", "total_cases", "total_deaths",
  "total_recovered")

if (!all(expected %in% nms))
  stop("Expected column names have changed.")

# fix empty names
idx <- which(nms == "")
nms[idx] <- paste0("emptyname", idx)

# other manipulation?
names(data) <- nms

data <- data %>%
  dplyr::rename(
    region = "country_other",
    cases = "total_cases",
    deaths = "total_deaths",
    recovered = "total_recovered"
  ) %>%
  dplyr::select(dplyr::one_of(c("region", "cases", "deaths", "recovered")))

for (i in 2:ncol(data)) {
  data[[i]][data[[i]] %in% c("", "-")] <- NA
  data[[i]] <- gsub(",", "", data[[i]])
  data[[i]] <- gsub("\\+", "", data[[i]])
  tmp <- tryCatch(as.integer(data[[i]]), warning = function(w) w)
  if (!inherits(tmp, "warning"))
    data[[i]] <- tmp
}

data <- dplyr::filter(data, !region %in% c("North America", "Europe",
  "South America", "Asia", "Africa", "Oceania", "World", ""))

# write to a temporary file
ff <- file.path(tempdir(), paste0("wom_", timestamp, ".csv"))
readr::write_csv(data, ff)

# only put it in output directory if it is new
md5_new <- unname(tools::md5sum(ff))
md5_prev <- ""

ff2 <- tail(sort(list.files("data/wom", full.names = TRUE)), 1)
if (length(ff2) == 1)
  md5_prev <- unname(tools::md5sum(ff2))

if (md5_new != md5_prev) {
  message("  ... data has changed - writing new file")
  readr::write_csv(data,
    file.path("output/snapshots", paste0("wom_", timestamp, ".csv")))
}

# prune old snapshot data so that we only have the latest file for every day
ff <- list.files("output/snapshots", full.names = TRUE)
rgxp <- paste0("^wom", "_(.*)_UTC\\.csv$")
dt_str <- gsub(rgxp, "\\1", basename(ff))
dt <- as.Date(as.POSIXct(strptime(dt_str, "%Y-%m-%d_%H%M%S", tz = "UTC")))
tmp <- tibble(dt = dt, idx = seq_along(dt))
idx <- tmp %>% group_by(dt) %>% slice(n()) %>% pull(idx)
ff2 <- ff[setdiff(seq_along(dt), idx)]
file.remove(ff2)

ff <- list.files(paste0("output/snapshots"), full.names = TRUE)

d <- lapply(seq_along(ff), function(ii) {
  suppressMessages(readr::read_csv(ff[ii], na = c("", "NA", "N/A"))) %>%
    dplyr::mutate(date = dt[ii]) %>%
    tidyr::replace_na(list(deaths = 0))
}) %>%
  dplyr::bind_rows() %>%
  dplyr::arrange(region, date)

d <- d %>%
  dplyr::filter(!grepl("^Total", region)) %>%
  dplyr::group_by(region) %>%
  tidyr::complete(date = seq.Date(min(date), max(date), by = "day")) %>%
  tidyr::fill(cases) %>%
  tidyr::fill(deaths) %>%
  dplyr::ungroup() %>%
  dplyr::filter(!is.na(region)) %>%
  dplyr::select(-recovered)

lookup <- suppressMessages(readr::read_csv("src/lookup.csv"))

d <- dplyr::left_join(d, lookup, by = "region") %>%
  dplyr::select(admin0_code, date, cases, deaths)

d <- d %>%
  dplyr::group_by(admin0_code, date) %>%
  summarise(cases = sum(cases), deaths = sum(deaths))

d <- d %>%
  dplyr::left_join(
    dplyr::select(geoutils::admin0, admin0_code, who_region_code, continent_code),
    by = "admin0_code")

global <- d %>%
  dplyr::group_by(date) %>%
  dplyr::summarise(cases = sum(cases), deaths = sum(deaths)) %>%
  dplyr::arrange(date)

who <- d %>%
  dplyr::group_by(who_region_code, date) %>%
  dplyr::summarise(cases = sum(cases), deaths = sum(deaths)) %>%
  dplyr::arrange(who_region_code, date) %>%
  dplyr::filter(who_region_code != "Conveyance" & !is.na(who_region_code))

cont <- d %>%
  dplyr::group_by(continent_code, date) %>%
  dplyr::summarise(cases = sum(cases), deaths = sum(deaths)) %>%
  dplyr::arrange(continent_code, date) %>%
  dplyr::filter(!is.na(continent_code))

admin0 <- dplyr::select(d, admin0_code, date, cases, deaths)

stopifnot(dplyr::select(d, admin0_code, date) %>% dplyr::distinct() %>% nrow() == nrow(d))

readr::write_csv(admin0, "output/admin0/all.csv")
readr::write_csv(cont, "output/continents.csv")
readr::write_csv(who, "output/who_regions.csv")
readr::write_csv(global, "output/global.csv")
