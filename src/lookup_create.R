library(tidyverse)
library(reticulate)
coco <- import("country_converter")
cc <- coco$CountryConverter()

dat <- d
dat <- dat %>%
  mutate(region2 = region) %>%
  mutate(region2 = replace(region2, region2 == "DRC",
    "Democratic Republic of Congo")) %>%
  mutate(region2 = replace(region2, region2 == "XK",
    "Kosovo")) %>%
  mutate(region2 = replace(region2, region2 == "UAE",
    "United Arab Emirates")) %>%
  mutate(region2 = replace(region2, region2 == "UK",
    "United Kingdom")) %>%
  mutate(region2 = replace(region2, region2 == "Nothern Cyprus",
    "Cyprus")) %>%
  mutate(region2 = replace(region2, region2 == "CAR",
    "Central African Republic")) %>%
  mutate(region2 = replace(region2, region2 == "MS Zaandam",
    "International Conveyance")) %>%
  mutate(region2 = replace(region2, grepl("Cruise Ship", region2),
    "International Conveyance")) %>%
  mutate(region2 = replace(region2, grepl("Diamond Princess", region2),
    "International Conveyance"))
cr <- sort(unique(dat$region2))
cr_lookup <- tibble(
  region2 = cr,
  admin0_code = cc$convert(cr, to = "ISO2")
)
cr_lookup$admin0_code[cr_lookup$admin0_code == "not found"] <- NA
cr_lookup$admin0_code[cr_lookup$region2 == "International Conveyance"] <- "ZZ"

lkp <- select(dat, region, region2) %>%
  distinct() %>%
  left_join(cr_lookup, by = "region2") %>%
  filter(!is.na(admin0_code)) %>%
  select(-region2) %>%
  distinct()

readr::write_csv(lkp, path = "src/lookup.csv")
