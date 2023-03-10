#' @import dplyr
#' 
################################################################################
## 01. 전국 약국 위치 데이터 읽기
################################################################################
##==============================================================================
## 01.01. 데이터 파일 읽기
##==============================================================================
##------------------------------------------------------------------------------
## 01.01.01. 파일 정보
##------------------------------------------------------------------------------
## https://www.data.go.kr/data/15051059/fileData.do
## 공공데이터포털 > 건강보험심사평가원_전국 병의원 및 약국 현황
data_path <- here::here("raw", "stats")
fnames <- c("2.약국정보서비스 2022.10.csv")

##------------------------------------------------------------------------------
## 01.01.02. 데이터 읽기
##------------------------------------------------------------------------------
library(tidyverse)

pharmacy <- fnames %>% 
  purrr::map_df(
    function(x) {
      fname <- glue::glue("{data_path}/{x}")
      
      pharmacy <- readr::read_csv(fname, locale = locale("ko", encoding = "euc-kr"),
                                  col_types = "cccccccccccDdd")
      
      pharmacy %>% 
        rename("pharmacy_nm" = 요양기관명,
               "class_cd" = 종별코드,
               "class_nm" = 종별코드명,               
               # "mega_cd" = 시도코드,
               # "mega_nm" = 시도코드명,
               # "cty_cd" = 시군구코드,
               # "cty_nm" = 시군구코드명,               
               # "admi_nm" = 읍면동,
               "post_cd" = 우편번호,
               "address" = 주소,
               "open_date" = 개설일자,
               "lat" = `좌표(y)`,
               "lon" = `좌표(x)`) %>% 
        select(-암호화요양기호, -시도코드, -시도코드명, -시군구코드, 
               -시군구코드명, -읍면동) %>% 
        mutate(post_cd = stringr::str_pad(post_cd, 5, pad = "0"))
    }
  ) 


################################################################################
## 02. 데이터 전처리
################################################################################
##==============================================================================
## 02.01. 위치정보로 행정구역 매핑하기
##==============================================================================
## 위치정보가 있는 건만 대상으로 작업
tmp <- pharmacy %>% 
  filter(!is.na(lon))

load(here::here("raw", "sf", "admi_origin.rda"))

position2admi_origin <- function(x, y, proj = c("WGS84", "Bessel", "GRS80", "KATECH")) {
  proj <- match.arg(proj)
  
  if (proj != "WGS84") {
    pos <- convert_projection(x, y, from = proj, to = "WGS84")
    
    x <- pos$lon
    y <- pos$lat
  }
  
  crsWGS84  <- 4326
  
  postions <- data.frame(lon = x, lat = y)
  
  result <- postions %>% 
    st_as_sf(coords = c("lon", "lat")) %>% 
    st_set_crs(crsWGS84) %>% 
    st_intersects(admi) %>% 
    as.integer() %>% 
    admi_origin[., ] %>% 
    select(base_ym:admi_nm) %>% 
    st_drop_geometry() 
  
  postions %>% 
    bind_cols(
      result
    )
}

pharmacy_pos <- tmp %>% 
  bind_cols(
    position2admi_origin(tmp$lon, tmp$lat) %>% 
      select(base_ym:admi_nm)
  ) 
rm(tmp)

##==============================================================================
## 02.02. 주소로 행정구역 매핑하기 - 위치 정보 없는 건
##==============================================================================
##------------------------------------------------------------------------------
## 02.02.01. 대상 추출
##------------------------------------------------------------------------------
no_position <- pharmacy %>% 
  filter(is.na(lon))

##------------------------------------------------------------------------------
## 02.02.02. 광역시도 + 시군구 + 읍면동 조인으로 매핑하기
##  주소의 1, 2, 3, 번째 워드를 각각 추출하여 조인
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  mutate(mega_nm = stringr::word(address, 1)) %>% 
  mutate(cty_nm = stringr::word(address, 2)) %>% 
  mutate(admi_nm = stringr::word(address, 3))

pharmacy_nopos_01 <- tmp %>% 
  inner_join(
     admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
    ) %>% 
  select(pharmacy_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)
  
