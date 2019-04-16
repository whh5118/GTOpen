

;------环境定义

procedure( gtopen_int()
let((file port InstallPath)
	unless(boundp('gtopen_global)
		defvar(gtopen_global nil)
		gtopen_global = ncons(nil)
	)
	
	;---获取安装路径
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
)
)
gtopen_int()


;-----测试函数
procedure( gtopen_Debugfun()
let((tt)
	load(strcat(gtopen_global->InstallPath "/code/gtopen_calculator.il"))
	gt_calculator_main()
t
)
)


axlSetAlias( "~1" "skill load(strcat(gtopen_global->InstallPath \"/Code/gtopen_main.il\"))")
axlSetAlias( "~2" "skill gtopen_Debugfun")