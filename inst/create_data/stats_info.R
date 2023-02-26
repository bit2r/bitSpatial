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
  "고등학교수",
  "약국수",
  "총의료기관수",
  "총의사수",
  "병원수",
  "보건소수",
  "보건지소수",
  "보건진료소수",
  "상급종합병원수",
  "요양병원수",
  "의원수",
  "정신병원수",
  "조산원수",
  "종합병원수",
  "치과병원수",
  "치과의원수",
  "한방병원수",
  "한의원수",
  "관광여가오락업체수",
  "부동산업체수",
  "생활서비스업체수",
  "소매업체수",
  "숙박업체수",
  "스포츠업체수",
  "음식업체수",
  "학문교육업체수"  
)  

is_use <- rep(TRUE, length(stats_id))
  
stats_info <-
  data.frame(
    stats_id = stats_id,
    stats_nm = stats_nm,
    is_use = is_use  
  )

save(stats_info, file = here::here("data", "stats_info.rda"))