##------------------------------------------------------------------------------
## 02.02.03. 광역시도 + 시군구 + 읍면동 조인으로 매핑하기
##  주소의 1, 2과 괄호 안의 워드를 각각 추출하여 조인
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  mutate(mega_nm = stringr::word(address, 1)) %>% 
  mutate(cty_nm = stringr::word(address, 2)) %>% 
  mutate(admi_nm = stringr::str_replace(address, "([[:print:]]+)(\\()([[:print:]]+)(\\))", "\\3") %>% 
           stringr::word(1))

pharmacy_nopos_02 <- tmp %>% 
  inner_join(
    admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
  ) %>% 
  select(pharmacy_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)


##------------------------------------------------------------------------------
## 02.02.04. 광역시도 + 시군구 조인으로 매핑하기 - 도에 구가 있는 행정구역
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  mutate(mega_nm = stringr::word(address, 1)) %>% 
  mutate(cty_nm = paste(
    stringr::word(address, 2),
    stringr::word(address, 3))) %>% 
  mutate(admi_nm = stringr::str_replace(address, "([[:print:]]+)(\\()([[:print:]]+)(\\))", "\\3") %>% 
           stringr::word(1))

pharmacy_nopos_03 <- tmp %>% 
  inner_join(
    admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
  ) %>% 
  select(pharmacy_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)


##------------------------------------------------------------------------------
## 02.02.05. 세종특별자치시
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  filter(stringr::str_detect(address, "^세종특별자치시")) %>% 
  mutate(mega_nm = "세종특별자치시") %>% 
  mutate(cty_nm = "세종시") %>% 
  mutate(admi_nm = stringr::word(address, 2))

pharmacy_nopos_04 <- tmp %>% 
  inner_join(
    admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
  ) %>% 
  select(pharmacy_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)


##------------------------------------------------------------------------------
## 02.02.06. 우편번호로 행정동 패핑
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  left_join(
    pharmacy_nopos_01 %>% 
      bind_rows(
        pharmacy_nopos_02
      ) %>% 
      bind_rows(
        pharmacy_nopos_03
      ) %>% 
      bind_rows(
        pharmacy_nopos_04
      ),
    by = c("pharmacy_nm", "class_cd", "class_nm", "post_cd", "address", 
           "open_date", "lon", "lat")
  ) %>% 
  filter(is.na(admi_cd)) %>% 
  select(-(base_ym:admi_nm)) %>% 
  left_join(
    post_admi,
    by = c("post_cd")
  ) %>% 
  filter(!is.na(mega_nm))

pharmacy_nopos_05 <- tmp %>% 
  select(-geometry) %>% 
  left_join(
    admi %>% 
      select(base_ym:admi_nm) %>% 
      st_centroid()
  ) %>% 
  select(pharmacy_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)
  

##------------------------------------------------------------------------------
## 02.02.07. 주소로 매핑
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  left_join(
    pharmacy_nopos_01 %>% 
      bind_rows(
        pharmacy_nopos_02
      ) %>% 
      bind_rows(
        pharmacy_nopos_03
      ) %>% 
      bind_rows(
        pharmacy_nopos_04
      ) %>% 
      bind_rows(
        pharmacy_nopos_05
      ),      
    by = c("pharmacy_nm", "class_cd", "class_nm", "post_cd", "address", 
           "open_date", "lon", "lat")
  ) %>% 
  filter(is.na(admi_cd)) %>% 
  select(-(base_ym:admi_nm)) 


tmp <- tmp %>% 
  mutate(short_addr = stringr::word(address, start = 1, end = 4)) %>% 
  inner_join(
    road_addr,
    by = c("short_addr") 
  ) %>% 
  bind_rows(
    tmp %>% 
      mutate(short_addr = stringr::word(address, start = 1, end = 5)) %>% 
      inner_join(
        road_addr,
        by = c("short_addr") 
      )
  )

pharmacy_nopos_06 <- tmp %>% 
  select(-geometry) %>% 
  left_join(
    admi %>% 
      select(base_ym:admi_nm) %>% 
      st_centroid()
  ) %>% 
  select(pharmacy_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm, geometry)


##------------------------------------------------------------------------------
## 02.02.08. 주소로 미 매핑건 보정 후 매핑
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  left_join(
    pharmacy_nopos_01 %>% 
      bind_rows(
        pharmacy_nopos_02
      ) %>% 
      bind_rows(
        pharmacy_nopos_03
      ) %>% 
      bind_rows(
        pharmacy_nopos_04
      ) %>% 
      bind_rows(
        pharmacy_nopos_05
      ) %>% 
      bind_rows(
        pharmacy_nopos_06
      ),          
    by = c("pharmacy_nm", "class_cd", "class_nm", "post_cd", "address", 
           "open_date", "lon", "lat")
  ) %>% 
  filter(is.na(admi_cd)) %>% 
  select(-(base_ym:admi_nm)) 


