#' 최적 지도 이미지 사이즈 계산
#' 
#' @description 
#' 플롯팅할 지도의 종횡비를 고려하여, 최적의 지도 이미지 크기를 계산
#' 
#' @details 
#' sp객체나 sf 객체의 수치지도의 종횡비를 계산한 후, 지정한 너비(경도)나 높이(위도) 
#' 에 대응하는 최적의 높이나 너비의 크기를 계산합니다.
#' 
#' @param map sf 혹은 sp 객체. 계산한 지도 객체.
#' @param width numeric. 너비의 크기. 기본값은 800.
#' @param height numeric. 높이의 크기.
#' @return list. 높이와 너비의 크기.
#' 리스트의 성분은 다음과 같습니다.
#' \itemize{
#' \item width : 너비의 크기.
#' \item height : 높이의 크기.
#' }
#' @examples
#' \donttest{
#' optimal_map_size(mega)
#' optimal_map_size(mega, height = 600)
#' optimal_map_size(mega %>% filter(mega_nm %in% "서울특별시"))
#' }
#' @export
#' @importFrom tmaptools get_asp_ratio
#' 
optimal_map_size <- function(map, width = 800, height = NULL) {
  if (inherits(map, c("Spatial"))) {
    asp <- map %>%
      as("sf") %>%
      tmaptools::get_asp_ratio()
  } else if (inherits(map, c("sf"))) {
    asp <- tmaptools::get_asp_ratio(map)
  }
  
  if (is.null(width) && !is.null(height)) {
    width <- round(height * asp)
  } else if (is.null(height) && !is.null(width)) {
    height <- round(width / asp)
  }
  
  return(list(width = width, height = height))
}


#' 위도/경도로 행정구역 코드와 이름 가져오기
#' 
#' @description 
#' 경위도 좌표계 위치정보인 (경도, 위도) 위치 정보로 행정구역 정보를 구함
#' 
#' @param x numeric. 행정구역 정보를 얻을 경도
#' @param y numeric. 행정구역 정보를 얻을 위도
#' @param proj character. 위치정보의 좌표계 CRS 정보
#' @return data.frame. 행정구역 정보.
#' 데이터 프레임의 변수는 다음과 같습니다.
#' \itemize{
#' \item lon numeric. 경도.
#' \item lat numeric. 위도.
#' \item base_ym character. 경계 수치지도의 기준 년월.
#' \item mega_cd character. 광역시도 코드.
#' \item mega_nm character. 광역시도 이름.
#' \item cty_cd character. 시군구 코드.
#' \item cty_nm character. 시군구 이름.
#' \item admi_cd character. 읍면동 코드.
#' \item admi_nm character. 읍면동 이름.
#' }
#' 
#' @details proj에 사용할 수 있는 좌표계 CRS정보는 다음과 같습니다. 
#' 만약 다음 4개가 아닌 좌표계는 CRS 문자열을 기술해야 합니다.:
#' \itemize{
#' \item "WGS84" : WGS84 경위도 좌표계. (EPSG:4326)
#' \item "Bessel" : Bessel 1841 경위도. 한국과 일본에 잘 맞는 지역타원체를 사용한 좌표계.
#' \item "GRS80" : 통계청 통계지리정보서비스 좌표계(네이버지도에서 사용중인 좌표계). (EPSG:5179)
#' \item "KATECH" : KATECH 좌표계. 비표준 좌표계임.
#' }
#' @examples
#' \donttest{
#' x <- c(126.9691, 127.4926, 157.4926) 
#' y <- c(37.56825, 36.23795, 36.23795)
#' 
#' # 광역시도 정보 구하기
#' position2mega(x, y)
#' 
#' # 시군구 정보 구하기
#' position2cty(x, y)
#' 
#' # 읍면동 정보 구하기
#' position2admi(x, y)
#' 
#' x <- c(953116.3, 999335.1, 3728768.6) 
#' y <- c(1952231, 1804526, 2250492)
#' 
#' position2mega(x, y, proj = "GRS80")
#' }
#' @export
#' @import sf
#' @import dplyr
#' @importFrom purrr map_df
#' @importFrom tibble tibble
position2mega <- function(x, y, proj = c("WGS84", "Bessel", "GRS80", "KATECH")) {
  proj <- match.arg(proj)
  
  if (proj != "WGS84") {
    pos <- convert_projection(x, y, from = proj, to = "WGS84")
    
    x <- pos$lon
    y <- pos$lat
  }
    
  crsWGS84  <- 4326

  postions <- data.frame(lon = x, lat = y)
  
  # result <- postions %>% 
  #   st_as_sf(coords = c("lon", "lat")) %>% 
  #   st_set_crs(crsWGS84) %>% 
  #   st_intersects(mega) %>% 
  #   as.integer() %>% 
  #   mega[., ] %>% 
  #   select(base_ym:mega_nm) %>% 
  #   st_drop_geometry() 
  
  suppressWarnings(
    result <- postions %>%
      st_as_sf(coords = c("lon", "lat"), crs = crsWGS84) %>% 
      st_intersects(mega %>%
                      st_set_crs(crsWGS84)) %>%
      as.integer() %>%
      mega[., ] %>%
      select(mega_cd:mega_nm) %>%
      st_drop_geometry()
  )
  
  postions %>% 
    bind_cols(
      result
    )
}


