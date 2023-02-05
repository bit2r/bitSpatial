#' @importFrom sysfonts font_add_google font_add 
#' @importFrom showtext showtext_auto
.onAttach <- function(libname, pkgname) {
  tryCatch(
    expr = {
      # Online Korean font
      sysfonts::font_add_google(name = "Noto Sans KR", 
                                family = "Noto Sans Korean") 
      
      options(is_offline = FALSE)
    },
    error = function(e) { 
      options(is_offline = TRUE)
      
      packageStartupMessage("Because it is an offline environment, only offline fonts are imported.")
    },    
    finally = {
      # Offline Korean font
      font_path <- system.file("fonts", "NanumSquare", package = "bitSpatial")
      sysfonts::font_add(
        family = "NanumSquare",
        regular = paste(font_path, "NanumSquareOTF_acR.otf", sep = "/")
      )
    }
  )  
  
  showtext::showtext_auto()
}