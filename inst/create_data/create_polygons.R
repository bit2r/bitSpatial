################################################################################
## 01. 통계청 지도의 지역코드 코드 변환 및 sf 객체로의 변환 
################################################################################
##==============================================================================
## 01.01. 광역시도 레벨
##==============================================================================
## from https://sgis.kostat.go.kr/view/pss/dataProvdIntrcn (통계청 통계지리정보서비스)
file_mega <- here::here("raw", "shape", "bnd_sido_00_2022_2022", "bnd_sido_00_2022_2022_2Q.shp")
mega <- sf::read_sf(file_mega) %>%
  rename_all(tolower) %>% 
  rename(mega_cd = sido_cd,
         mega_nm = sido_nm) %>%
  mutate(land_area = sf::st_area(.) %>%
           units::set_units(km^2)) %>%
  mutate(base_ym = substr(base_date, 1, 6)) %>% 
  select(base_ym, mega_cd, mega_nm, land_area)

## Simplifying geospatial features
## 플로팅 속도 개선을 위해서 리아스식 해안의 복잡한 해안선을 심플하게 변경
## https://datascience.blog.wzb.eu/2021/03/15/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
mega <- rmapshaper::ms_simplify(mega, keep = 0.001, keep_shapes = FALSE)

object.size(mega) %>%
  format(units = "auto")


##==============================================================================
## 01.02. 시군구 레벨
##==============================================================================
## from https://sgis.kostat.go.kr/view/pss/dataProvdIntrcn (통계청 통계지리정보서비스)
file_cty <- here::here("raw", "shape", "bnd_sigungu_00_2022_2022", "bnd_sigungu_00_2022_2022_2Q.shp")
cty <- sf::read_sf(file_cty) %>%
  rename_all(tolower) %>%   
  mutate(mega_cd = substr(sigungu_cd, 1, 2)) %>%
  rename(cty_cd = sigungu_cd,
         cty_nm = sigungu_nm) %>%
  left_join(
    mega %>%
      select(mega_cd, mega_nm) %>%
      sf::st_drop_geometry(),
    by = "mega_cd"
  ) %>%
  mutate(land_area = sf::st_area(.) %>%
           units::set_units(km^2)) %>%
  mutate(base_ym = substr(base_date, 1, 6)) %>%   
  select(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, land_area)

## Simplifying geospatial features
## 플로팅 속도 개선을 위해서 리아스식 해안의 복잡한 해안선을 심플하게 변경
## https://datascience.blog.wzb.eu/2021/03/15/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
cty <- rmapshaper::ms_simplify(cty, keep = 0.01, keep_shapes = FALSE)

object.size(cty) %>%
  format(units = "auto")

##==============================================================================
## 01.03. 읍면동 레벨
##==============================================================================
## from https://sgis.kostat.go.kr/view/pss/dataProvdIntrcn (통계청 통계지리정보서비스)
file_admi <- here::here("raw", "shape", "bnd_dong_00_2022_2022", "bnd_dong_00_2022_2022_2Q.shp")
admi <- sf::read_sf(file_admi) %>%
  rename_all(tolower) %>%     
  mutate(mega_cd = substr(adm_cd, 1, 2)) %>%
  mutate(cty_cd = substr(adm_cd, 1, 5)) %>%
  left_join(
    cty %>%
      select(mega_cd, mega_nm, cty_cd, cty_nm) %>%
      sf::st_drop_geometry(),
    by = c("mega_cd", "cty_cd")
  ) %>%
  select(base_date, mega_cd:cty_nm, adm_cd, adm_nm) %>%
  rename(admi_cd = adm_cd,
         admi_nm = adm_nm) %>%
  mutate(land_area = sf::st_area(.) %>%
           units::set_units(km^2)) %>%
  mutate(base_ym = substr(base_date, 1, 6)) %>%     
  select(base_ym, mega_cd:cty_nm, admi_cd, admi_nm, land_area)

## Simplifying geospatial features
## 플로팅 속도 개선을 위해서 리아스식 해안의 복잡한 해안선을 심플하게 변경
## https://datascience.blog.wzb.eu/2021/03/15/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
admi <- rmapshaper::ms_simplify(admi, keep = 0.01, keep_shapes = FALSE)

object.size(admi) %>%
  format(units = "auto")


