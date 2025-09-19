## ----environment, echo = FALSE, message = FALSE, warning=FALSE----------------
knitr::opts_chunk$set(collapse = TRUE, comment = "", out.width = "600px", dpi = 70)
options(tibble.print_min = 4L, tibble.print_max = 4L)

## ----echo=FALSE, out.width = "85%", fig.align='center', fig.cap="소스: http://nationalatlas.ngii.go.kr/pages/page_1217.php"----
knitr::include_graphics("img/kor_hi_54-2.jpg")

## ----echo=FALSE, out.width = "85%", fig.align='center', fig.cap="소스: http://nationalatlas.ngii.go.kr/pages/page_1217.php"----
knitr::include_graphics("img/kor_hi_54-1.jpg")

## ----eval=FALSE---------------------------------------------------------------
#  thematic_map(
#    zoom = c("mega", "cty", "admi")[1],
#    subset = NULL,
#    stat = NULL,
#    polygon = TRUE,
#    point = FALSE,
#    label = NULL,
#    col_cnt = 9,
#    palette = "YlOrRd",
#    line_col = "darkgray",
#    fill = "lightblue",
#    point_col = "blue",
#    title = NULL,
#    subtitle = NULL,
#    legend_pos = c("none", "right", "left", "bottom", "top"),
#    base_family = "NanumSquare"
#  )

## ----warning=FALSE, message=FALSE, fig.height=7.48, fig.width=9.5, fig.align='center'----
library(bitSpatial)

thematic_map(stat = "인구수", 
             title = "광역시도별 인구분포 현황",
             legend_pos = "right")

## ----warning=FALSE, fig.height=7.48, fig.width=8, fig.align='center'----------
thematic_map(zoom = "cty",
             stat = "병원수", 
             title = "시군구별 병원수 현황",
             palette = "Blues")

## ----warning=FALSE, fig.height=4.3, fig.width=8, fig.align='center'-----------
thematic_map(zoom = "cty",
             stat = "병원수", 
             subset = mega_nm %in% c("서울특별시", "경기도", "인천광역시"),
             title = "시군구별 병원수 현황",
             subtitle = "수도권 지역 (서울특별시, 경기도, 인천광역시)",
             palette = "Blues")

## ----warning=FALSE, fig.height=7.1, fig.width=8, fig.align='center'-----------
thematic_map(zoom = "admi", 
             subset = mega_nm == "서울특별시" & cty_nm %in% "양천구", 
             stat = "age_mean", 
             label = "name",
             title = "서울 양천구 인구통계 주제도",
             subtitle = "동별 평균 연령 현황", 
             palette = "Purples",
             legend_pos = "right")

## ----warning=FALSE, fig.height=8.7, fig.width=6, fig.align='center'-----------
thematic_map(zoom = "admi",
             subset = cty_nm %in% "노원구",
             stat = "household", 
             polygon = FALSE, 
             point = TRUE, point_col = "Red",
             label = "name",
             line_col = "black", fill = "grey90",
             title = "서울특별시 가구 분포",
             subtitle = "노원구 동별 가구현황")

## -----------------------------------------------------------------------------
stats_info

## ----warning=FALSE, fig.height=7.1, fig.width=8, fig.align='center'-----------
pos_school <- school |>  
  filter(mega_nm %in% "서울특별시") |> 
  filter(school_class %in% "초등학교") |> 
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

ggplot() +
  stat_density_2d(data = pos_school, 
                  mapping = aes(x = purrr::map_dbl(geometry, ~.[1]),
                                y = purrr::map_dbl(geometry, ~.[2]),
                                fill = after_stat(density)),
                  geom = 'tile',
                  contour = FALSE,
                  alpha = 0.7) +
  scale_fill_viridis_c(option = "viridis", direction = -1) +
  geom_sf(data = cty |> 
            filter(mega_nm %in% "서울특별시"),
          color = "grey30", fill = NA, linewidth = 0.8) +
  geom_sf(data = pos_school, color = "blue", size = 0.5) +  
  xlim(126.75, 127.22) + 
  ylim(37.42, 37.71) + 
  labs(title = "서울특별시 초등학교 분포 현황",
       subtitle = "출처: 공공데이터포털의 전국 초중등학교 위치 표준데이터") +
  theme_custom_map()

