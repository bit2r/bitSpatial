#' 광역시도, 시군구, 읍면동 수치지도 및 통계
#' 
#' @description 
#' sf 클래스 객체로 만들어진 광역시도(mega), 시군구(cty), 읍면동(admi) 레벨의 수치지도 및 관련 통계 
#' 
#' @details 
#' sf 클래스 객체로 만들어진 데이터로서 2022년 6월 기준의 데이터입니다. 
#' 읍면동 레벨의 데이터는 상위 시군구, 광역시도 정보를 포함하며, 
#' 시군구 레벨의 데이터는 상위 광역시도 정보를 포함합니다.
#' 
#' @format 기준일자, 6개의 행정구역 코드 및 값과 개별 통계정보를 담은 sf 클래스 객체.
#' \describe{
#'   \item{base_ym}{character. 기준월도.}
#'   \item{mega_cd}{character. 광역시도 코드.}
#'   \item{mega_nm}{character. 광역시도 이름.}
#'   \item{cty_cd}{character. 시군구 코드.}
#'   \item{cty_nm}{character. 시군구 이름.}
#'   \item{admi_cd}{character. 읍면동 코드.}
#'   \item{admi_nm}{character. 읍면동 이름.}
#'   \item{land_area}{numeric. 면적(km^2).}
#'   \item{population}{numeric. 인구수.}
#'   \item{household}{numeric. 가구수.}
#'   \item{pop_per_hosue}{numeric. 가구당 인구수.}
#'   \item{pop_male}{numeric. 남성 인구수.}
#'   \item{pop_female}{numeric. 여성 인구수.}
#'   \item{male_per_female}{numeric. 여성대비 남성수.} 
#'   \item{age_mean_male}{numeric. 남성 평균연령.}
#'   \item{age_mean_female}{numeric. 여성 평균연령.}
#'   \item{age_mean}{numeric. 평균연령.} 
#'   \item{elemnt_schl_cnt}{numeric. 초등학교갯수.} 
#'   \item{mdle_schl_cnt}{numeric. 중학교갯수.} 
#'   \item{high_schl_cnt}{numeric. 고등학교갯수.} 
#'   \item{geometry}{MULTIPOLYGON. 지도 polygons.}
#' }
#' @docType data
#' @keywords datasets
#' @name mega
#' @usage data(mega)
#' @source 
#' "통계청 통계지리정보서비스" in <https://sgis.kostat.go.kr>, License : 공공저작물 자유이용허락 표시기준(공공누리, KOGL) 제 1유형
#' "주민등록 인구통계" in <https://jumin.mois.go.kr/index.jsp>.
NULL


#' @rdname mega
#' @name cty
#' @usage data(cty)
NULL


#' @rdname mega
#' @name admi
#' @usage data(admi)
NULL


#' 광역시도, 시군구, 읍면동 성별 연령대별 인구수
#' 
#' @description 
#' 광역시도(mega), 시군구(cty), 읍면동(admi) 레벨의 성별 연령대별 인구 통계 
#' 
#' @details 
#' tibble 클래스 객체로 만들어진 데이터로서 2022년 6월 기준의 데이터입니다. 
#' 읍면동 레벨의 데이터는 상위 시군구, 광역시도 정보를 포함하며, 
#' 시군구 레벨의 데이터는 상위 광역시도 정보를 포함합니다.
#' 
#' @format 기준일자, 6개의 행정구역 코드 및 값과 개별 통계정보를 담은 tibble 클래스 객체.
#' \describe{
#'   \item{base_ym}{character. 기준월도.}
#'   \item{mega_cd}{character. 광역시도 코드.}
#'   \item{mega_nm}{character. 광역시도 이름.}
#'   \item{cty_cd}{character. 시군구 코드.}
#'   \item{cty_nm}{character. 시군구 이름.}
#'   \item{admi_cd}{character. 읍면동 코드.}
#'   \item{admi_nm}{character. 읍면동 이름.}
#'   \item{age_group}{character. 5세 단위의 연령그룹.}
#'   \item{gender}{character. 성별.}
#'   \item{population}{numeric. 인구수.}
#' }
#' @docType data
#' @keywords datasets
#' @name mega_population_age
#' @usage data(mega_population_age)
#' @source 
#' "주민등록 인구통계" in <https://jumin.mois.go.kr/index.jsp>.
NULL


#' @rdname mega_population_age
#' @name cty_population_age
#' @usage data(cty_population_age)
NULL


#' @rdname mega_population_age
#' @name admi_population_age
#' @usage data(admi_population_age)
NULL



#' 전국 초중등학교 위치 표준 데이터
#' 
#' @description 
#' 초중등교육법에 따라 설립 승인을 받아 운영하는 초등학교, 중학교, 고등학교의 소재지 정보
#' 
#' @details 
#' tibble 클래스 객체로 만들어진 데이터로서 2022년 9월 21일 기준의 데이터입니다. 
#' 학교 위치정보와 속성, 행정구역 코드 매핑 정보 등이 포함되어 있습니다.
#' 
#' @format 기준일자, 6개의 행정구역 코드 및 값과 개별 통계정보를 담은 tibble 클래스 객체.
#' \describe{
#'   \item{school_id}{character. 학교 ID.}
#'   \item{school_nm}{character. 학교 이름.}
#'   \item{school_class}{character. 학교 급구분.} 
#'   \item{estab_date}{character. 설립 일자.} 
#'   \item{estab_class}{character. 설립 형태.} 
#'   \item{branch_cd}{character. 본교분교 구분.} 
#'   \item{operate_stat}{character. 운영 상태.} 
#'   \item{addr_land}{character. 소재지 지번 주소.} 
#'   \item{addr_road}{character. 소재지 도로명 주소.} 
#'   \item{edu_office_cd}{character. 시도 교육청 코드.} 
#'   \item{edu_office_nm}{character. 시도 교육청 이름.} 
#'   \item{edu_support_cd}{character. 교육지원청 코드.} 
#'   \item{edu_support_nm}{character. 교육지원청 이름.} 
#'   \item{lat}{numeric. 위도.}
#'   \item{lon}{numeric. 경도.}
#'   \item{base_date}{character. 기준일자.}
#'   \item{mega_cd}{character. 광역시도 코드.}
#'   \item{mega_nm}{character. 광역시도 이름.}
#'   \item{cty_cd}{character. 시군구 코드.}
#'   \item{cty_nm}{character. 시군구 이름.}
#'   \item{admi_cd}{character. 읍면동 코드.}
#'   \item{admi_nm}{character. 읍면동 이름.}
#' }
#' @docType data
#' @keywords datasets
#' @name school
#' @usage data(school)
#' @source 
#' 공공데이터포털의 "전국초중등학교위치표준데이터" in <https://www.data.go.kr/data/15021148/standard.do?recommendDataYn=Y>.
NULL
