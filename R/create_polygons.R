#' 광역시도, 시군구, 읍면동 수치지도 및 통계
#' 
#' @description 
#' sf 클래스 객체로 만들어진 광역시도(mega), 시군구(cty), 읍면동(admi) 레벨의 수치지도 및 관련 통계 
#' 
#' @details 
#' sf 클래스 객체로 만들어진 데이터로서 2022년 6월말 기준의 데이터입니다. 
#' 읍면동 레벨의 데이터는 상위 시군구, 광역시도 정보를 포함하며, 
#' 시군구 레벨의 데이터는 상위 광역시도 정보를 포함합니다.
#' 
#' @format 기준일자, 6개의 행정구역 코드 및 값과 개별 통계정보를 담은 sf 클래스 객체.
#' \describe{
#'   \item{BASE_DATE}{character. 기준일자.}
#'   \item{MEGA_CD}{character. 광역시도 코드.}
#'   \item{MEGA_NM}{character. 광역시도 이름.}
#'   \item{CTY_CD}{character. 시군구 코드.}
#'   \item{CTY_NM}{character. 시군구 이름.}
#'   \item{ADMI_CD}{character. 읍면동 코드.}
#'   \item{ADMI_NM}{character. 읍면동 이름.}
#'   \item{LAND_AREA}{numeric. 면적(km^2).}
#'   \item{geometry}{MULTIPOLYGON. 지도 polygons.}
#' }
#' @docType data
#' @keywords datasets
#' @name mega
#' @usage data(mega)
#' @source 
#' "통계청 통계지리정보서비스" in <https://sgis.kostat.go.kr>, License : 공공저작물 자유이용허락 표시기준(공공누리, KOGL) 제 1유형
NULL

#' @import dplyr
#' @importFrom here here
#' @importFrom sf read_sf st_drop_geometry
#' @importFrom units set_units
#' @importFrom rmapshaper ms_simplify
# ##==============================================================================
# ## 01. Create Mega level
# ##==============================================================================
# ## from https://sgis.kostat.go.kr/view/pss/dataProvdIntrcn (통계청 통계지리정보서비스)
# file_mega <- here::here("raw", "bnd_sido_00_2022_2022", "bnd_sido_00_2022_2022_2Q.shp")
# mega <- sf::read_sf(file_mega) %>% 
#   rename(MEGA_CD = SIDO_CD,
#          MEGA_NM = SIDO_NM) %>% 
#   mutate(LAND_AREA = sf::st_area(.) %>% 
#            units::set_units(km^2)) %>% 
#   select(BASE_DATE:MEGA_NM, LAND_AREA)
# 
# ## Simplifying geospatial features
# ## 플로팅 속도 개선을 위해서 리아스식 해안의 복잡한 해안선을 심플하게 변경
# ## https://datascience.blog.wzb.eu/2021/03/15/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
# mega <- rmapshaper::ms_simplify(mega, keep = 0.001, keep_shapes = FALSE)     
# plot(mega)
# 
# object.size(mega) %>% 
#   format(units = "auto")
# 
# save(mega, file = here::here("data", "mega.rda"))


#' @rdname mega
#' @name cty
#' @usage data(cty)
NULL
# ##==============================================================================
# ## 02. Create Cty level
# ##==============================================================================
# ## from https://sgis.kostat.go.kr/view/pss/dataProvdIntrcn (통계청 통계지리정보서비스)
# file_cty <- here::here("raw", "bnd_sigungu_00_2022_2022", "bnd_sigungu_00_2022_2022_2Q.shp")
# cty <- sf::read_sf(file_cty) %>% 
#   mutate(MEGA_CD = substr(SIGUNGU_CD, 1, 2)) %>% 
#   rename(CTY_CD = SIGUNGU_CD,
#          CTY_NM = SIGUNGU_NM) %>% 
#   left_join(
#     mega %>% 
#       select(MEGA_CD, MEGA_NM) %>% 
#       sf::st_drop_geometry(),
#     by = "MEGA_CD"
#   ) %>% 
#   mutate(LAND_AREA = sf::st_area(.) %>% 
#            units::set_units(km^2)) %>% 
#   select(BASE_DATE, MEGA_CD, MEGA_NM, CTY_CD, CTY_NM, LAND_AREA)
# 
# ## Simplifying geospatial features
# ## 플로팅 속도 개선을 위해서 리아스식 해안의 복잡한 해안선을 심플하게 변경
# ## https://datascience.blog.wzb.eu/2021/03/15/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
# cty <- rmapshaper::ms_simplify(cty, keep = 0.01, keep_shapes = FALSE)     
# cty %>% 
#   filter(MEGA_CD %in% "39") %>% 
#   plot()
# 
# object.size(cty) %>% 
#   format(units = "auto")
# 
# save(cty, file = here::here("data", "cty.rda"))


#' @rdname mega
#' @name admi
#' @usage data(admi)
NULL
# ##==============================================================================
# ## 03. Create Admi level
# ##==============================================================================
# ## from https://sgis.kostat.go.kr/view/pss/dataProvdIntrcn (통계청 통계지리정보서비스)
# file_admi <- here::here("raw", "bnd_dong_00_2022_2022", "bnd_dong_00_2022_2022_2Q.shp")
# admi <- sf::read_sf(file_admi) %>% 
#   mutate(MEGA_CD = substr(ADM_CD, 1, 2)) %>% 
#   mutate(CTY_CD = substr(ADM_CD, 1, 5)) %>% 
#   left_join(
#     cty %>% 
#       select(MEGA_CD, MEGA_NM, CTY_CD, CTY_NM) %>% 
#       sf::st_drop_geometry(),
#     by = c("MEGA_CD", "CTY_CD")    
#   ) %>% 
#   select(BASE_DATE, MEGA_CD:CTY_NM, ADM_CD, ADM_NM) %>% 
#   rename(ADMI_CD = ADM_CD,
#          ADMI_NM = ADM_NM) %>% 
#   mutate(LAND_AREA = sf::st_area(.) %>% 
#            units::set_units(km^2)) %>% 
#   select(BASE_DATE, MEGA_CD:CTY_NM, ADMI_CD, ADMI_NM, LAND_AREA)  
# 
# ## Simplifying geospatial features
# ## 플로팅 속도 개선을 위해서 리아스식 해안의 복잡한 해안선을 심플하게 변경
# ## https://datascience.blog.wzb.eu/2021/03/15/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
# admi <- rmapshaper::ms_simplify(admi, keep = 0.01, keep_shapes = FALSE)     
# admi %>% 
#   filter(MEGA_CD %in% "39") %>% 
#   plot()
# 
# object.size(admi) %>% 
#   format(units = "auto")
# 
# save(admi, file = here::here("data", "admi.rda"))
