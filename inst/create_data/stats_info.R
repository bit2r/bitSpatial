stats_id <- bitSpatial::mega %>% 
  select(-c(1:3)) %>% 
  names() %>% 
  setdiff(c("geometry"))

stats_nm <- c(
  "면적",
  "인구수",
  "가구수",
  "가구당인구수",
  "남성인구수",
  "여성인구수",
  "여성대비남성인구",
  "남성평균연령",
  "여성평균연령",
  "평균연령",
  "초등학교수",
  "중학교수",
  "고등학교수"
)  

is_use <- rep(TRUE, length(stats_id))
  
stats_info <-
  data.frame(
    stats_id = stats_id,
    stats_nm = stats_nm,
    is_use = is_use  
  )

save(stats_info, file = here::here("data", "stats_info.rda"))
