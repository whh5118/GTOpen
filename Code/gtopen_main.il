

procedure( gtopen_menu_load(@optional window timerId_lj elapsedTime)
prog((port menuList tt menuListch chlist file line port offset)
	unless(axlGetVariable("menuload")
		return(t)
	)
	file = "1211.txt" ;axlTempFile()
	axlUIMenuDump(file)
	port = infile(file)
	menuexit = nil
	while(gets(line port)
		when(rexMatchp("GTopen+" line)
			menuexit = t
		)
	)
	close(port)
	deleteFile(file)
	if(menuexit then
		return(t)
	else
		timerId = axlUIWTimerAdd(nil 2000 t 'gtopen_menu_load)
	)
	menuList = '(
		(popup "&GTopen")
			("[Working Directory]" "filemgr")
			("[Clean Directory]" "skill gtopen_Clean")
			(separator)
			(popup "Cut")
			   ("Cut Clines/Lines/Shapes" "gtopen_CutClines_Lines_Shapes")
			(end)
			(popup "Create")
			   ("Create Pad" "skill gtopen_create_pad")
			   ("Create Gnd Vias" "skill gtopen_AutoVia")
			(end)
			(popup "Utility Tools")
			   ("Calculator" "skill gt_calculator_main")
			   ("Export Symbols" "skill gtopen_Export_Symbol")
			   ("Cline Cross" "gtopen_Cline_Cross")
			(end)
			(separator)
			("[Tool About]" "http https://github.com/whh5118/GTOpen")
		(end)
	)
	
	;------中文菜单。
	chlist = '(
		"&GTopen" "\274\270\302\245\277\306\274\274"
		"[Working Directory]" "[\344\257\300\300\304\277\302\274]"
		"[Clean Directory]" "[\307\345\300\355\304\277\302\274]"
		"Utility Tools" "\312\265\323\303\271\244\276\337"
		"Cut" "\307\320\270\356"
		"Cut Clines/Lines" "\307\320\270\356\317\337\266\316"
		"Calculator" "\274\306\313\343\306\367"
		"Export Symbols" "\265\274\263\366\267\342\327\260"
		"Create Pad" "\264\264\275\250\272\270\305\314"
		"Create Gnd Vias" "\264\264\275\250Gnd\271\375\277\327"
		"[Tool About]" "[\271\330\323\332]"
	)
	when(axlVersion('version) < 17 && nil
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
	offset = "-1"
	when(axlVersion('version) <= 17
		offset = "100"
		file = axlTempFile()
		axlUIMenuDump(file)
		axlUIMenuLoad(file)
	)
  axlUIMenuFind(nil readstring(offset))
  axlUIMenuInsert(nil menuList)
  deleteFile(file)
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


;------环境定义
procedure( gtopen_int()
let((file port InstallPath)
	unless(boundp('gtopen_global)
		defvar(gtopen_global nil)
		gtopen_global = ncons(nil)
	)
	InstallPath = nil
	file = strcat(axlOSSlash(getShellEnvVar("HOME")) "/pcbenv/allegro.ilinit")
	port = infile(file)
	while(gets(n0 port)
		when(rexMatchp("load.*gtopen_main.il\")+" n0)
			InstallPath = car(axlDMFileParts(cadr(parseString(n0 " ()\t\n\""))))
			InstallPath = buildString(reverse(cdr(reverse(parseString(InstallPath "/\\")))) "/")
		)
	)
	close(port)
	gtopen_global->InstallPath = InstallPath
	load(strcat(gtopen_global->InstallPath "/Code/gtopen_Code.il"))
	timerId = axlUIWTimerAdd(nil 1000 t 'gtopen_menu_load) ;<5000
)
)
gtopen_int()


procedure( gtopen_install()
let(()
	file = strcat(axlOSSlash(getShellEnvVar("HOME")) "/pcbenv/allegro.ilinit")
	port = outfile(file "a")
	fprintf(port "\nload(%L)" strcat(getWorkingDir() "/Code/gtopen_main.il"))
	close(port)
)
)