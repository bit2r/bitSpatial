#' @import dplyr
#' 
################################################################################
## 01. 주민등록 인구 및 세대현황
################################################################################
##==============================================================================
## 01.01. Global variables
##==============================================================================
## https://jumin.mois.go.kr/index.jsp
## 행정안전부 > 주민등록 인구통계 > 주민등록 인구 및 세대현황
data_path <- here::here("raw", "stats")
fnames <- c("202206_202206_주민등록인구및세대현황_월간.xlsx")

##==============================================================================
## 01.02. 주민등록 인구 및 세대현황 데이터 읽기
##==============================================================================
population_total <- fnames %>% 
  purrr::map_df(
    function(x) {
      fname <- glue::glue("{data_path}/{x}")
      
      population_total <- readxl::read_xlsx(fname, skip = 2)
      
      population_total %>% 
        rename("org_cd" = 행정기관코드,
               "org_nm" = 행정기관,
               "population" = 총인구수,
               "household" = 세대수,
               "pop_per_hosue" = `세대당 인구`,
               "pop_male" = `남자 인구수`,
               "pop_female" = `여자 인구수`,
               "male_per_female" = `남여 비율`) %>% 
        filter(!str_detect(org_cd, "000000$")) %>% 
        mutate(base_ym = stringr::str_sub(x, 1, 6)) %>% 
        mutate_at(vars(!matches("org")), function(x) {str_remove(x, ",")}) %>% 
        mutate_at(vars(!matches("org")), as.numeric) %>% 
        mutate(mega_cd = substr(org_cd, 1, 2)) %>% 
        mutate(mega_nm = str_split(org_nm, " ", n = 3) %>%
                 purrr::map_chr(function(x) x[1])) %>% 
        mutate(cty_cd = substr(org_cd, 1, 5)) %>% 
        mutate(cty_nm = str_split(org_nm, " ", n = 3) %>%
                 purrr::map_chr(function(x) x[2])) %>% 
        mutate(admi_cd = substr(org_cd, 1, 10)) %>% 
        mutate(admi_nm = str_split(org_nm, " ", n = 3) %>%
                 purrr::map_chr(function(x) x[3])) %>% 
        select(base_ym, mega_cd:admi_nm, population:male_per_female) %>% 
        filter(!is.na(admi_nm))
    }
  ) %>% 
  mutate(base_ym = as.character(base_ym))


################################################################################
## 02. 수치지도에 주민등록 인구 및 세대현황 넣기
################################################################################
##==============================================================================
## 02.01. 읍면동 레벨에 붙이기
##==============================================================================
admi <- bitSpatial::admi
admi <- admi %>% 
  left_join(
    population_total %>% 
      select(-mega_nm, -cty_nm, -admi_nm),
    by = c("base_ym", "mega_cd", "cty_cd", "admi_cd")
  ) %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x), 0 , x)) %>% 
  select(base_ym:land_area, population:male_per_female)


##==============================================================================
## 02.02. 시군구 레벨에 집계하여 붙이기
##==============================================================================
cty <- bitSpatial::cty
cty <- cty %>% 
  left_join(
    admi %>% 
      group_by(base_ym, mega_cd, mega_nm, cty_cd, cty_nm) %>% 
      summarise(population = sum(population),
                household = sum(household),
                pop_per_hosue = sum(pop_per_hosue) / sum(household),
                pop_male = sum(pop_male),
                pop_female = sum(pop_female),
                male_per_female = sum(pop_male) / sum(pop_female),
                .groups = "drop") %>% 
      sf::st_drop_geometry(),
    by = c("base_ym", "mega_cd", "mega_nm", "cty_cd", "cty_nm")
  )


##==============================================================================
## 02.03. 광역시도 레벨에 집계하여 붙이기
##==============================================================================
mega <- bitSpatial::mega
mega <- mega %>% 
  left_join(
    cty %>% 
      group_by(base_ym, mega_cd, mega_nm) %>% 
      summarise(population = sum(population),
                household = sum(household),
                pop_per_hosue = sum(pop_per_hosue) / sum(household),
                pop_male = sum(pop_male),
                pop_female = sum(pop_female),
                male_per_female = sum(pop_male) / sum(pop_female),
                .groups = "drop") %>% 
      sf::st_drop_geometry(),
    by = c("base_ym", "mega_cd", "mega_nm")
  )


##==============================================================================
## 02.04. 지도 데이터 저장
##==============================================================================
save(mega, file = here::here("data", "mega.rda"))
save(cty, file = here::here("data", "cty.rda"))
save(admi, file = here::here("data", "admi.rda"))


################################################################################
## 03. 연령별 인구현황 (5세 단위)
################################################################################
##==============================================================================
## 03.01. Global variables
##==============================================================================
## https://jumin.mois.go.kr/index.jsp
## 행정안전부 > 주민등록 인구통계 > 연령별 인구현황
data_path <- here::here("raw", "stats")
fnames <- c("202206_202206_연령별인구현황_월간.xlsx")

