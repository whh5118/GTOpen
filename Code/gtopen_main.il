

procedure( gtopen_menu_load(@optional t_menufile)
let((port menuList)
	axlTriggerClear('menu 'gtopen_menu_load)
	unless(t_menufile
		foreach(n0 parseString(axlGetVariable("menupath")	" ")
			when(isFile(strcat(n0 "/allegro.men")) && axlVersion('programName) == "allegro"
				axlUIMenuLoad(strcat(n0 "/allegro.men"))
			)
		)
	)
	load(strcat(gtopen_global->InstallPath "/Code/gtopen_calculator.il"))
	menuList = '(
		(popup "&GTopen")
			("[Working Directory]" "filemgr")
			("[Clean Directory]" "skill gtopen_Clean")
			(separator)
			(popup "Utility Tools")
			   ("mils<->mm" "skill gt_calculator_main")
			(end)
			(separator)
			("[Tool About]" "skill axlHttp(\"https://github.com/whh5118/GTOpen\")")
		(end)
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
	
	gtopen_menu_load()
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
	load(strcat(gtopen_global->InstallPath "/Code/gtopen_calculator.il"))
	
	
	
	
	
;---------------------------

)
)
gtopen_int()