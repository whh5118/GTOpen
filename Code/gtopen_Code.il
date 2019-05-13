;------计算器主函数--------------
;------主函数
procedure( gt_calculator_main()
prog((form)
	form = gt_calculator_createform()
	gt_calculator_int_var(form)
	gt_calculator_update_form(form)
)
)


;------创建form
procedure( gt_calculator_createform()
let((file port form)
	file = strcat(gtopen_global->InstallPath "/Code/form/gtopen_calculator.form")
	when(boundp('calculator_form)
		when(axlIsFormType(eval('calculator_form))
			axlFormClose(eval('calculator_form))
		)
	)
	form = axlFormCreate('calculator_form file nil 'gt_calculator_CB t)
	form
)
)


;------form初始化
procedure( gt_calculator_int_var(form)
let(()
	form->var = ncons(nil)
	form->var->mils_input = nil
	form->var->mm_input = nil
)
)

;------form更新
procedure( gt_calculator_update_form(form)
let((tt)
	
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)
)
)

;------form反馈函数
procedure( gt_calculator_CB(form)
let((tt update)
	update = t
	case(form->curField
		("mils_input"
			if(rexMatchp("[^0-9.]+" form->curValue) then
				axlUIWPrint(form "\312\344\310\353\264\355\316\363")
			else
				tt = evalstring(form->curValue)
				if(tt > 393700787 then
					axlUIWPrint(form "\312\344\310\353\264\355\316\363")
				else
					form->var->mils_input = form->curValue
			  	form->var->mm_input = sprintf(nil "%.3g" axlMKSConvert(tt "MILS" "MM"))
				)
			)
		)
	
    ("mm_input"
	 		if(rexMatchp("[^0-9.]+" form->curValue) then 
				axlUIWPrint(form "\312\344\310\353\264\355\316\363")
			else 
				tt = evalstring(form->curValue)
				println(tt)
				if(tt > 2539999 then
					axlUIWPrint(form "\312\344\310\353\264\355\316\363")
				else
					form->var->mm_input = form->curValue
					
					form->var->mils_input = sprintf(nil "%g" axlMKSConvert(tt "MM" "MILS"))
				)
			)
	  	t
    )
    (t
    	update = nil
    )
	)
	when(update
		gt_calculator_update_form(form)
	)
)
)

;---------导出封装--------
procedure( gtopen_Export_Symbol()
let((form)

	form = gtopen_Export_Symbol_createform()
	gtopen_Export_Symbol_int_var(form)
	gtopen_Export_Symbol_update_form(form)

)
)

procedure( gtopen_Export_Symbol_createform()
let((file form)
	file = strcat(gtopen_global->InstallPath "/Code/form/gtopen_Export_Symbol.form")
	when(boundp('exportsymbol_form)
		when(axlIsFormType(eval('exportsymbol_form))
			axlFormClose(eval('exportsymbol_form))
		)
	)
	form = axlFormCreate('exportsymbol_form file nil 'gtopen_Export_Symbol_CB t)
	form

)
)

procedure( gtopen_Export_Symbol_CB(form)
let((tt symbols OldDir SavePath symbolids)
	case(form->curField
		("export"
			SavePath = axlDMDirectoryBrowse("." t ?title "Pick a directory")
			when(SavePath
				OldDir = getWorkingDir()
				changeWorkingDir(SavePath)
				symbols = nil
				foreach(n0 setof(x0 form->Items (axlFormTreeViewGetSelectState(form "symbols" x0) == 1))
					symbols = cons(axlFormTreeViewGetLabel(form "symbols" n0) symbols)
				)
				symbolids = setof(x0 axlDBGetDesign()->symdefs (member(x0->name symbols) != nil))
				foreach(n0 symbolids
					axlWritePackageFile(n0)
				)
				changeWorkingDir(OldDir)
			)
		)
	)
)
)


procedure( gtopen_Export_Symbol_int_var(form)
let(()
	
	form->symbols = sort(axlDBGetDesign()->symdefs~>name 'axlStrcmpAlpNum)

)
)

procedure( gtopen_Export_Symbol_update_form(form)
let((tt)
	unless(form->isChanged
		form->Items = nil
		foreach(n0 form->symbols
			tt = axlFormTreeViewAddItem(form "symbols" n0 nil nil t 4 nil nil)
			form->Items = cons(tt form->Items)
		)
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)

)
)
