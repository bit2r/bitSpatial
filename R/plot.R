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


#' 주제도 시각화
#' @description 패키지에 포함된 통계 데이터로 여러 포맷의 주제도를 시각화함  
#' @param zoom character. "mega", "cty", "admi"는 각각 광역시도,
#'  시군구, 읍면동 레벨의 주제도를 지정함. 기본값은 "mega"로 광역시도 지도 정보를 가져옴.
#' @param subset expression. 지도에서 일부 영역을 표현할 조건.
#' @param stat character. 주제도에서 표현할 통계의 종류 영문 이름이나 한글 이름. See details.
#' @param polygon logical. 다각형 영역에 heatmap을 표현할지의 여부. 
#' 기본값은 TRUE. stat 인수를 사용할 경우에만 허용됨.
#' @param point logical. 다각형 영역에 산점도 표현할지의 여부. 
#' 기본값은 FALSE. stat 인수를 사용할 경우에만 허용됨.
#' @param label character. 다각형 영역에 범례 라벨을 출력하는 방법을 설정함.
#' 기본값은 NULL로 라벨을 출력하지 않음. "name"은 행정구역의 이름을, 
#' "value"는 통계값을 라벨링함. "all"은 행정구역 이름과 통계값을 라벨링함.
#' @param col_cnt numeric. 주제도에서 표현할 색상 크라데이션의 개수.
#' @param palette character. 주제도에서 표현할 색상 팔레트 이름.
#' @param line_col character. 지도의 경계를 채울 색상을 지정함. 기본값은 "darkgray".
#' @param point_col character. 통계의 크기를 표현할 포인트를 채울 색상을 지정함. 
#' 기본값은 "blue".
#' @param fill character. 지도의 다각형 내부를 채울 색상을 지정함. stat 인수의
#'  값을 지정하지 않을 경우에만 적용됨. 기본값은 "lightblue".
#' @param title character. 메인 타이틀.
#' @param subtitle character. 서브 타이틀.
#' @param legend_pos character. 주제도의 범례를 출력할 위치로 stat 인수를 지정할 
#' 경우에만 효력이 있음. 이 인수를 지정하지 않으면 범례를 출력하지 않음. 
#' "none", "left", "right", "bottom", "top"에서 선택.
#' @param base_family character. 주제도에 출력할 문자 폰트 패밀리. 
#' 기본값은 나눔스퀘어 폰트인 "NanumSquare"이며, 온라인 환경에서는 본고딕인 
#' "Noto Sans Korean"을 지정할 수 있음.
#' @details
#' 통계의 종류는 stats_info 데이터 프레임에 13개가 정의되어 있음.
#' 이중 stats_id나 stats_nm 변수를 stat 인수에 사용해야 함.
#' @seealso \code{\link{mega}}, \code{\link{cty}}, \code{\link{admi}}, 
#' \code{\link{stats_info}}, \code{\link{brewer.pal}}
#' @examples
#' \dontrun{
#' # 광역시도 인구분포 주제도 그리기 - 통계 영문 이름을 적용
#' thematic_map(stat = "population")
#' 
#' # 광역시도 인구분포 주제도 그리기 - 통계 이름을 적용
#' thematic_map(stat = "인구수")
#' 
#' # 포인트 추가 및 "Blues" 팔레트 적용
#' thematic_map(stat = "household", point = TRUE, palette = "Blues")
#' 
#' # 시군구 레벨 서울특별시 가구대비인구수, 범례 추가
#' thematic_map(zoom = "cty", subset = mega_nm == "서울특별시", stat = "pop_per_hosue", 
#'              point = TRUE, polygon = FALSE, legend_pos = "bottom")
#'              
#' # 초등학교 개수지만 통계량이 출력되지 않음
#' thematic_map(stat = "elemnt_schl_cnt", point = FALSE, polygon = FALSE)
#' 
#' # 서울 양천구의 평균인구, 이름 라벨 및 범례 추가
#' thematic_map(zoom = "admi", subset = mega_nm == "서울특별시" & cty_nm %in% "양천구", 
#'              stat = "age_mean", label = "name", legend_pos = "right")
#'              
#' # 서울 양천구의 평균인구, 값 라벨 및 범례 제거
#' thematic_map(zoom = "admi", subset = mega_nm == "서울특별시" & cty_nm %in% "양천구", 
#'              stat = "age_mean", label = "value", legend_pos = "none")
#'              
#' # 인구통계의 이름과 값 라벨 추가
#' thematic_map(stat = "population", zoom = "admi", 
#'              subset = mega_nm == "서울특별시" & cty_nm %in% "양천구", label = "all")
#'              
#' # 지역코드로 서울시 시각화
#' thematic_map(subset = mega_cd == 11)
#' 
#' # 지역코드로 서울시와 경기도 시각화
#' thematic_map(subset = mega_cd %in% c("11", "41"))
#' 
#' # 지역이름으로 수도권 가구수 시각화 
#' thematic_map(zoom = "cty", stat = "household", 
#'              subset = mega_nm %in% c("서울특별시", "인천광역시", "경기도"))
#' }
#' @export
#' @import dplyr
#' @import ggplot2
#' @importFrom  rlang sym enquo
#' @importFrom classInt classIntervals
thematic_map <- function(
    zoom = c("mega", "cty", "admi")[1], subset = NULL, stat = NULL, 
    polygon = TRUE, point = FALSE, label = NULL, col_cnt = 9, palette = "YlOrRd", 
    line_col = "darkgray", fill = "lightblue", point_col = "blue", title = NULL, 
    subtitle = NULL, legend_pos = c("none", "right", "left", "bottom", "top"),
    base_family = "NanumSquare")
{
  legend_pos <- match.arg(legend_pos)
  
  map_df <- eval(get(zoom))
  
  if (!missing(subset)) {
    map_df <- map_df %>% 
      filter(!!rlang::enquo(subset))
  }
  
  if (is.null(stat) | (!stat %in% names(map_df) & !stat %in% stats_info$stats_nm)) {
    p <- map_df %>%
      ggplot() +
      geom_sf(fill = fill, color = line_col)
  } else {
    if (stat %in% stats_info$stats_nm) {
      stat_nm <- stat      
      stat <- stats_info[stats_info$stats_nm %in% stat, "stats_id"]
    } else {
      stat_nm <- stats_info[stats_info$stats_id %in% stat, "stats_nm"]
    }
    
    stats <- map_df[, stat] %>%
      st_drop_geometry() %>%
      pull()
    
    suppressWarnings({
      stats2 <- c(min(stats) - .00001, stats)
      
      brks <- classInt::classIntervals(stats2, n = col_cnt, style = "pretty")$brks
      
      if (length(brks) > col_cnt) {
        brks <- classInt::classIntervals(stats2, n = col_cnt, style = "quantile")
        # legend binning 오류(#35) 수정
        # brks <- unique(round(brks$brks))
        brks_min <-  floor(brks$brks[1])
        brks_max <-  ceiling(brks$brks[length(brks$brks)])
        brks_mid <-  round(brks$brks[2:length(brks$brks)-1])
        brks <- unique(c(brks_min, brks_mid, brks_max))
      }         
    })
    
    map_df <- map_df %>%
      mutate(statists = !!rlang::sym(stat)) %>%
      mutate(binn_stat = cut(statists, brks, include.lowest = TRUE, dig.lab = 20) )
    
    if (!is.null(label)) {
      name <- paste0(zoom, "_nm")
      
      name <- map_df[, name] %>%
        st_drop_geometry() %>%
        pull()
    
      statists <- format(stats, big.mark  = ",")
      
      if (label %in% "name") {
        map_df <- map_df %>%
          mutate(label_string = name)
      } else if (label %in% "value") {
        map_df <- map_df %>%
          mutate(label_string = statists)       
      } else if (label %in% "all") {
        all_str <- paste(name, statists, sep = "\n")
        
        map_df <- map_df %>%
          mutate(label_string = all_str)
      }  
    }
    
    p <- map_df %>%
      ggplot() +
      geom_sf(fill = fill, color = line_col)
    
    if (polygon) {
      p <- p +
        geom_sf(aes(fill = binn_stat), color = line_col) +
        scale_fill_brewer(palette = palette)
    }
    
    if (point) {
      p <- p +
        geom_point(aes(size = statists, geometry = geometry),
                   stat = "sf_coordinates", color = point_col)        
    }
    
    if (!is.null(label)) {
      p <- p +
        ggrepel ::geom_label_repel(
          aes(label = label_string, geometry = geometry),
          stat = "sf_coordinates",
          family = base_family)
    }
  }
  
  p <- p +
    labs(title = title, subtitle = subtitle, fill = stat_nm, size = stat_nm) +
    theme_custom_map(base_family = base_family)
  
  if (!is.null(stat) & length(stat %in% names(map_df)) > 0) {
    p <- p +
      theme(legend.position = legend_pos)
  }
  
  p
}



