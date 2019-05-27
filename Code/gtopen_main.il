

procedure( gtopen_menu_load(@optional t_menufile)
let((port menuList tt menuListch)
	axlTriggerClear('menu 'gtopen_menu_load)
	unless(t_menufile
		foreach(n0 parseString(axlGetVariable("menupath")	" ")
			when(isFile(strcat(n0 "/allegro.men")) && axlVersion('programName) == "allegro"
				axlUIMenuLoad(strcat(n0 "/allegro.men"))
			)
		)
	)
	menuList = '(
		(popup "&GTopen")
			("[Working Directory]" "filemgr")
			("[Clean Directory]" "skill gtopen_Clean")
			(separator)
;			(popup "Board Tools")
;			   ("Board Parameters Setup" "skill geopen_BoardParam_main")
;			(end)
			(popup "Utility Tools")
			   ("Calculator" "skill gt_calculator_main")
			   ("Export Symbols" "skill gtopen_Export_Symbol")
			   ("Create Pad" "skill gtopen_create_pad")
			   ("Create Gnd Vias" "skill gtopen_AutoVia")
			(end)
			(separator)
			("[Tool About]" "skill axlHttp(\"https://github.com/whh5118/GTOpen\")")
		(end)
	)
	
	;------中文菜单
	chlist = '(
		"&GTopen" "\274\270\302\245\277\306\274\274"
		"[Working Directory]" "[\344\257\300\300\304\277\302\274]"
		"[Clean Directory]" "[\307\345\300\355\304\277\302\274]"
		"Utility Tools" "\312\265\323\303\271\244\276\337"
		"Calculator" "\274\306\313\343\306\367"
		"Export Symbols" "\265\274\263\366\267\342\327\260"
		"Create Pad" "\264\264\275\250\272\270\305\314"
		"Create Gnd Vias" "\264\264\275\250Gnd\271\375\277\327"
		"[Tool About]" "[\271\330\323\332]"
	)
	when(axlVersion('version) < 17 ;&& nil
		menuListch = nil
		foreach(n0 menuList
			tt = member(car(n0) chlist)
			tt0 = member(cadr(n0) chlist)
			if(tt then
				menuListch = cons(list(cadr(tt) cadr(n0)) menuListch)
			else
				if(tt0 then
					menuListch = cons(list(car(n0) cadr(tt0)) menuListch)
				else
					menuListch = cons(n0 menuListch)
				)
			)
		)
		menuList = reverse(menuListch)
	)
	
	
  axlUIMenuFind(nil -1)
  axlUIMenuInsert(nil menuList)
)
)

procedure( gtopen_Clean()
	shell("
		del /f /s /q  *.log
		del /f /s /q  *.dbk
		del /f /s /q  *.opj
		del /f /s /q  *.jrl
		del /f /s /q  *.cnv
		del /f /s /q  *.sav
		del /f /s /q  *.ldf
		del /f /s /q  *.csv
		del /f /s /q  *.scr
		del /f /s /q  *.xml
		del /f /s /q  *.dml
		del /f /s /q  *.dml,1
		del /f /s /q  *.XRF
		del /f /s /q  *.bdf
		del /f /s /q  *.tag
		del /f /s /q  *.form
		rd /s /q Indesign
		rd /s /q signoise.run
	")
)

procedure( gtopen_about()
	axlUIConfirm("\274\270\302\245\277\306\274\274\277\252\324\264skill")
)

;-----调试函数
procedure( gtopen_Debugfun()
let((tt)
;------ctrl+1是加载，ctrl+2是运行。

t
)
)



;------环境定义
procedure( gtopen_int()
let((file port InstallPath)
	unless(boundp('gtopen_global)
		defvar(gtopen_global nil)
		gtopen_global = ncons(nil)
	)
	InstallPath = nil
	file = strcat(buildString(parseString(getShellEnvVar("HOME") "\\") "/") "/pcbenv/allegro.ilinit")
	port = infile(file)
	while(gets(n0 port)
		when(rexMatchp("load.*gtopen_main.il\")+" n0)
			InstallPath = car(axlDMFileParts(cadr(parseString(n0 " ()\t\n\""))))
			InstallPath = buildString(reverse(cdr(reverse(parseString(InstallPath "/\\")))) "/")
		)
	)
	close(port)
	gtopen_global->InstallPath = InstallPath
	axlTriggerSet('menu 'gtopen_menu_load)
	axlSetAlias( "~1" "skill load(strcat(gtopen_global->InstallPath \"/Code/gtopen_main.il\"))")
	axlSetAlias( "~2" "skill gtopen_Debugfun")
	
	
;------将需要调试的il文件到这里。
	load(strcat(gtopen_global->InstallPath "/Code/gtopen_Code.il"))
	
	
	
	
	
;---------------------------

)
)
gtopen_int()