##==============================================================================
## 03.02. 연령별 인구현황 (5세 단위) 데이터 읽기
##==============================================================================
admi_population_age <- fnames %>% 
  purrr::map_df(
    function(x) {
      fname <- glue::glue("{data_path}/{x}")
      
      population_age <- readxl::read_xlsx(fname, skip = 3) %>% 
        select(-"남 인구수", -"여 인구수", -"연령구간인구수...4", -"연령구간인구수...27")
      
      population_age %>% 
        rename("org_cd" = 행정기관코드,
               "org_nm" = 행정기관) %>% 
        rename_all(str_remove_all, "\\.") %>% 
        rename_all(str_remove_all, "~") %>% 
        filter(!str_detect(org_cd, "000000$")) %>% 
        mutate(base_ym = stringr::str_sub(x, 1, 6)) %>%         
        mutate_at(vars(!matches("org")), function(x) {str_remove(x, ",")}) %>% 
        mutate_at(vars(!matches("org")), as.numeric) %>% 
        pivot_longer(`04세5`:`100세 이상48`,  
                     names_to = "age_group", values_to = "population") %>% 
        mutate(age_group = str_remove(age_group, "세[[:number:]]")) %>% 
        mutate(gender = case_when(
          age_group %in% c("04", "59", "1014", "1519", "2024", "25290", "30341", 
                           "35392", "40443", "45494", "50545", "55596", "60647",
                           "65698", "70749", "75790", "80841", "85892", "90943",
                           "95994", "100세 이상25") ~ "남",
          age_group %in% c("048", "599", "10140", "15191", "20242", "25293", "30344", 
                           "35395", "40446", "45497", "50548", "55599", "60640",
                           "65691", "70742", "75793", "80844", "85895", "90946",
                           "95997", "100세 이상48") ~ "여"
        )) %>% 
        mutate(age_group = case_when(
          str_detect(age_group, "^100") ~ "100+",
          str_detect(age_group, "^04") ~ "01-04",
          str_detect(age_group, "^59") ~ "05-09",
          str_detect(age_group, "^1014") ~ "10-14",
          str_detect(age_group, "^1519") ~ "15-19",
          str_detect(age_group, "^2024") ~ "20-24",
          str_detect(age_group, "^2529") ~ "25-29",
          str_detect(age_group, "^3034") ~ "30-34",
          str_detect(age_group, "^3539") ~ "35-39",
          str_detect(age_group, "^4044") ~ "40-44",
          str_detect(age_group, "^4549") ~ "45-49",
          str_detect(age_group, "^5054") ~ "50-54",
          str_detect(age_group, "^5559") ~ "55-59",
          str_detect(age_group, "^6064") ~ "60-64",
          str_detect(age_group, "^6569") ~ "65-69",
          str_detect(age_group, "^7074") ~ "70-74",
          str_detect(age_group, "^7579") ~ "75-79",
          str_detect(age_group, "^8084") ~ "80-84",
          str_detect(age_group, "^8589") ~ "85-89",
          str_detect(age_group, "^9094") ~ "90-94",
          str_detect(age_group, "^9599") ~ "95-99"
        )) %>%    
        mutate(mega_cd = substr(org_cd, 1, 2)) %>% 
        mutate(mega_nm = str_split(org_nm, " ", n = 3) %>%
                 purrr::map_chr(function(x) x[1])) %>% 
        mutate(cty_cd = substr(org_cd, 1, 4)) %>% 
        mutate(cty_nm = str_split(org_nm, " ", n = 3) %>%
                 purrr::map_chr(function(x) x[2])) %>% 
        mutate(admi_cd = substr(org_cd, 1, 8)) %>% 
        mutate(admi_nm = str_split(org_nm, " ", n = 3) %>%
                 purrr::map_chr(function(x) x[3])) %>% 
        select(base_ym, mega_cd:admi_nm, age_group, gender, population) %>% 
        filter(!is.na(admi_nm))
    }
  ) %>% 
  mutate(base_ym = as.character(base_ym))


################################################################################
## 04. 연령별 인구현황 (5세 단위) 데이터 집계
################################################################################
##==============================================================================
## 04.01. 시군구 레벨에 집계하여 붙이기
##==============================================================================
cty_population_age <- admi_population_age %>% 
  group_by(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, age_group, gender) %>% 
  summarise(population = sum(population),
            .groups = "drop") 


##==============================================================================
## 02.03. 광역시도 레벨에 집계하여 붙이기
##==============================================================================
mega_population_age <- cty_population_age %>% 
  group_by(base_ym, mega_cd, mega_nm, age_group, gender) %>% 
  summarise(population = sum(population),
            .groups = "drop") 


##==============================================================================
## 02.04. 지도 데이터 저장
##==============================================================================
save(mega_population_age, cty_population_age, admi_population_age,
     file = here::here("data", "population_age.rda"))

