% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_stats.R
\docType{data}
\name{hospital_info}
\alias{hospital_info}
\title{병원 위치 정보}
\format{
29개의 변수, 76,032건을 담은 tbl_df 클래스 객체.
\describe{
  \item{hospital_nm}{character. 병원이름.}
  \item{class_cd}{character. 종별코드.}
  \item{class_nm}{character. 종별이름.}
  \item{post_cd}{character. 도로명 우편번호.}
  \item{address}{character. 도로명 주소.}
  \item{open_date}{character. 개업일자.}
  \item{doctor_cnt}{numeric. 총의사수.}
  \item{medical_gp_cnt}{numeric. 의과일반의 인원수.}
  \item{medical_intern_cnt}{numeric. 의과인턴 인원수.}
  \item{medical_residency_cnt}{numeric. 의과레지던트 인원수.}
  \item{medical_specialist_cnt}{numeric. 의과전문의 인원수.}
  \item{dental_gp_cnt}{numeric. 치과일반의 인원수.}
  \item{dental_intern_cnt}{numeric. 치과인턴 인원수.}
  \item{dental_residency_cnt}{numeric. 치과레지던트 인원수.}
  \item{dental_specialist_cnt}{numeric. 치과전문의 인원수.}
  \item{kmedicine_gp_cnt}{numeric. 한방일반의 인원수.}
  \item{kmedicine_intern_cnt}{numeric. 한방인턴 인원수.}
  \item{kmedicine_residency_cnt}{numeric. 한방레지던트 인원수.} 
  \item{kmedicine_specialist_cnt}{numeric. 한방전문의 인원수.} 
  \item{lon}{numeric. 위치정보, 경도.}
  \item{lat}{numeric. 위치정보, 위도.}
  \item{base_ym}{character. 기준월도.}
  \item{mega_cd}{character. 광역시도 코드.}
  \item{mega_nm}{character. 광역시도 이름.}
  \item{cty_cd}{character. 시군구 코드.}
  \item{cty_nm}{character. 시군구 이름.}
  \item{admi_cd}{character. 읍면동 코드.}
  \item{admi_nm}{character. 읍면동 이름.}
}
}
\source{
"공공데이터 포털의 건강보험심사평가원_전국 병의원 및 약국 현황" in <https://www.data.go.kr/data/15051059/fileData.do>.
}
\usage{
data(hospital_info)
}
\description{
건강보험심사평가원에서 제공하는 병원 위치 정보
}
\details{
이 데이터셋은 개별 병원의 위치정보 데이터로 병원 건물 위치의 경도/위도 정보를 
포함하고 있음. 일부 위치를 제공하지 않는 병원의 경우는 병원이 위치한 읍면동의
기하학적 중심의 좌표로 대체하였음.
}
\keyword{datasets}