#' @rdname position2mega
#' @name position2cty
#' @export
#' @import sf
#' @import dplyr
#' @importFrom purrr map_df
#' @importFrom tibble tibble
position2cty <- function(x, y, proj = c("WGS84", "Bessel", "GRS80", "KATECH")) {
  proj <- match.arg(proj)
  
  if (proj != "WGS84") {
    pos <- convert_projection(x, y, from = proj, to = "WGS84")
    
    x <- pos$lon
    y <- pos$lat
  }
  
  crsWGS84  <- 4326
  
  postions <- data.frame(lon = x, lat = y)
  
  # result <- postions %>% 
  #   st_as_sf(coords = c("lon", "lat")) %>% 
  #   st_set_crs(crsWGS84) %>% 
  #   st_intersects(cty) %>% 
  #   as.integer() %>% 
  #   cty[., ] %>% 
  #   select(base_ym:cty_nm) %>% 
  #   st_drop_geometry() 
    
  suppressWarnings(
    result <- postions %>%
      st_as_sf(coords = c("lon", "lat"), crs = crsWGS84) %>% 
      st_intersects(cty %>%
                      st_set_crs(crsWGS84)) %>%
      as.integer() %>%
      cty[., ] %>%
      select(mega_cd:cty_nm) %>%
      st_drop_geometry()
  )
  
  postions %>% 
    bind_cols(
      result
    )
}



#' @rdname position2mega
#' @name position2admi
#' @export
#' @import sf
#' @import dplyr
#' @importFrom purrr map_df
#' @importFrom tibble tibble
position2admi <- function(x, y, proj = c("WGS84", "Bessel", "GRS80", "KATECH")) {
  proj <- match.arg(proj)
  
  if (proj != "WGS84") {
    pos <- convert_projection(x, y, from = proj, to = "WGS84")
    
    x <- pos$lon
    y <- pos$lat
  }
  
  crsWGS84  <- 4326
  
  postions <- data.frame(lon = x, lat = y)
  
  # result <- postions %>% 
  #   st_as_sf(coords = c("lon", "lat")) %>% 
  #   st_set_crs(crsWGS84) %>% 
  #   st_intersects(admi) %>% 
  #   as.integer() %>% 
  #   admi[., ] %>% 
  #   select(base_ym:admi_nm) %>% 
  #   st_drop_geometry() 
  
  suppressWarnings(
    result <- postions %>%
      st_as_sf(coords = c("lon", "lat"), crs = crsWGS84) %>% 
      st_intersects(admi %>%
                      st_set_crs(crsWGS84)) %>%
      as.integer() %>%
      admi[., ] %>%
      select(mega_cd:admi_nm) %>%
      st_drop_geometry()
  )

  postions %>% 
    bind_cols(
      result
    )
}


