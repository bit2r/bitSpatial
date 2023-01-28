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
