syn keyword cExtraType
	\ i8 i16 i32 i64
	\ u8 u16 u32 u64
	\ b8 b16 b32 b64
	\ isize usize uint uintptr
	\ f16 f32 f64

syn keyword Keyword typedef sizeof alignof decltype
syn match cppNamespace '\v\zs\i+\ze(\<.{-}\>)?\s*::\s*\i+'
syn match cAttribute '\v\[\[.{-}\]\]'

syn keyword cType true false NULL

syn clear cStructure

syn keyword cDeFactoConstant true false NULL nullptr

syn match cStructKw '\v(struct|union|enum)' contained
syn match cStructure '\zs\v(struct|union|enum)\s*(\i+)?\ze\s*\{?' contains=cStructKw

hi! link cStructure Type
hi! link cStructKw Keyword

hi! link cDeFactoConstant Keyword
hi! link cStructure Type
hi! link cStructKw Keyword
hi! link cppNamespace Type
hi! link cAttribute Type
hi! link cExtraType Type