tmp <- tmp %>% 
  mutate(short_addr = stringr::str_replace(address, "([[:print:]]+)(-)([[:print:]]+)", "\\1")) %>% 
  inner_join(
    road_addr,
    by = c("short_addr") 
  ) %>% 
  bind_rows(
    tmp %>% 
      mutate(short_addr = paste(stringr::word(address, start = 1, end = 3),
                                stringr::word(address, start = 5, end = 6))) %>% 
      inner_join(
        road_addr,
        by = c("short_addr") 
      )
  )

pharmacy_nopos_07 <- tmp %>% 
  select(-geometry) %>% 
  left_join(
    admi %>% 
      select(base_ym:admi_nm) %>% 
      st_centroid()
  ) %>% 
  select(pharmacy_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm, geometry)


##==============================================================================
## 02.03. 위경도 없는 데이터 병합
##==============================================================================
pharmacy_nopos <- pharmacy_nopos_01 %>% 
  bind_rows(
    pharmacy_nopos_02
  ) %>% 
  bind_rows(
    pharmacy_nopos_03
  ) %>% 
  bind_rows(
    pharmacy_nopos_04
  ) %>% 
  bind_rows(
    pharmacy_nopos_05
  ) %>% 
  bind_rows(
    pharmacy_nopos_06
  ) %>% 
  bind_rows(
    pharmacy_nopos_07
  )    


##==============================================================================
## 02.04. 위경도 정제
##==============================================================================
pos <- pharmacy_nopos$geometry %>% 
  st_coordinates()

pharmacy_nopos$lon <- pos[, 1]
pharmacy_nopos$lat <- pos[, 2]

pharmacy_nopos <- pharmacy_nopos %>% 
  select(-geometry)


##==============================================================================
## 02.05. 최종 데이터
##==============================================================================
pharmacy_info <- pharmacy_pos %>% 
  bind_rows(
    pharmacy_nopos
  ) %>% 
  mutate(cty_cd = ifelse(cty_nm %in% "증평군", "43780", cty_cd))  

save(pharmacy_info, file = here::here("data", "pharmacy_info.rda"))

################################################################################
## 03. 전국 약국 위치 통계 생성
################################################################################
##==============================================================================
## 03.01. 광역시도 레벨 집계
##==============================================================================
mega <- mega %>% 
  left_join(
    pharmacy_info %>% 
      count(base_ym, mega_cd, mega_nm) %>% 
      rename(pharmacy_cnt = n),
    by = c("base_ym", "mega_cd", "mega_nm")
  ) %>% 
  select(base_ym:high_schl_cnt, pharmacy_cnt)


##==============================================================================
## 03.02. 시군구 레벨 집계
##==============================================================================
cty <- cty %>% 
  left_join(
    pharmacy_info %>% 
      count(base_ym, mega_cd, mega_nm, cty_cd, cty_nm) %>% 
      rename(pharmacy_cnt = n),
    by = c("base_ym", "mega_cd", "mega_nm", "cty_cd", "cty_nm")
  ) %>% 
  select(base_ym:high_schl_cnt, pharmacy_cnt)


##==============================================================================
## 03.03. 읍면동 레벨 집계
##==============================================================================
admi <- admi %>% 
  left_join(
    pharmacy_info %>% 
      count(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm) %>% 
      rename(pharmacy_cnt = n),
    by = c("base_ym", "mega_cd", "mega_nm", "cty_cd", "cty_nm", "admi_cd", "admi_nm")
  ) %>% 
  mutate(pharmacy_cnt = ifelse(is.na(pharmacy_cnt), 0, pharmacy_cnt)) %>% 
  select(base_ym:high_schl_cnt, pharmacy_cnt)


##==============================================================================
## 03.04. 지도 데이터 저장
##==============================================================================
save(mega, file = here::here("data", "mega.rda"))
save(cty, file = here::here("data", "cty.rda"))
save(admi, file = here::here("data", "admi.rda"))