#' 경위도 좌표계 위치정보의 좌표계 변환
#' 
#' @description 
#' 경위도 좌표계 위치정보인 (경도, 위도) 위치 정보를 다른 좌표계의 값으로 변환
#' 
#' @param x numeric. 변환할 위치 경도
#' @param y numeric. 변환할 위치 위도
#' @param from character. 변경 전의 좌표계 CRS 정보
#' @param to character. 변경 후의 좌표계 CRS 정보
#' @return data.frame. 변경 전후의 경도, 위도 정보.
#' 데이터 프레임의 변수는 다음과 같습니다.
#' \itemize{
#' \item x numeric. 변경 전의 경도
#' \item y numeric. 변경 전의 위도
#' \item lon numeric. 변경 후의 경도
#' \item lat numeric. 변경 후의 위도
#' }
#' 
#' @details from과 to에 사용할 수 있는 좌표계 CRS정보는 다음과 같습니다. 
#' 만약 다음 4개가 아닌 좌표계는 CRS 문자열을 기술해야 합니다.:
#' \itemize{
#' \item "WGS84" : WGS84 경위도 좌표계. (EPSG:4326)
#' \item "Bessel" : Bessel 1841 경위도. 한국과 일본에 잘 맞는 지역타원체를 사용한 좌표계.
#' \item "GRS80" : 통계청 통계지리정보서비스 좌표계(네이버지도에서 사용중인 좌표계). (EPSG:5179)
#' \item "KATECH" : KATECH 좌표계. 비표준 좌표계임.
#' }
#' @examples
#' \donttest{
#' x <- c(126.9691, 127.4926) 
#' y <- c(37.56825, 36.23795)
#' 
#' convert_projection(x, y, from = "WGS84", to = "GRS80")
#'
#' x <- c(953116.3, 999335.1) 
#' y <- c(1952231, 1804526) 
#' convert_projection(x, y, from = "GRS80", to = "WGS84")
#' }
#' @export
#' @import sf
convert_projection <- function(x, y, from = c("WGS84", "Bessel", "GRS80", "KATECH")[3],
                               to = c("WGS84", "Bessel", "GRS80", "KATECH")) {
  # WGS84 경위도 좌표계 : EPSG:4326
  projWGS84 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
  crsWGS84  <- 4326
  
  # Bessel 1841 경위도: 한국과 일본에 잘 맞는 지역타원체를 사용한 좌표계
  projBessel <- "+proj=longlat +ellps=bessel +no_defs +towgs84=-115.80,474.99,674.11,1.16,-2.31,-1.63,6.43"
  crsBessel  <- 4162
  
  # Korea 2000 / Unified CS: 통계청 통계지리정보서비스 좌표계(네이버지도에서 사용중인 좌표계) (EPSG:5179)
  projGRS80 <- "+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +units=m +no_defs"
  crsGRS80  <- 5179
  
  # KATECH 좌표계
  projKATECH <- "+proj=tmerc +lat_0=38 +lon_0=128 +k=0.9999 +x_0=400000 +y_0=600000 +ellps=bessel +units=m +no_defs +towgs84=-115.80,474.99,674.11,1.16,-2.31,-1.63,6.43"
  crsKATECH  <- NA 
  
  from_crs <- case_when(
    from %in% "WGS84" ~ projWGS84,
    from %in% "Bessel" ~ projBessel,
    from %in% "GRS80" ~ projGRS80,
    from %in% "KATECH" ~ projKATECH,
    TRUE ~ from
  )

  to <- match.arg(to)
  
  to_crs <- case_when(
    to %in% "WGS84" ~ projWGS84,
    to %in% "Bessel" ~ projBessel,
    to %in% "GRS80" ~ projGRS80,
    to %in% "KATECH" ~ projKATECH,
    TRUE ~ to    
  )
  
  xy <- data.frame(x = x, y = y)
  
  xy_convert <- xy %>% 
    st_as_sf(coords = c("x", "y")) %>% 
    st_set_crs(from_crs) %>% 
    st_transform(to_crs) %>% 
    st_coordinates() %>% 
    as.data.frame()
  
  names(xy_convert) <- c("lon", "lat")
  
  xy %>% 
    bind_cols(
      xy_convert
    )
}


