#' map 시각화용 ggplot2 테마
#' 
#' @description 
#' 플롯팅할 지도를 위한 ggplot2 custom 테마
#' @details 완전히 비어 있는 테마인 theme_void()를 기반으로 생성
#' @param base_size numeric. pts로 주어진 기본 글꼴 크기.
#' @param base_family character. 기본 글꼴 패밀리. 기본값은 "NanumSquare".
#' @param base_line_size numeric. 선 요소의 기본 크기.
#' @param base_rect_size numeric. rect 요소의 기본 크기.
#' @param title_size numeric. 제목의 폰트 크기.
#' @param subtitle_size numeric. 부제목의 폰트 크기.
#' @param title_margin numeric. 부제목의 마진 크기.
#' @param subtitle_margin numeric. 부제목의 마진 크기.
#' @examples
#' \donttest{
#' ## 테마 적용 전
#' mega %>% 
#'   ggplot() +
#'   geom_sf(aes(fill = household), lwd = 0.3)
#' 
#' ## 테마 적용
#' mega %>% 
#'   ggplot() +
#'   geom_sf(aes(fill = household), lwd = 0.3) +
#'   theme_custom_map()
#' }
#' @export
#' @import ggplot2
theme_custom_map <- function(base_size = 11,
                             base_family = "NanumSquare",
                             base_line_size = base_size / 22,
                             base_rect_size = base_size / 22,
                             title_size = 16,
                             subtitle_size = 12,
                             title_margin = 7,
                             subtitle_margin = 5, ...) {
  theme_void(base_size = base_size,
             base_family = base_family,
             base_line_size = base_line_size) %+replace%
    theme(
      plot.title = element_text(
        hjust = 0, size = title_size, colour = "black",
        margin = margin(b = title_margin)),
      plot.subtitle = element_text(
        hjust = 0,
        size = subtitle_size, margin = margin(b = subtitle_margin)),
      complete = TRUE,
      ...
    )
}
