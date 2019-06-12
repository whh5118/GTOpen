

procedure( gtopen_menu_load(@optional window timerId_lj elapsedTime)
prog((port menuList tt menuListch chlist file line port offset)
	file = axlTempFile()
	axlUIMenuDump(file)
	port = infile(file)
	menuexit = nil
	while(gets(line port)
		when(rexMatchp("https://github.com/whh5118/GTOpen+" line)
			menuexit = t
		)
	)
	close(port)
	deleteFile(file)
	if(menuexit then
		return(t)
	else
		timerId = axlUIWTimerAdd(nil 5000 t 'gtopen_menu_load)
	)
	menuList = '(
		(popup "&GTopen")
			("[Working Directory]" "filemgr")
			("[Clean Directory]" "skill gtopen_Clean")
			(separator)
			(popup "Cut/Link")
			   ("Cut Clines/Lines/Shapes" "gtopen_CutClines_Lines_Shapes")
			   ("Link Cline" "gtopen_Cline_Cross")
			(end)
			(popup "Create")
			   ("Create Pad" "skill gtopen_create_pad")
			   ("Create Gnd Vias" "skill gtopen_AutoVia")
			(end)
			(popup "Utility Tools")
			   ("Calculator" "skill gt_calculator_main")
			   ("Export Symbols" "skill gtopen_Export_Symbol")
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
		"[Tool About]" "[\271\330\323\332]"
		"Cut/Link" "\307\320\270\356/\301\254\317\337"
		"Cut Clines/Lines/Shapes" "\307\320\270\356\317\337\266\316/\315\255\306\244"
		"Link Cline" "\327\324\266\257\301\254\317\337"
		
		"Create" "\264\264\275\250"
		"Create Pad" "\264\264\275\250\272\270\305\314"
		"Create Gnd Vias" "\264\264\275\250Gnd\271\375\277\327"
		
		"Utility Tools" "\312\265\323\303\271\244\276\337"
		"Calculator" "\274\306\313\343\306\367"
		"Export Symbols" "\265\274\263\366\267\342\327\260"
	)
	when(axlVersion('version) < 17 							;（想要中文菜单，用这行，注释掉下面一行） 
;	when(nil 																		;（想要英文菜单，用这行，注释掉上面一行） 
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
	when(axlVersion('version) < 17
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
prog((file port InstallPath tt)
	unless(boundp('gtopen_global)
		defvar(gtopen_global ncons(nil))
	)
	InstallPath = nil
	tt = setof(x0 getSkillPath() (isFile(strcat(x0 "/allegro.ilinit")) == t))
	file = strcat(axlOSSlash(car(tt)) "/allegro.ilinit")
	port = infile(file)
	while(gets(n0 port)
		when(rexMatchp("^load.*gtopen_main.il\")+" n0)
			InstallPath = car(axlDMFileParts(cadr(parseString(n0 " ()\t\n\""))))
			InstallPath = buildString(reverse(cdr(reverse(parseString(InstallPath "/\\")))) "/")
		)
	)
	close(port)
	gtopen_global->InstallPath = InstallPath
	load(strcat(gtopen_global->InstallPath "/Code/gtopen_Code.il"))
	timerId = axlUIWTimerAdd(nil 1000 t 'gtopen_menu_load) ;<5000
	printf("\n\n>>GTopen\262\313\265\245\316\264\274\323\324\330\243\254\307\353\312\344\310\353\243\272GTopen\n\n")
	axlCmdRegister("GTopen" 'gtopen_menu_load ?cmdType "general")
)
)
gtopen_int()


procedure( gtopen_install()
let((tt file port)
	tt = setof(x0 getSkillPath() (isFile(strcat(x0 "/allegro.ilinit")) == t))
	file = strcat(axlOSSlash(car(tt)) "/allegro.ilinit")
	port = outfile(file "a")
	fprintf(port "\nload(%L)" strcat(getWorkingDir() "/Code/gtopen_main.il"))
	close(port)
)
)