################################################################################
## 02. 행정구역코드와 행정기관코드의 매핑하여 행정기관코드로 일원화
################################################################################
## 통계청 행정구역(행정구역코드)은 행정동(행정기관코드)과 그 관할구역(경계)이 
## 동일하나 서로 다른 코드체계를 지니고 있음.

##==============================================================================
## 02.01. 행정안전부의 행정기관코드 가져오기
##==============================================================================
## from https://www.mois.go.kr/frt/bbs/type001/commonSelectBoardArticle.do?bbsId=BBSMSTR_000000000052&nttId=92810
## - 20220701기준의 행정기관코드
##    - 통계청의 행정구역코드 기준의 지도 기준이 2022년 6월 기준이기 때문에 시점 통일
file_administrative <- here::here("raw", "meta", "KIKcd_H.20220701(말소코드포함).xlsx")
admi_district <- readxl::read_xlsx(file_administrative) %>% 
  filter(is.na(말소일자)) %>% 
  filter(!is.na(읍면동명)) %>%   
  filter(!stringr::str_detect(읍면동명, "출장소$")) %>%     
  rename(mega_nm = 시도명) %>% 
  rename(cty_nm = 시군구명) %>%   
  rename(admi_cd = 행정동코드) %>%
  rename(admi_nm = 읍면동명) %>%   
  mutate(base_ym = "202206") %>% 
  mutate(mega_cd = substr(admi_cd, 1, 2)) %>% 
  mutate(cty_cd = substr(admi_cd, 1, 5)) %>% 
  mutate(cty_nm = case_when(
    mega_cd %in% "36" ~ "세종시",
    TRUE ~ cty_nm  
  )) %>% 
  select(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm)

##==============================================================================
## 02.02. 행정안전부의 행정기관코드 데이터의 한글명을 통계청 지도와 일치시키기
##==============================================================================
admi_district <- admi_district %>% 
  mutate(admi_nm = stringr::str_replace_all(admi_nm, "\\.", "·")) %>%   
  mutate(admi_nm = stringr::str_replace(admi_nm, "([[:alpha:]]+)(제)([[:number:]]+)(동)", "\\1\\3\\4")) %>%  
  mutate(admi_nm = stringr::str_replace(admi_nm, "([[:alpha:]]+)(제)([[:number:]]+)(·)([[:number:]]+)(동)", "\\1\\3\\4\\5\\6")) %>%  
  mutate(admi_nm = stringr::str_replace(admi_nm, "탑대성동", "탑·대성동")) %>%    
  left_join(
    admi %>% 
      select(-mega_cd, -cty_cd, -admi_cd) %>% 
      sf::st_drop_geometry(),
    by = c("base_ym", "mega_nm", "cty_nm", "admi_nm")
  ) 

##==============================================================================
## 02.03. 광역시도 레벨의 지도 데이터 코드 변경
##==============================================================================
mega <- mega %>% 
  select(-mega_cd) %>% 
  left_join(
    admi_district %>% 
      distinct(base_ym, mega_cd, mega_nm),
    by = c("base_ym", "mega_nm")
  ) %>% 
  select(base_ym, mega_cd, mega_nm, land_area)


##==============================================================================
## 02.04. 시군구 레벨의 지도 데이터 코드 변경
##==============================================================================
cty <- cty %>% 
  select(-mega_cd, -cty_cd) %>% 
  left_join(
    admi_district %>% 
      distinct(base_ym, mega_cd, mega_nm, cty_cd, cty_nm),
    by = c("base_ym", "mega_nm", "cty_nm")
  ) %>% 
  select(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, land_area)


##==============================================================================
## 02.05. 읍면동 레벨의 지도 데이터 코드 변경
##==============================================================================
admi <- admi %>% 
  select(-mega_cd, -cty_cd, -admi_cd) %>% 
  left_join(
    admi_district %>% 
      distinct(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm),
    by = c("base_ym", "mega_nm", "cty_nm", "admi_nm")
  ) %>% 
  select(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm, land_area)


##==============================================================================
## 02.06. 지도 데이터 저장
##==============================================================================
save(mega, file = here::here("data", "mega.rda"))
save(cty, file = here::here("data", "cty.rda"))
save(admi, file = here::here("data", "admi.rda"))


