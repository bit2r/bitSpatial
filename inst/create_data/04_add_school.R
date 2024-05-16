#' @import dplyr
#' 
################################################################################
## 01. 전국 초중등학교 위치 표준 데이터
################################################################################
##==============================================================================
## 01.01. 전국 초중등학교 위치 표준 데이터 읽기
##==============================================================================
##------------------------------------------------------------------------------
## 01.01.01. Global variables
##------------------------------------------------------------------------------
## https://www.data.go.kr/data/15021148/standard.do?recommendDataYn=Y
## 공공데이터포털 > 전국초중등학교위치표준데이터
data_path <- here::here("raw", "stats")
fnames <- c("전국초중등학교위치표준데이터.csv")

library(tidyverse)
##------------------------------------------------------------------------------
## 01.01.02. 데이터 읽기
##------------------------------------------------------------------------------
school <- fnames %>% 
  purrr::map_df(
    function(x) {
      fname <- glue::glue("{data_path}/{x}")
      
      school <- readr::read_csv(fname, locale = locale("ko", encoding = "euc-kr"))
      
      school %>% 
        rename("school_id" = 학교ID,
               "school_nm" = 학교명,
               "school_class" = 학교급구분,
               "estab_date" = 설립일자,               
               "estab_class" = 설립형태,
               "branch_cd" = 본교분교구분,
               "operate_stat" = 운영상태,
               "addr_land" = 소재지지번주소,
               "addr_road" = 소재지도로명주소,
               "edu_office_cd" = 시도교육청코드,
               "edu_office_nm" = 시도교육청명,
               "edu_support_cd" = 교육지원청코드,
               "edu_support_nm" = 교육지원청명,
               "lat" = 위도,
               "lon" = 경도,
               "base_date" = 데이터기준일자) %>% 
        select(-생성일자, -변경일자, -제공기관코드, -제공기관명) 
    }
  ) 


##==============================================================================
## 01.02. 위치정보로 행정구역 매핑하기
##==============================================================================
school <- school %>% 
  bind_cols(
    position2admi(school$lon, school$lat) %>% 
      select(mega_cd:admi_nm)
  ) 


##==============================================================================
## 01.03. 전국 초중등학교 위치 표준 데이터 저장하기
##==============================================================================
save(school, file = here::here("data", "school.rda"))



################################################################################
## 02. 수치지도에 전국 초중등학교 통계 데이터 넣기
################################################################################
##==============================================================================
## 02.01. 광역시도 레벨
##==============================================================================
# mega <- bitSpatial::mega
mega <- mega %>% 
  left_join(
    school %>% 
      filter(school_class %in% "초등학교") %>% 
      group_by(mega_cd) %>% 
      tally() %>% 
      rename("elemnt_schl_cnt" = n),
    by = c( "mega_cd")) %>% 
  left_join(
    school %>% 
      filter(school_class %in% "중학교") %>% 
      group_by(mega_cd) %>% 
      tally() %>% 
      rename("mdle_schl_cnt" = n),
    by = c( "mega_cd")) %>% 
  left_join(
    school %>% 
      filter(school_class %in% "고등학교") %>% 
      group_by(mega_cd) %>% 
      tally() %>% 
      rename("high_schl_cnt" = n),        
    by = c( "mega_cd")) %>%  
  select(base_ym:age_mean, elemnt_schl_cnt:high_schl_cnt) %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x), 0 , x)) 


##==============================================================================
## 02.02. 시군구 레벨
##==============================================================================
# cty <- bitSpatial::cty
cty <- cty %>% 
  left_join(
    school %>% 
      filter(school_class %in% "초등학교") %>% 
      group_by(mega_cd, cty_cd) %>% 
      tally() %>% 
      rename("elemnt_schl_cnt" = n),
    by = c( "mega_cd", "cty_cd")) %>% 
  left_join(
    school %>% 
      filter(school_class %in% "중학교") %>% 
      group_by(mega_cd, cty_cd) %>% 
      tally() %>% 
      rename("mdle_schl_cnt" = n),
    by = c( "mega_cd", "cty_cd")) %>% 
  left_join(
    school %>% 
      filter(school_class %in% "고등학교") %>% 
      group_by(mega_cd, cty_cd) %>% 
      tally() %>% 
      rename("high_schl_cnt" = n),        
    by = c( "mega_cd", "cty_cd")) %>% 
  select(base_ym:age_mean, elemnt_schl_cnt:high_schl_cnt) %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x), 0 , x)) 


##==============================================================================
## 02.03. 읍면동 레벨
##==============================================================================
# admi <- bitSpatial::admi
admi <- admi %>% 
  left_join(
    school %>% 
      filter(school_class %in% "초등학교") %>% 
      group_by(mega_cd, cty_cd, admi_cd) %>% 
      tally() %>% 
      rename("elemnt_schl_cnt" = n),
    by = c( "mega_cd", "cty_cd", "admi_cd")) %>% 
  left_join(
    school %>% 
      filter(school_class %in% "중학교") %>% 
      group_by(mega_cd, cty_cd, admi_cd) %>% 
      tally() %>% 
      rename("mdle_schl_cnt" = n),
    by = c( "mega_cd", "cty_cd", "admi_cd")) %>% 
  left_join(
    school %>% 
      filter(school_class %in% "고등학교") %>% 
      group_by(mega_cd, cty_cd, admi_cd) %>% 
      tally() %>% 
      rename("high_schl_cnt" = n),        
    by = c( "mega_cd", "cty_cd", "admi_cd")) %>% 
  select(base_ym:age_mean, elemnt_schl_cnt:high_schl_cnt) %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x), 0 , x)) 


##==============================================================================
## 01.03. 지도 데이터 저장
##==============================================================================
save(mega, file = here::here("data", "mega.rda"))
save(cty, file = here::here("data", "cty.rda"))
save(admi, file = here::here("data", "admi.rda"))
