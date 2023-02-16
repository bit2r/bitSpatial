# bitSpatial 0.2.4.9002

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