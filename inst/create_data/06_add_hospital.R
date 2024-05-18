#' @import dplyr
#' 
################################################################################
## 01. 전국 병원 위치 데이터 읽기
################################################################################
##==============================================================================
## 01.01. 데이터 파일 읽기
##==============================================================================
##------------------------------------------------------------------------------
## 01.01.01. 파일 정보
##------------------------------------------------------------------------------
## https://www.data.go.kr/data/15051059/fileData.do
## https://opendata.hira.or.kr/op/opc/selectOpenData.do?sno=11925
## 공공데이터포털 > 건강보험심사평가원_전국 병의원 및 약국 현황
data_path <- here::here("raw", "stats")
fnames <- c("1.병원정보서비스 2024.3.xlsx")

##------------------------------------------------------------------------------
## 01.01.02. 데이터 읽기
##------------------------------------------------------------------------------
library(tidyverse)
library(openxlsx)

hospital <- fnames %>% 
  purrr::map_df(
    function(x) {
      fname <- glue::glue("{data_path}/{x}")
      
      hospital <- openxlsx::read.xlsx(fname)
      
      hospital |> 
        rename("hospital_nm" = 요양기관명,
               "class_cd" = 종별코드,
               "class_nm" = 종별코드명,               
               # "mega_cd" = 시도코드,
               # "mega_nm" = 시도코드명,
               # "cty_cd" = 시군구코드,
               # "cty_nm" = 시군구코드명,               
               # "admi_nm" = 읍면동,
               "post_cd" = 우편번호,
               "address" = 주소,
               "homepage" = 병원홈페이지,
               "open_date" = 개설일자,
               "doctor_cnt" = 총의사수,
               "medical_gp_cnt" = `의과일반의.인원수`,
               "medical_intern_cnt" = `의과인턴.인원수`,
               "medical_residency_cnt" = `의과레지던트.인원수`,
               "medical_specialist_cnt" = `의과전문의.인원수`,
               "dental_gp_cnt" = `치과일반의.인원수`,
               "dental_intern_cnt" = `치과인턴.인원수`,
               "dental_residency_cnt" = `치과레지던트.인원수`,
               "dental_specialist_cnt" = `치과전문의.인원수`,
               "kmedicine_gp_cnt" = `한방일반의.인원수`,
               "kmedicine_intern_cnt" = `한방인턴.인원수`,
               "kmedicine_residency_cnt" = `한방레지던트.인원수`,
               "kmedicine_specialist_cnt" = `한방전문의.인원수`,
               "lat" = `좌표(Y)`,
               "lon" = `좌표(X)`) %>% 
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
tmp <- hospital %>% 
  filter(!is.na(lon))

# load(here::here("raw", "sf", "admi_origin.rda"))

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
    st_intersects(admi_origin) %>% 
    as.integer() %>% 
    admi_origin[., ] %>% 
    select(base_ym:admi_nm) %>% 
    st_drop_geometry() 
  
  postions %>% 
    bind_cols(
      result
    )
}

hospital_pos <- tmp %>% 
  bind_cols(
    position2admi_origin(tmp$lon, tmp$lat) %>% 
      select(base_ym:admi_nm)
  ) 
rm(tmp)


##------------------------------------------------------------------------------
## 02.02.02. 미 매치건 추출
##------------------------------------------------------------------------------
hospital_nomatch <- hospital_pos %>% 
  filter(is.na(mega_cd))

##------------------------------------------------------------------------------
## 02.02.03. 매치건만 취하기
##------------------------------------------------------------------------------
hospital_pos <- hospital_pos %>% 
  filter(!is.na(mega_cd))


##==============================================================================
## 02.02. 주소로 행정구역 매핑하기 - 위치 정보 없는 건
##==============================================================================
##------------------------------------------------------------------------------
## 02.02.01. 대상 추출
##------------------------------------------------------------------------------
no_position <- hospital %>% 
  filter(is.na(lon)) %>% 
  bind_rows(
    hospital_nomatch %>% 
      select_at(all_of(names(hospital)))
  )
  

##------------------------------------------------------------------------------
## 02.02.02. 광역시도 + 시군구 + 읍면동 조인으로 매핑하기
##  주소의 1, 2, 3, 번째 워드를 각각 추출하여 조인
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  mutate(mega_nm = stringr::word(address, 1)) %>% 
  mutate(cty_nm = stringr::word(address, 2)) %>% 
  mutate(admi_nm = stringr::word(address, 3))

hospital_nopos_01 <- tmp %>% 
  inner_join(
     admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
    ) %>% 
  select(hospital_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)
  
##------------------------------------------------------------------------------
## 02.02.03. 광역시도 + 시군구 + 읍면동 조인으로 매핑하기
##  주소의 1, 2과 괄호 안의 워드를 각각 추출하여 조인
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  setdiff(hospital_nopos_01 %>%
            select(names(no_position))) %>%   
  mutate(mega_nm = stringr::word(address, 1)) %>% 
  mutate(cty_nm = stringr::word(address, 2)) %>% 
  mutate(admi_nm = stringr::str_replace(address, "([[:print:]]+)(\\()([[:print:]]+)(\\))", "\\3") %>% 
           stringr::word(1) %>% 
           stringr::str_remove(","))

hospital_nopos_02 <- tmp %>% 
  inner_join(
    admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
  ) %>% 
  select(hospital_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry) %>% 
  setdiff(hospital_nopos_01)


##------------------------------------------------------------------------------
## 02.02.04. 광역시도 + 시군구 조인으로 매핑하기 - 도에 구가 있는 행정구역
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  setdiff(hospital_nopos_01 %>%
            select(names(no_position))) %>%  
  setdiff(hospital_nopos_02 %>%
            select(names(no_position))) %>%    
  mutate(mega_nm = stringr::word(address, 1)) %>% 
  mutate(cty_nm = paste(
    stringr::word(address, 2),
    stringr::word(address, 3))) %>% 
  mutate(admi_nm = stringr::str_replace(address, "([[:print:]]+)(\\()([[:print:]]+)(\\))", "\\3") %>% 
           stringr::word(1) %>% 
           stringr::str_remove(","))

hospital_nopos_03 <- tmp %>% 
  inner_join(
    admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
  ) %>% 
  select(hospital_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry) %>% 
  setdiff(hospital_nopos_01) %>% 
  setdiff(hospital_nopos_02)  


##------------------------------------------------------------------------------
## 02.02.05. 세종특별자치시
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  setdiff(hospital_nopos_01 %>%
            select(names(no_position))) %>%  
  setdiff(hospital_nopos_02 %>%
            select(names(no_position))) %>%  
  setdiff(hospital_nopos_03 %>%
            select(names(no_position))) %>%    
  filter(stringr::str_detect(address, "^세종특별자치시")) %>% 
  mutate(mega_nm = "세종특별자치시") %>% 
  mutate(cty_nm = "세종시") %>% 
  mutate(admi_nm = stringr::word(address, 2))

hospital_nopos_04 <- tmp %>% 
  inner_join(
    admi %>% 
      select(1:7) %>% 
      st_centroid(),
    by = c("mega_nm", "cty_nm", "admi_nm")
  ) %>% 
  select(hospital_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)


##------------------------------------------------------------------------------
## 02.02.06. 우편번호로 행정동 패핑
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  setdiff(hospital_nopos_01 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_02 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_03 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_04 %>%
            select(names(no_position))) %>% 
  left_join(
    post_admi,
    by = c("post_cd")
  ) %>% 
  filter(!is.na(mega_nm))

hospital_nopos_05 <- tmp %>% 
  left_join(
    admi %>% 
      select(base_ym:admi_nm) %>% 
      st_centroid()
  ) %>% 
  select(hospital_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, 
         admi_nm, geometry)
  

##------------------------------------------------------------------------------
## 02.02.07. 주소로 매핑
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  setdiff(hospital_nopos_01 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_02 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_03 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_04 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_05 %>%
            select(names(no_position))) 

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

hospital_nopos_06 <- tmp %>% 
  left_join(
    admi %>% 
      select(base_ym:admi_nm) %>% 
      st_centroid()
  ) %>% 
  select(hospital_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm, geometry)


##------------------------------------------------------------------------------
## 02.02.08. 주소로 미 매핑건 보정 후 매핑
##------------------------------------------------------------------------------
tmp <- no_position %>% 
  setdiff(hospital_nopos_01 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_02 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_03 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_04 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_05 %>%
            select(names(no_position))) %>% 
  setdiff(hospital_nopos_06 %>%
            select(names(no_position))) %>%   
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

hospital_nopos_07 <- tmp %>% 
  left_join(
    admi %>% 
      select(base_ym:admi_nm) %>% 
      st_centroid(),
    by = c("base_ym", "mega_nm", "mega_cd", "cty_nm", "cty_cd", "admi_nm", "admi_cd")
  ) %>% 
  select(hospital_nm:lat, base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm, geometry)


##==============================================================================
## 02.03. 위경도 없는 데이터 병합
##==============================================================================
hospital_nopos <- hospital_nopos_01 %>% 
  bind_rows(
    hospital_nopos_02
  ) %>% 
  bind_rows(
    hospital_nopos_03
  ) %>% 
  bind_rows(
    hospital_nopos_04
  ) %>% 
  bind_rows(
    hospital_nopos_05
  ) %>% 
  bind_rows(
    hospital_nopos_06
  ) %>% 
  bind_rows(
    hospital_nopos_07
  )    


##==============================================================================
## 02.04. 위경도 정제
##==============================================================================
pos <- hospital_nopos$geometry %>% 
  st_coordinates()

hospital_nopos$lon <- pos[, 1]
hospital_nopos$lat <- pos[, 2]

hospital_nopos <- hospital_nopos %>% 
  select(-geometry)


##==============================================================================
## 02.05. 최종 데이터
##==============================================================================
hospital_info <- hospital_pos %>% 
  bind_rows(
    hospital_nopos
  ) %>% 
  mutate(cty_cd = ifelse(cty_nm %in% "증평군", "43780", cty_cd))  

save(hospital_info, file = here::here("data", "hospital_info.rda"))

################################################################################
## 03. 전국 병원 위치 통계 생성
################################################################################
##==============================================================================
## 03.01. 광역시도 레벨 집계
##==============================================================================
mega <- mega %>% 
  left_join(
    hospital_info %>% 
      group_by(base_ym, mega_cd, mega_nm) %>% 
      summarise(total_hospital_cnt = n(),
                doctor_cnt = sum(doctor_cnt, na.rm = TRUE)) %>% 
      left_join(
        hospital_info %>% 
          group_by(base_ym, mega_cd, mega_nm, class_nm) %>% 
          summarise(hospital_cnt = n()) %>% 
          tidyr::pivot_wider(names_from = "class_nm", values_from = "hospital_cnt") %>% 
          mutate_if(is.integer, function(x) ifelse(is.na(x), 0, x)) %>%       
          mutate(보건소 = 보건소 + 보건의료원) %>%
          rename(hospital_cnt = 병원,
                 pubhealth_center_cnt = 보건소,
                 pubhealth_branch_cnt = 보건지소,
                 pubhealth_clinic_cnt = 보건진료소,
                 tertiary_hospital_cnt = 상급종합,
                 nursing_hospital_cnt = 요양병원,
                 clinic_cnt = 의원,
                 mental_hospital_cnt = 정신병원,
                 midwife_hospital_cnt = 조산원,
                 general_hospital_cnt = 종합병원,
                 dental_hospital_cnt = 치과병원,
                 dental_clinic_cnt = 치과의원,
                 kmedicine_hospital_cnt = 한방병원,
                 kmedicine_clinic_cnt = 한의원) %>% 
          select(-보건의료원),
        by = c("base_ym", "mega_cd", "mega_nm")        
      ),
    by = c("base_ym", "mega_cd", "mega_nm")       
  ) %>% 
  select(base_ym:pharmacy_cnt, total_hospital_cnt:pubhealth_branch_cnt,
         pubhealth_clinic_cnt, tertiary_hospital_cnt:kmedicine_clinic_cnt)



##==============================================================================
## 03.02. 시군구 레벨 집계
##==============================================================================
cty <- cty %>% 
  left_join(
    hospital_info %>% 
      group_by(base_ym, mega_cd, mega_nm, cty_cd, cty_nm) %>% 
      summarise(total_hospital_cnt = n(),
                doctor_cnt = sum(doctor_cnt, na.rm = TRUE)) %>% 
      left_join(
        hospital_info %>% 
          group_by(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, class_nm) %>% 
          summarise(hospital_cnt = n()) %>% 
          tidyr::pivot_wider(names_from = "class_nm", values_from = "hospital_cnt") %>% 
          mutate_if(is.integer, function(x) ifelse(is.na(x), 0, x)) %>%       
          mutate(보건소 = 보건소 + 보건의료원) %>%
          rename(hospital_cnt = 병원,
                 pubhealth_center_cnt = 보건소,
                 pubhealth_branch_cnt = 보건지소,
                 pubhealth_clinic_cnt = 보건진료소,
                 tertiary_hospital_cnt = 상급종합,
                 nursing_hospital_cnt = 요양병원,
                 clinic_cnt = 의원,
                 mental_hospital_cnt = 정신병원,
                 midwife_hospital_cnt = 조산원,
                 general_hospital_cnt = 종합병원,
                 dental_hospital_cnt = 치과병원,
                 dental_clinic_cnt = 치과의원,
                 kmedicine_hospital_cnt = 한방병원,
                 kmedicine_clinic_cnt = 한의원) %>% 
          select(-보건의료원),
        by = c("base_ym", "mega_cd", "mega_nm", "cty_cd", "cty_nm")      
      ),
    by = c("base_ym", "mega_cd", "mega_nm", "cty_cd", "cty_nm")     
  ) %>% 
  select(base_ym:pharmacy_cnt, total_hospital_cnt:pubhealth_branch_cnt,
         pubhealth_clinic_cnt, tertiary_hospital_cnt:kmedicine_clinic_cnt)


##==============================================================================
## 03.03. 읍면동 레벨 집계
##==============================================================================
admi <- admi %>% 
  left_join(
    hospital_info %>% 
      group_by(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm) %>% 
      summarise(total_hospital_cnt = n(),
                doctor_cnt = sum(doctor_cnt, na.rm = TRUE)) %>% 
      left_join(
        hospital_info %>% 
          group_by(base_ym, mega_cd, mega_nm, cty_cd, cty_nm, admi_cd, admi_nm, class_nm) %>% 
          summarise(hospital_cnt = n()) %>% 
          tidyr::pivot_wider(names_from = "class_nm", values_from = "hospital_cnt") %>% 
          mutate_if(is.integer, function(x) ifelse(is.na(x), 0, x)) %>%       
          mutate(보건소 = 보건소 + 보건의료원) %>%
          rename(hospital_cnt = 병원,
                 pubhealth_center_cnt = 보건소,
                 pubhealth_branch_cnt = 보건지소,
                 pubhealth_clinic_cnt = 보건진료소,
                 tertiary_hospital_cnt = 상급종합,
                 nursing_hospital_cnt = 요양병원,
                 clinic_cnt = 의원,
                 mental_hospital_cnt = 정신병원,
                 midwife_hospital_cnt = 조산원,
                 general_hospital_cnt = 종합병원,
                 dental_hospital_cnt = 치과병원,
                 dental_clinic_cnt = 치과의원,
                 kmedicine_hospital_cnt = 한방병원,
                 kmedicine_clinic_cnt = 한의원) %>% 
          select(-보건의료원),
        by = c("base_ym", "mega_cd", "mega_nm", "cty_cd", "cty_nm", "admi_cd", "admi_nm")    
      ),
    by = c("base_ym", "mega_cd", "mega_nm", "cty_cd", "cty_nm", "admi_cd", "admi_nm")    
  ) %>% 
  select(base_ym:pharmacy_cnt, total_hospital_cnt:pubhealth_branch_cnt,
         pubhealth_clinic_cnt, tertiary_hospital_cnt:kmedicine_clinic_cnt) %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x), 0, x)) 


##==============================================================================
## 03.04. 지도 데이터 저장
##==============================================================================
save(mega, file = here::here("data", "mega.rda"))
save(cty, file = here::here("data", "cty.rda"))
save(admi, file = here::here("data", "admi.rda"))