#' 두 좌표의 거리 구하기
#' 
#' @description 좌표계에서 위도, 경도로 이루어진 두 지점간의 거리를 구함
#' 
#' @param lon1 numeric. 첫 좌표의 경도. 
#' @param lat1 numeric. 첫 좌표의 위도. 
#' @param lon2 numeric. 둘째 좌표의 경도. 
#' @param lat2 numeric. 둘째 좌표의 위도. 
#' @param proj character. 좌표계 CRS 정보.
#' 
#' @return numeric. 두 점 간의 거리. 미터(m) 단위의 거리.
#' @details proj에 사용할 수 있는 좌표계 CRS정보는 다음과 같습니다. 
#' 만약 다음 4개가 아닌 좌표계는 CRS 문자열을 기술해야 합니다.:
#' \itemize{
#' \item "WGS84" : WGS84 경위도 좌표계. (EPSG:4326)
#' \item "Bessel" : Bessel 1841 경위도. 한국과 일본에 잘 맞는 지역타원체를 사용한 좌표계.
#' \item "GRS80" : 통계청 통계지리정보서비스 좌표계(네이버지도에서 사용중인 좌표계). (EPSG:5179)
#' \item "KATECH" : KATECH 좌표계. 비표준 좌표계임.
#' }
#' 
#' @examples
#' calc_distance(132.12, 37.23, 133.45, 37.32)
#' 
#' @export
#' @import dplyr
#' @import sf
calc_distance <- function(lon1, lat1, lon2, lat2, 
                          proj = c("WGS84", "Bessel", "GRS80", "KATECH")) {
  # WGS84 경위도 좌표계 : EPSG:4326
  projWGS84 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
  crsWGS84  <- 4326
  
  # Bessel 1841 경위도: 한국과 일본에 잘 맞는 지역타원체를 사용한 좌표계
  projBessel <- "+proj=longlat +ellps=bessel +no_defs +towgs84=-115.80,474.99,674.11,1.16,-2.31,-1.63,6.43"
  crsBessel  <- 4162
  
  # Korea 2000 / Unified CS: 통계청 통계지리정보서비스 좌표계(네이버지도에서 사용중인 좌표계) (EPSG:5179)
  projGRS80 <- "+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +units=m +no_defs"
  crsGRS80  <- 5179
  
  # KATECH 좌표계
  projKATECH <- "+proj=tmerc +lat_0=38 +lon_0=128 +k=0.9999 +x_0=400000 +y_0=600000 +ellps=bessel +units=m +no_defs +towgs84=-115.80,474.99,674.11,1.16,-2.31,-1.63,6.43"
  crsKATECH  <- NA 
  
  proj <- match.arg(proj)
  
  crs <- case_when(
    proj %in% "WGS84" ~ projWGS84,
    proj %in% "Bessel" ~ projBessel,
    proj %in% "GRS80" ~ projGRS80,
    proj %in% "KATECH" ~ projKATECH,
    TRUE ~ proj    
  )
  
  xy <- data.frame(x = lon1, y = lat1)
  
  pos_1 <- xy %>% 
    st_as_sf(coords = c("x", "y")) %>% 
    st_set_crs(crs) 
  
  xy <- data.frame(x = lon2, y = lat2)
  
  pos_2 <- xy %>% 
    st_as_sf(coords = c("x", "y")) %>% 
    st_set_crs(crs)   
  
  suppressWarnings(
    st_distance(pos_1, pos_2, by_element = TRUE) %>% 
      as.numeric()
  )
}

