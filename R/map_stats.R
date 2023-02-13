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
#'   \item{pharmacy_cnt}{numeric. 약국갯수.} 
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



#' 제공 통계정보
#' 
#' @description 
#' 행정구역 경계 수치지도 데이터와 함께 제공되는 공공데이터 집계 정보
#' 
#' @details 
#' 행정구역 경계 수치지도 데이터인 mega, cty, admi의 데이터 컬럼에 포함된 통계의  
#' 정보를 담고 있는 데이터임.
#' 
#' @format 3개의 변수를 담은 data.frame 클래스 객체.
#' \describe{
#'   \item{stats_id}{character. 통계 아이디.}
#'   \item{stats_nm}{character. 통계 이름.}
#'   \item{is_use}{logical. 사용여부. TRUE이면 사용할 수 있는 통계 정보이며, 
#'   FALSE이면 관리되지 않는 통계 정보로 사용할 수 없음을 의미함} 
#' }
#' @docType data
#' @keywords datasets
#' @name stats_info
#' @usage data(stats_info)
NULL


#' 우편번호 행정동 매핑 데이터
#' 
#' @description 
#' 우편번호로 광역시도 > 시군구 > 읍면동을 매핑하기 위한 메타 데이터
#' 
#' @details 
#' 이 데이터셋은 우편번호 데이터로 읍면동 레벨까지의 행정구역을 매핑하기 위해서 
#' 제작된 데이터셋으로, 모든 우편번호를 포함하지 않음. 그 이유는 우편번호만으로 
#' 행정동 기준은 읍면동 레벨까지 매핑시킬 수 없는 구조이기 때문임. 
#' 그래서 우편번호로 광역시도 > 시군구 > 읍면동을 매핑할 수 있는 사례만 발췌한 것임.
#' 
#' @format 8개의 변수, 29,241건을 담은 tbl_df 클래스 객체.
#' \describe{
#'   \item{post_cd}{character. 도로명 주소 우편번호}
#'   \item{base_ym}{character. 기준월도.}
#'   \item{mega_cd}{character. 광역시도 코드.}
#'   \item{mega_nm}{character. 광역시도 이름.}
#'   \item{cty_cd}{character. 시군구 코드.}
#'   \item{cty_nm}{character. 시군구 이름.}
#'   \item{admi_cd}{character. 읍면동 코드.}
#'   \item{admi_nm}{character. 읍면동 이름.}
#' }
#' @docType data
#' @keywords datasets
#' @name post_admi
#' @usage data(post_admi)
#' @source 
#' "주소기반산업지원서비스 사이트의 도로명주소 한글" in <https://business.juso.go.kr/addrlink/attrbDBDwld/attrbDBDwldList.do?cPath=99MD&menu=도로명주소+한글>.
NULL


#' 약국 위치 정보
#' 
#' @description 
#' 건강보험심사평가원에서 제공하는 약국 위치 정보
#' 
#' @details 
#' 이 데이터셋은 개별 약국의 위치정보 데이터로 병원 건물 위치의 경도/위도 정보를 
#' 포함하고 있음. 일부 위치를 제공하지 않는 약국의 경우는 약국이 위치한 읍면동의
#' 기하학적 중심의 좌표로 대체하였음. 
#' 
#' @format 15개의 변수, 24,364건을 담은 tbl_df 클래스 객체.
#' \describe{
#'   \item{pharmacy_nm}{character. 약국이름.}
#'   \item{class_cd}{character. 종별코드.}
#'   \item{class_nm}{character. 종별이름.}
#'   \item{post_cd}{character. 도로명 우편번호.}
#'   \item{address}{character. 도로명 주소.}
#'   \item{open_date}{character. 개업일자.}
#'   \item{lon}{numeric. 위치정보, 경도.}
#'   \item{lat}{numeric. 위치정보, 위도.}
#'   \item{base_ym}{character. 기준월도.}
#'   \item{mega_cd}{character. 광역시도 코드.}
#'   \item{mega_nm}{character. 광역시도 이름.}
#'   \item{cty_cd}{character. 시군구 코드.}
#'   \item{cty_nm}{character. 시군구 이름.}
#'   \item{admi_cd}{character. 읍면동 코드.}
#'   \item{admi_nm}{character. 읍면동 이름.}
#' }
#' @docType data
#' @keywords datasets
#' @name post_admi
#' @usage data(post_admi)
#' @source 
#' "공공데이터 포털의 건강보험심사평가원_전국 병의원 및 약국 현황" in <https://www.data.go.kr/data/15051059/fileData.do>.
NULL


