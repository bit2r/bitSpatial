# bitSpatial 0.2.7.9000

## MAJOR CHANGES

* 통계청 통계지리정보서비스 최신 버전 (#33).
    - 2022-06 -> 2023-06 
    - 광역시도 레벨: mega
    - 시군구 레벨: cty
    - 읍면동 레벨: admi

* 통계정보 업데이트 (#33).
    - 도로명 주소
        - 주소기반산업지원서비스 > 공개하는 주소 > 도로명주소 한글 > 전체자료
        -  2022-06 -> 2023-06
        - post_admi
    - 주민등록인구 및 세대현황
        - 행정안전부 > 주민등록 인구통계 > 주민등록 인구 및 세대현황
        -  2022-06 -> 2023-06
    - 연령별 인구현황 (5세 단위)
        - 행정안전부 > 주민등록 인구통계 > 연령별 인구현황
        -  2022-06 -> 2023-06
    - 평균연령
        - 행정안전부 > 주민등록 인구통계 > 주민등록 인구 기타현황 > 지역별 평균연령
        -  2022-06 -> 2023-06
    - 전국 초중등학교 위치 표준 데이터
        - 공공데이터포털 > 전국초중등학교위치표준데이터
        -  기준: 2024-03
        - 위치데이터 
            - school
    - 전국 약국 위치 데이터
        - 공공데이터포털 > 건강보험심사평가원_전국 병의원 및 약국 현황
        -  기준: 2024-03
        - 위치데이터 
            - pharmacy_info
    - 전국 병원 위치 데이터
        - 공공데이터포털 > 건강보험심사평가원_전국 병의원 및 약국 현황
        -  기준: 2024-03
        - 위치데이터 
            - hospital_info
    - 전국 상가업소 위치 정보 데이터
        - 공공데이터포털 > 소상공인시장진흥공단_상가(상권)정보
        -  기준: 2024-03
        - 위치데이터
            - store_info_seoul
            - store_info_gyeonggi
            - store_info_middle
            - store_info_south

* 통계정보 변경 (#33).
    - 상가업소 분류 카테고리 변경
        - 근거: https://sg.sbiz.or.kr/godo/noticeInfo/announcementView.sg?id=5158&page=1 
            - 상권업종분류 : 표준산업분류 기반 업종분류 개편(837개 -> 247개)
            - 표준산업분류 : 9차→10차
            - 상가업소번호 : 상가업소번호를 새롭게 생성하여 과거 데이터와 연계 불가 
        - stats_info

    
    
# bitSpatial 0.2.6

## NEW FEATURES

* 전국 상가업소 위치 정보 데이터 추가. (#29).
    - store_info_seoul
    - store_info_gyeonggi
    - store_info_middle
    - store_info_south

* 수치지도 데이터에 상가업소 갯수 데이터 추가. (#29). 
    
## BUG FIXS
  
* 증평군 시군구 코드 오류 수정. (#30).
    - cty
    - hospital_info
    - pharmacy_info
    
    
    
# bitSpatial 0.2.5

## NEW FEATURES

* 패키지 소개 Vignette 추가. (#27).

* README 추가. (#26).

## BUG FIXS
  
* Ubuntu에서 위도/경도로 행정구역 코드와 이름 가져오기 에러 수정. (#28).
    - position2mega()
    - position2cty()
    - position2admi()
    
    
    
# bitSpatial 0.2.4.

## NEW FEATURES

* 우편번호 행정동 매핑 데이터 추가. (#23).
    - stats_info

* 약국 위치 정보 데이터 추가. (#22).
    - pharmacy_info
    
* 병원 위치 정보 데이터 추가. (#22).
    - hospital_info    

* 수치지도 데이터에 약국 갯수 데이터 추가. (#24).        
    
* 수치지도 데이터에 병원 갯수 데이터 추가. (#25).    



# bitSpatial 0.2.3

## NEW FEATURES

* 제공 통계정보 데이터 추가. (#20).
    - stats_info

## MINOR CHANGES

* 주제도에서 통계 연동 및 범례 통계이름 출력을 메타 데이터 활용. (#21).
    - thematic_map()

    

# bitSpatial 0.2.2

## NEW FEATURES
  
* 한글폰트 추가 및 주제도에 적용. (#17).
    - 나눔스퀘어 폰트
    - thematic_map()에 적용

## BUG FIXS
  
* 주제도에서 값의 범위를 커버 못하는 그라데이션 오류 수정. (#19).
    - thematic_map()


    
# bitSpatial 0.2.1

## NEW FEATURES
  
* 주제도 시각화 함수. (#18).
    - thematic_map()

* 두 좌표의 거리 구하기. (#16).
    - optimal_map_size()
    
## MINOR CHANGES
  
* 위도/경도로 행정구역 코드 매핑 함수 속도 개선. (#15).
    - position2mega()
    - position2cty()
    - position2admi()



# bitSpatial 0.2.0

## NEW FEATURES
  
* 최적의 지도 이미지 크기 구하는 함수. (#8).
    - optimal_map_size()

* 지도 시각화용 ggplot2 테마 함수. (#9).
    - theme_custom_map()

* 경위도 좌표계 위치정보의 좌표계 변환 함수. (#14).
    - convert_projection()
    
* 위도/경도로 행정구역 코드 매핑 함수. (#11).
    - position2mega()
    - position2cty()
    - position2admi()
    
* 전국 초중등학교 위치 표준 데이터 (#10).
    - school   
    
## MAJOR CHANGES

* 수치지도 데이터에 초등학교갯수, 중학교갯수, 고등학교갯수 데이터 추가. (#10).

## MINOR CHANGES

* 행정구역 경계지도 데이터 중 가구당 인구수 오류 수정. (#13).



# bitSpatial 0.1.3

## MAJOR CHANGES
  
* 수치지도 데이터에 성별 평균연령 통계 데이터 추가. (#6).
    - 여성 평균연령, 남성평균연령, 전체평균연령



# bitSpatial 0.1.2

## NEW FEATURES
  
* 성별 연령대별 인구수 통계 데이터 추가. (#5).
    - 연령그룹별 성별 인구수

    
    
# bitSpatial 0.1.1

## NEW FEATURES
  
* 행정구역 경계 지도 데이터에 통계량 추가. (#2).
    - 인구수
    - 가구수
    - 가구당 인구수
    - 남성 인구수
    - 여성 인구수
    - 여성대비 남성수  

## MAJOR CHANGES

* 행정구역 경계 지도 데이터의 코드를 통계청 코드에서 행정안전부코드로 변경. (#3).
       
       
       
# bitSpatial 0.1.0

## NEW FEATURES
  
* 행정구역 경계 지도 데이터 추가. (#1).
    - mega
       - 광역시 레벨
    - cty
       - 시군구 레벨    
    - admi
       - 읍면동 레벨    