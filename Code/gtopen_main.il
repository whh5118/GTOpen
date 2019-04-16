


;------环境定义

defvar(gtopen_global nil)


;-----转换成中文，快捷键（Ctrl+Q）
procedure( Test_ChangeEn2CH()
let((tt)
	tt = axlUIPrompt("\307\353\312\344\310\353\326\320\316\304\243\272")
	axlUIPrompt("\264\372\302\353\312\307:",sprintf(nil,"%L",tt))
	t
)
)

;-----测试函数
procedure( Test_fun()
let((tt)
	println(11)
t
)
)

