#' @import dplyr
#' 
################################################################################
## 01. 전국 상가업소 위치 정보 데이터
################################################################################
##==============================================================================
## 01.01. 전국 상가업소 위치 정보 데이터 읽기
##==============================================================================
##------------------------------------------------------------------------------
## 01.01.01. Global variables
##------------------------------------------------------------------------------
## https://www.data.go.kr/data/15083033/fileData.do
## 소상공인시장진흥공단_상가(상권)정보
data_path <- here::here("raw", "stats", "stores")

fnames <- list.files(data_path, pattern = "csv$")

library(tidyverse)
##------------------------------------------------------------------------------
## 01.01.02. 데이터 읽기
##------------------------------------------------------------------------------
store_info <- fnames %>% 
  purrr::map_df(
    function(x) {
      fname <- glue::glue("{data_path}/{x}")
      
      store <- readr::read_csv(fname, col_types = "cccccccccccccccccccccciiccciiccccccccdd")
      
      store %>% 
        rename("store_id" = 상가업소번호,
               "store_nm" = 상호명,
               "branch_nm" = 지점명,
               "industry_l_cd" = 상권업종대분류코드,               
               "industry_l_nm" = 상권업종대분류명,
               "industry_m_cd" = 상권업종중분류코드,
               "industry_m_nm" = 상권업종중분류명,
               "industry_s_cd" = 상권업종소분류코드,
               "industry_s_nm" = 상권업종소분류명,
               "stnd_industry_cd" = 표준산업분류코드,
               "stnd_industry_nm" = 표준산업분류명,
               "mega_cd" = 시도코드,
               "mega_nm" = 시도명,
               "cty_cd" = 시군구코드,
               "cty_nm" = 시군구명,
               "admi_cd" = 행정동코드,
               "admi_nm" = 행정동명,     
               "law_admi_cd" = 법정동코드,
               "law_admi_nm" = 법정동명, 
               "landno_cd" = 지번코드, 
               "plat_class_cd" = 대지구분코드, 
               "plat_class_nm" = 대지구분명, 
               "land_major_no" = 지번본번지, 
               "land_minor_no" = 지번부번지, 
               "land_addr" = 지번주소, 
               "road_cd" = 도로명코드, 
               "road_nm" = 도로명, 
               "build_major_no" = 건물본번지, 
               "build_minor_no" = 건물부번지, 
               "regist_bukd_no" = 건물관리번호, 
               "build_nm" = 건물명, 
               "road_addr" = 도로명주소, 
               "post_cd_old" = 구우편번호, 
               "post_cd" = 신우편번호, 
               "dong_info" = 동정보, 
               "floor_info" = 층정보, 
               "house_info" = 호정보,                
               "lat" = 위도,
               "lon" = 경도)
    }
  ) 



################################################################################
## 02. 패키지 수치지도의 행정구역으로 매핑하기
################################################################################
##==============================================================================
## 02.01. 시군구 이름의 수치지도 기준으로의 변경
##  - 구를 포함하는 도의 4 단계 행정구역 구조에 해당하는 건들
##==============================================================================
store_info <- store_info %>% 
  select(-cty_nm) %>% 
  left_join(
    cty %>% 
      select(cty_cd, cty_nm),
    by = "cty_cd"
  ) %>% 
  select(store_id:cty_cd, cty_nm, admi_cd:lat) %>% 
  sf::st_drop_geometry() 


##==============================================================================
## 02.02. 시군구 이름이 증평군인 건의 시군구 코드 수정
##==============================================================================
store_info <- store_info %>% 
  mutate(cty_nm = ifelse(cty_cd %in% "43785", "증평군", cty_nm)) %>% 
  mutate(cty_cd = ifelse(cty_cd %in% "43785", "43745", cty_cd)) 


##==============================================================================
## 02.03. 행정동 코드로 행정동 이름 매핑하여 변경
##==============================================================================
store_info <- store_info %>% 
  left_join(
    admi %>% 
      select(admi_cd, admi_nm_mega = admi_nm, land_area) %>% 
      sf::st_drop_geometry(),
    by = "admi_cd"
  ) %>% 
  mutate(admi_nm = ifelse(is.na(land_area), admi_nm, admi_nm_mega)) %>% 
  select(-admi_nm_mega, -land_area)


##==============================================================================
## 02.03. 시군구 이름이 증평군인 건의 읍면동 코드 수정
##==============================================================================
store_info <- store_info %>% 
  mutate(admi_cd = ifelse(admi_cd %in% "4378525000", "4374525000", admi_cd)) %>% 
  mutate(admi_cd = ifelse(admi_cd %in% "4378531000", "4374531000", admi_cd)) 


##==============================================================================
## 02.04. 경기도 파주시 장단면 소재 오류건의 보정
##    - 경기도 파주시 군내면/진동면으로 분류가되어 있었음
##==============================================================================
store_info <- store_info %>% 
  mutate(admi_nm = ifelse(admi_cd %in% c("4148038000", "4148040000"), 
                          "장단면", admi_nm)) %>% 
  mutate(admi_cd = ifelse(admi_cd %in% c("4148038000", "4148040000"), 
                          "4148039000", admi_cd)) 
  

################################################################################
## 03. 전국 상가업소 위치 정보 데이터
################################################################################
##==============================================================================
## 03.01. 데이터 파일 사이즈가 github에 올릴 수 있는 100MB를 초과하므로 분리함
##==============================================================================
# store_info %>%
#   count(mega_cd, mega_nm)

store_info_seoul <- store_info %>% 
   filter(mega_cd %in% "11")

store_info_gyeonggi <- store_info %>% 
  filter(mega_cd %in% "41")

store_info_middle <- store_info %>% 
  filter(mega_cd %in% c("28", "30", "36", "42", "43", "44"))

store_info_south <- store_info %>% 
  filter(mega_cd %in% c("26", "27", "29", "31", "45", "46", "47", "48", "50"))


##==============================================================================
## 03.02. 분리한 데이터의 개별 저장
##==============================================================================
save(store_info_seoul, file = here::here("data", "store_info_seoul.rda"))
save(store_info_gyeonggi, file = here::here("data", "store_info_gyeonggi.rda"))
save(store_info_middle, file = here::here("data", "store_info_middle.rda"))
save(store_info_south, file = here::here("data", "store_info_south.rda"))
