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
;	2019-09-13：首板
;	2019-05-15：更新，解决中间层不能导出问题
;---------
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
let((tt symdefs OldDir SavePath symdefids)
	case(form->curField
		("export"
			SavePath = axlDMDirectoryBrowse("." t ?title "Pick a directory")
			when(SavePath
				when(length(axlSubclassRoute(?field 'isEtch)) == 2
					axlLayerCreateCrossSection("BOTTOM" "Conductor" "Copper" "GT0")
					axlLayerCreateCrossSection("BOTTOM" "DIELECTRIC" "FR-4" "GT1")
				)
	
				symdefs = nil
				foreach(n0 setof(x0 form->Items (axlFormTreeViewGetSelectState(form "symbols" x0) == 1))
					symdefs = cons(axlFormTreeViewGetLabel(form "symbols" n0) symdefs)
				)
				symdefids = setof(x0 axlDBGetDesign()->symdefs (member(x0->name symdefs) != nil))
				
				foreach(n0 symdefids
					axlWritePackageFile(n0 SavePath)
				)
				when(axlLayerGet("ETCH/GT0")
					axlDeleteObject(axlLayerGet("ETCH/GT0"))
				)
				when(axlLayerGet("ETCH/GT1")
					axlDeleteObject(axlLayerGet("ETCH/GT1"))
				)
			)
		)
	)
)
)


procedure( gtopen_Export_Symbol_int_var(form)
let(()
	tt = setof(x0 axlDBGetDesign()->symdefs (x0->instances != nil))
	form->symbols = sort(tt~>name 'axlStrcmpAlpNum)
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


;--------创建焊盘--------
;	2019-05-15：首板

;---------------



procedure( gtopen_create_pad()
let((form)

	form = gtopen_create_pad_createform()
	gtopen_create_pad_int_var(form)
	gtopen_create_pad_update_form(form)

)
)


procedure( gtopen_create_pad_createform()
let((file form)
	file = strcat(gtopen_global->InstallPath "/Code/form/gtopen_create_pad.form")
	when(boundp('createpad_form)
		when(axlIsFormType(eval('createpad_form))
			axlFormClose(eval('createpad_form))
		)
	)
	form = axlFormCreate('createpad_form file nil 'gtopen_create_pad_CB t)
	form
	
)
)

procedure( gtopen_create_pad_int_var(form)
let(()
	
	form->pop = ncons(nil)
	form->pop->padtype = list(
		list("\261\355\314\371" "padtype_smd")
		list("\315\250\277\327" "padtype_hole")
		list("\271\375\277\327" "padtype_via")
	)
	form->var = ncons(nil)
	form->var->padtype = cadar(form->pop->padtype)
	
	form->var->rec_pad = t
	form->var->unitsel = "mil"
	form->var->pad_name = "smd100_80"
	form->var->value_W = 100.
	form->var->value_H = 80.
	form->var->value_D1 = 40.
	form->var->value_D2 = 60.
	form->var->sold_val = 4.
	
	form->var->cir_cir_hole = t
	
	form->vis = ncons(nil)
	form->vis->rec_pad = 1
	form->vis->cir_pad = 1
	form->vis->obl_pad = 1
	form->vis->cir_cir_hole = 0
	form->vis->cir_Rec_hole = 0
	form->vis->cir_oval_hole = 0
	form->vis->oval_oval_hole = 0
	form->vis->nth_hole = 0
	
	form->vis->W_name = 1
	form->vis->value_W = 1
	form->vis->H_name = 1
	form->vis->value_H = 1
	form->vis->D1_name = 0
	form->vis->value_D1 = 0
	form->vis->D2_name = 0
	form->vis->value_D2 = 0
t
)
)


procedure( gtopen_create_pad_CB(form)
let((SavePath tt)
	case(form->curField
		("pad_name" | "value_W" | "value_H" | "value_D1" | "value_D2" | "sold_val"
			evalstring(sprintf(nil "form->var->%s = %L" form->curField form->curValue))
			when(form->curField == "pad_name"
				form->var->pad_name = lowerCase(form->curValue)
			)
		)
		("unitsel"
			form->var->value_W = axlMKSConvert(form->var->value_W form->var->unitsel form->curValue)
			form->var->value_H = axlMKSConvert(form->var->value_H form->var->unitsel form->curValue)
			form->var->value_D1 = axlMKSConvert(form->var->value_D1 form->var->unitsel form->curValue)
			form->var->value_D2 = axlMKSConvert(form->var->value_D2 form->var->unitsel form->curValue)
			form->var->sold_val = axlMKSConvert(form->var->sold_val form->var->unitsel form->curValue)
			form->var->unitsel = form->curValue
		)
		("rec_pad" | "cir_pad" | "obl_pad"
			foreach(n0 list("rec_pad" "cir_pad" "obl_pad")
				evalstring(sprintf(nil "form->var->%s = axlFormGetField(form %L)" n0 n0))
			)
		)
		("cir_cir_hole" | "cir_Rec_hole" | "cir_oval_hole" | "oval_oval_hole" | "nth_hole"
			foreach(n0 list("cir_cir_hole" "cir_Rec_hole" "cir_oval_hole" "oval_oval_hole" "nth_hole")
				evalstring(sprintf(nil "form->var->%s = axlFormGetField(form %L)" n0 n0))
			)
		)
		("cpad"
			SavePath = axlDMDirectoryBrowse("." t ?title "Pick a directory")
			when(SavePath
				tt = gtopen_create_pad_CreateAction(form)
				when(tt
					axlOSFileMove(tt strcat(SavePath "/" tt))
				)
			)
		)
		("padtype"
			form->var->padtype = form->curValue
			form->var->sold_val = 4.
			form->var->rec_pad = t
			form->var->cir_pad = nil
			form->var->obl_pad = nil
			form->var->cir_cir_hole = t
			form->var->cir_Rec_hole = nil
			form->var->cir_oval_hole = nil
			form->var->oval_oval_hole = nil
			form->var->nth_hole = nil
			
			case(form->curValue
				("padtype_smd"
					form->vis->rec_pad = 1
					form->vis->cir_pad = 1
					form->vis->obl_pad = 1
					form->vis->cir_cir_hole = 0
					form->vis->cir_Rec_hole = 0
					form->vis->cir_oval_hole = 0
					form->vis->oval_oval_hole = 0
					form->vis->nth_hole = 0
				)
				("padtype_hole"
					form->vis->rec_pad = 0
					form->vis->cir_pad = 0
					form->vis->obl_pad = 0
					form->vis->cir_cir_hole = 1
					form->vis->cir_Rec_hole = 1
					form->vis->cir_oval_hole = 1
					form->vis->oval_oval_hole = 1
					form->vis->nth_hole = 1
				)
				("padtype_via"
					form->vis->rec_pad = 0
					form->vis->cir_pad = 0
					form->vis->obl_pad = 0
					form->vis->cir_cir_hole = 0
					form->vis->cir_Rec_hole = 0
					form->vis->cir_oval_hole = 0
					form->vis->oval_oval_hole = 0
					form->vis->nth_hole = 0
					form->var->sold_val = 0.
				)
			)
		)
	)
	unless(form->curField == ""
		gtopen_create_pad_update_form(form)
	)
t
)
)


procedure( gtopen_create_pad_update_form(form)
let((tt)
	
	form->var->W_name = "W"
	form->var->H_name = "H"
	case(form->var->padtype
		("padtype_smd"
			form->vis->D1_name = 0
			form->vis->value_D1 = 0
			form->vis->D2_name = 0
			form->vis->value_D2 = 0
			if(form->var->cir_pad then
				form->vis->H_name = 0
				form->vis->value_H = 0
			else
				form->vis->H_name = 1
				form->vis->value_H = 1
			)
		)
		("padtype_hole"
			form->vis->W_name = 1
			form->vis->value_W = 1
			form->vis->H_name = 1
			form->vis->value_H = 1
			form->vis->D1_name = 0
			form->vis->value_D1 = 0
			form->vis->D2_name = 0
			form->vis->value_D2 = 0
			cond(
				(form->var->cir_cir_hole
					form->var->W_name = "D0"
					form->vis->H_name = 0
					form->vis->value_H = 0
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
				)
				(form->var->cir_Rec_hole
					form->vis->H_name = 0
					form->vis->value_H = 0
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
				)
				(form->var->cir_oval_hole
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
				)
				(form->var->oval_oval_hole
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
					form->vis->D2_name = 1
					form->vis->value_D2 = 1
				)
				(form->var->nth_hole
					form->vis->W_name = 0
					form->vis->value_W = 0
					form->var->H_name = "D1"
				)
			)
		)
		("padtype_via"
			form->var->W_name = "D0"
			form->var->H_name = "D1"
		)
	)
	
	gtopen_create_pad_RenamePad(form)
	foreach(n0 form->vis->?
		tt = member(n0 form->vis)
		axlFormSetFieldVisible(form symbolToString(car(tt)) cadr(tt))
	)
	foreach(n0 form->pop->?
		tt = member(n0 form->pop)
		axlFormBuildPopup(form symbolToString(car(tt)) cadr(tt))
	)
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	handle = axlGRPDrwInit(form "pad_view" 'gtopen_create_pad_GrawView)
	handle->form = form
	unless(member(form->curField list("pad_name" "unitsel" "value_W" "value_H" "value_D1" "value_D2" "sold_val" "cpad"))
		axlGRPDrwUpdate(handle)
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)

)
)


procedure( gtopen_create_pad_GrawView(handle)
let((form s_xy xy_l xy_r)
	form = handle->form
	cond(
		(form->var->padtype == "padtype_smd"
			axlGRPDrwMapWindow(handle 200 200)
			putprop(handle "white" 'color)
			putprop(handle "filled" 'fill)
			axlGRPDrwRectangle(handle '(0 0) '(200 200))
			cond(
				(form->var->rec_pad
					putprop(handle "red" 'color)
					axlGRPDrwRectangle(handle 40:60 160:140)
					putprop(handle "black" 'color)
					axlGRPDrwLine(handle list(40:50 40:30))
					axlGRPDrwLine(handle list(160:50 160:30))
					axlGRPDrwText(handle 90:30 "W")
					axlGRPDrwLine(handle list(170:60 190:60))
					axlGRPDrwLine(handle list(170:140 190:140))
					axlGRPDrwText(handle 175:90 "H")
				)
				(form->var->cir_pad
			    putprop(handle "red" 'color)
			    axlGRPDrwCircle(handle 100:100 65)
					putprop(handle "black" 'color)
					axlGRPDrwLine(handle list(35:70 35:10))
					axlGRPDrwLine(handle list(165:70 165:10))
					axlGRPDrwText(handle 90:10 "W")
				)
				(form->var->obl_pad
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 70:100 30)
					axlGRPDrwRectangle(handle 70:70 130:130)
					axlGRPDrwCircle(handle 130:100 30)
					putprop(handle "black" 'color)
					axlGRPDrwLine(handle list(40:60 40:30))
					axlGRPDrwLine(handle list(160:60 160:30))
					axlGRPDrwText(handle 90:40 "W")
					axlGRPDrwLine(handle list(170:70 190:70))
					axlGRPDrwLine(handle list(170:130 190:130))
					axlGRPDrwText(handle 175:90 "H")
				)
			)
		)
		(form->var->padtype == "padtype_hole"
			axlGRPDrwMapWindow(handle 200 200)
			putprop(handle "white" 'color)
			putprop(handle "filled" 'fill)
			axlGRPDrwRectangle(handle 0:0 200:200)
			cond(
				(form->var->cir_cir_hole
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 100:100 60)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 30)
					axlGRPDrwLine(handle list(40:60 40:10))
					axlGRPDrwLine(handle list(160:60 160:10))
					axlGRPDrwText(handle 90:10 "D0")
					axlGRPDrwLine(handle list(80:170 80:190))
					axlGRPDrwLine(handle list(120:170 120:190))
					axlGRPDrwText(handle 90:170 "D1")
				)
				(form->var->cir_Rec_hole
					putprop(handle "red" 'color)
					axlGRPDrwRectangle(handle 40:40 160:160)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 30)
					axlGRPDrwLine(handle list(40:30 40:10))
					axlGRPDrwLine(handle list(160:30 160:10))
					axlGRPDrwText(handle 90:10 "W")
					axlGRPDrwLine(handle list(80:170 80:190))
					axlGRPDrwLine(handle list(120:170 120:190))
					axlGRPDrwText(handle 90:170 "D1")
				)
				(form->var->cir_oval_hole
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 60:100 30)
					axlGRPDrwCircle(handle 140:100 30)
					axlGRPDrwRectangle(handle 60:70 140:130)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 20)
					axlGRPDrwLine(handle list(30:60 30:40))
					axlGRPDrwLine(handle list(170:60 170:40))
					axlGRPDrwText(handle 90:40 "W")
					axlGRPDrwLine(handle list(180:70 200:70))
					axlGRPDrwLine(handle list(180:130 200:130))
					axlGRPDrwText(handle 180:90 "H")
					axlGRPDrwLine(handle list(80:140 80:160))
					axlGRPDrwLine(handle list(120:140 120:160))
					axlGRPDrwText(handle 90:140 "D1")
				)
				(form->var->oval_oval_hole
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 60:100 30)
					axlGRPDrwCircle(handle 140:100 30)
					axlGRPDrwRectangle(handle 60:70 140:130)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 80:100 20)
					axlGRPDrwCircle(handle 120:100 20)
					axlGRPDrwRectangle(handle 80:80 120:120)
					axlGRPDrwLine(handle list(30:60 30:40))
					axlGRPDrwLine(handle list(170:60 170:40))
					axlGRPDrwText(handle 90:40 "W")
					axlGRPDrwLine(handle list(180:70 200:70))
					axlGRPDrwLine(handle list(180:130 200:130))
					axlGRPDrwText(handle 180:90 "H")
					axlGRPDrwLine(handle list(20:80 0:80))
					axlGRPDrwLine(handle list(20:120 0:120))
					axlGRPDrwText(handle 0:90 "D1")
					axlGRPDrwLine(handle list(60:140 60:160))
					axlGRPDrwLine(handle list(140:140 140:160))
					axlGRPDrwText(handle 90:140 "D2")
				)
				(form->var->nth_hole
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 30)
					axlGRPDrwLine(handle list(140:70 160:70))
					axlGRPDrwLine(handle list(140:130 160:130))
					axlGRPDrwText(handle 140:90 "D1")
				)
			)
		)
		(form->var->padtype == "padtype_via"
			axlGRPDrwMapWindow(handle 200 200)
			putprop(handle "white" 'color)
			putprop(handle "filled" 'fill)
			axlGRPDrwRectangle(handle 0:0 200:200)
			putprop(handle "blue" 'color)
			axlGRPDrwCircle(handle 100:100 60)
			putprop(handle "black" 'color)
			axlGRPDrwCircle(handle 100:100 30)
			axlGRPDrwLine(handle list(40:60 40:10))
			axlGRPDrwLine(handle list(160:60 160:10))
			axlGRPDrwText(handle 90:10 "D0")
			axlGRPDrwLine(handle list(170:70 190:70))
			axlGRPDrwLine(handle list(170:130 190:130))
			axlGRPDrwText(handle 170:90 "D1")
		)
		
	)
)
)


procedure( gtopen_create_pad_RenamePad(form)
let((ttW ttH ttD1 ttD2)
	case(form->var->padtype
		("padtype_smd"
			if(form->var->unitsel == "mm" then
				ttW = parseString(sprintf(nil "%.2f" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%.2f" form->var->value_H) ".")
			else
				ttW = parseString(sprintf(nil "%L" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%L" form->var->value_H) ".")
			)
			cond(
				(form->var->rec_pad
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "smd%sm%s_%sm%s" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "smd%s_%s" car(ttW) car(ttH))
					)
				)
				(form->var->cir_pad
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "ball%sm%s" car(ttW) cadr(ttW))
					else
						form->var->pad_name = sprintf(nil "ball%s" car(ttW))
					)
				)
				(form->var->obl_pad
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "smd%sm%s_%sm%sob" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "smd%s_%sob" car(ttW) car(ttH))
					)
				)
			)
		)
		("padtype_hole"
			if(form->var->unitsel == "mm" then
				ttW = parseString(sprintf(nil "%.2f" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%.2f" form->var->value_H) ".")
				ttD1 = parseString(sprintf(nil "%.2f" form->var->value_D1) ".")
				ttD2 = parseString(sprintf(nil "%.2f" form->var->value_D2) ".")
			else
				ttW = parseString(sprintf(nil "%L" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%L" form->var->value_H) ".")
				ttD1 = parseString(sprintf(nil "%.2f" form->var->value_D1) ".")
				ttD2 = parseString(sprintf(nil "%.2f" form->var->value_D2) ".")
			)
			cond(
				(form->var->cir_cir_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%scir%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "pad%scir%sd" car(ttW) car(ttH))
					)
				)
				(form->var->cir_Rec_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%ssq%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "pad%ssq%sd" car(ttW) car(ttH))
					)
				)
				(form->var->cir_oval_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%sx%sm%sob%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH) car(ttD1) cadr(ttD1))
					else
						form->var->pad_name = sprintf(nil "pad%sx%sob%sd" car(ttW) car(ttH) car(ttD1))
					)
				)
				(form->var->oval_oval_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%sx%sm%sob%sm%sx%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH) car(ttD1) cadr(ttD1) car(ttD2) cadr(ttD2))
					else
						form->var->pad_name = sprintf(nil "pad%sx%sob%sx%sd" car(ttW) car(ttH) car(ttD1) car(ttD2))
					)
				)
				(form->var->nth_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "npad%sm%scir" car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "npad%scir" car(ttH))
					)
				)
			)
		)
		("padtype_via"
			if(form->var->unitsel == "mm" then
				ttW = parseString(sprintf(nil "%.2f" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%.2f" form->var->value_H) ".")
				form->var->pad_name = sprintf(nil "via%sm%s_%sm%s" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
			else
				ttW = parseString(sprintf(nil "%L" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%L" form->var->value_H) ".")
				form->var->pad_name = sprintf(nil "via%s_%s" car(ttW) car(ttH))
			)
		)
	)
)
)

procedure( gtopen_create_pad_CreateAction(form)
let((ttW ttH ttD1 ttD2 ttS figure file)
	file = nil
	case(form->var->padtype
		("padtype_smd"
			if(form->var->unitsel == "mm" then
				ttW = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_H))
				ttS = axlMKS2UU(sprintf(nil "%.2f mm" form->var->sold_val))
			else
				ttW = axlMKS2UU(sprintf(nil "%L mil" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%L mil" form->var->value_H))
				ttS = axlMKS2UU(sprintf(nil "%L mil" form->var->sold_val))
			)
			cond(
				(form->var->rec_pad
					figure = 'RECTANGLE
					when(ttH == ttW
						figure = 'SQUARE
					)
				)
				(form->var->cir_pad
					figure = 'CIRCLE
					ttH = ttW
				)
				(form->var->obl_pad
					figure = 'OBLONG_X
				)
			)
	    pad_list = cons(make_axlPadStackPad(?layer "TOP" ?type 'REGULAR	
	    	?figure figure ?figureSize (ttW:ttH)) nil
	    )
	    pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_TOP" ?type 'REGULAR 
	    	?figure figure ?figureSize (ttW+ttS):(ttH+ttS)) pad_list
	    )
	    pad_list = cons(make_axlPadStackPad(?layer "PASTEMASK_TOP" ?type 'REGULAR	
	    	?figure figure ?figureSize (ttW:ttH)) pad_list
	    )
	    axlDBCreatePadStack(form->var->pad_name nil pad_list t)
			when(axlPadstackToDisk(form->var->pad_name)
				file = strcat(form->var->pad_name ".pad")
			)
		)
		("padtype_hole" | "padtype_via"
			if(form->var->unitsel == "mm" then
				ttW = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_H))
				ttD1 = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_D1))
				ttD2 = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_D2))
				ttS = axlMKS2UU(sprintf(nil "%.2f mm" form->var->sold_val))
			else
				ttW = axlMKS2UU(sprintf(nil "%L mil" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%L mil" form->var->value_H))
				ttD1 = axlMKS2UU(sprintf(nil "%L mil" form->var->value_D1))
				ttD2 = axlMKS2UU(sprintf(nil "%L mil" form->var->value_D2))
				ttS = axlMKS2UU(sprintf(nil "%L mil" form->var->sold_val))
			)
			drill_data = make_axlPadStackDrill(?drillDiameter ttD1 ?figure 'CIRCLE 
				?drillChar sprintf(nil "%L" ttD1) ?figureSize ttD1:ttD1 ?plating 'PLATED
			)
			cond(
				(form->var->cir_cir_hole || form->var->padtype == "padtype_via"
					figure = 'CIRCLE
					ttH = ttW
				)
				(form->var->cir_Rec_hole
					figure = 'SQUARE
					ttH = ttW
				)
				(form->var->cir_oval_hole
					figure = 'OBLONG_X
				)
				(form->var->oval_oval_hole
					figure = 'OBLONG_X
			    drill_data = make_axlPadStackDrill(?holeType 'OVAL_SLOT ?slotSize ttD2:ttD1
				    ?figure 'OBLONG_X ?drillChar sprintf(nil "%L" ttD1) ?plating 'PLATED
				  )
				)
				(form->var->nth_hole
					drill_data = make_axlPadStackDrill(?drillDiameter ttD1 ?figure 'CIRCLE 
						?drillChar sprintf(nil "%L" ttD1) ?figureSize ttD1:ttD1 ?plating 'NON_PLATED
					)
					figure = 'CIRCLE
					ttD1 = ttH
					ttW = ttH
				)
			)
			pad_list = cons(make_axlPadStackPad(?layer "TOP" ?type 'REGULAR	
				?figure figure ?figureSize ttW:ttH) nil
			)
			pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL" ?type 'REGULAR 
				?figure figure ?figureSize ttW:ttH) pad_list
			)
			pad_list = cons(make_axlPadStackPad(?layer "BOTTOM" ?type 'REGULAR 
				?figure figure ?figureSize ttW:ttH) pad_list
			)
			unless(ttS == 0
				pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_TOP" ?type 'REGULAR 
					?figure figure ?figureSize (ttW+ttS):(ttH+ttS)) pad_list
				)
				pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_BOTTOM" ?type 'REGULAR	
					?figure figure ?figureSize (ttW+ttS):(ttH+ttS)) pad_list
				)
			)
			axlDBCreatePadStack(form->var->pad_name drill_data pad_list t)
			when(axlPadstackToDisk(form->var->pad_name)
				file = strcat(form->var->pad_name ".pad")
			)
		)
	)
	file
)
)



procedure( gtopen_AutoVia()
let((form)

	form = gtopen_AutoVia_createform()
	gtopen_AutoVia_int_var(form)
	gtopen_AutoVia_update_form(form)

)
)



procedure( gtopen_AutoVia_createform()
let((form)
	
	file = strcat(gtopen_global->InstallPath "/Code/form/gtopen_AutoVia.form")
	when(boundp('AutoVia_form)
		when(axlIsFormType(eval('AutoVia_form))
			axlFormClose(eval('AutoVia_form))
		)
	)
	form = axlFormCreate('AutoVia_form file nil 'gtopen_AutoVia_CB t)
	form
)
)



procedure( gtopen_AutoVia_CB(form)
prog(()
	when(!axlOKToProceed() 
	  axlUIConfirm("Please Finish current command!") 
	  return(nil)
	)
	case(form->curField
		("viasel" | "via_svalue" | "via_space" ;| "placetype"
			evalstring(sprintf(nil "form->var->%s = %L" form->curField form->curValue))
		)
		("unitsel"
			form->var->via_svalue = axlMKSConvert(form->var->via_svalue form->var->unitsel form->curValue)
			form->var->via_space = axlMKSConvert(form->var->via_space form->var->unitsel form->curValue)
			form->var->unitsel = form->curValue
		)
		("addvias"
			if(form->var->placetype == "matrixSel" then
				axlDBCloak('gtopen_AutoVia_Matrix(form) 'shape)
			else
				gtopen_AutoVia_Side(form)
			)
		)
		(t
			return(nil)
		)
	)
	gtopen_AutoVia_update_form(form)
)
)


procedure( gtopen_AutoVia_int_var(form)
let((sels vianame)
	axlClearSelSet()
	axlSetFindFilter(?enabled list("NOALL" "invisible" "VIAS") ?onButtons list("VIAS"))
	axlAddSelectAll()
	vianame = nil
	form->viaids = nil
	foreach(n0 axlGetSelSet()
		unless(member(n0->name vianame)
			vianame = cons(n0->name vianame)
			form->viaids = cons(list(n0->name n0) form->viaids)
		)
	)
	axlClearSelSet()
	form->pop = ncons(nil)
	form->pop->viasel = vianame
	form->pop->unitsel = list("mm" "mil")
	form->pop->placetype = list(list("\276\330\325\363" "matrixSel") list("\260\345\261\337" "sideSel"))
	form->pop->gndname = rexMatchList("GND" axlDBGetDesign()->nets~>name)
	
	form->var = ncons(nil)
	form->var->via_svalue = 10.
	form->var->via_space = 100.
	form->var->viasel = car(vianame)
	form->var->unitsel = "mil"
	form->var->placetype = "matrixSel"
	form->var->gndname = car(form->pop->gndname)
	
)
)


procedure( gtopen_AutoVia_update_form(form)
let((tt)
	
	foreach(n0 form->pop->?
		tt = member(n0 form->pop)
		axlFormBuildPopup(form symbolToString(car(tt)) cadr(tt))
	)
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)
)
)


procedure( gtopen_AutoVia_Matrix(form)
let((tt sels visfirst keepinshape M_xy ttSP v_x v_xs v_y v_ys via_xys mypath viapoly polysels)
	
	visfirst = axlVisibleGet()
	axlVisibleDesign(nil)	
	axlVisibleLayer("ROUTE KEEPIN/ALL" t)
	axlSetFindFilter(?enabled '("noall" "shapes") ?onButtons '("ALLTYPES"))
	axlAddSelectAll()
	keepinshape = car(axlGetSelSet())
	axlClearSelSet()
	tt = axlMXYAdd(car(keepinshape->bBox) cadr(keepinshape->bBox))
	M_xy = axlMXYMult(tt 0.5)
	if(form->var->unitsel == "mm" then
		ttSP = axlMKS2UU(sprintf(nil "%.2f mm" form->var->via_svalue))
		ttSV = axlMKS2UU(sprintf(nil "%.2f mm" form->var->via_space))
	else
		ttSP = axlMKS2UU(sprintf(nil "%L mil" form->var->via_svalue))
		ttSV = axlMKS2UU(sprintf(nil "%L mil" form->var->via_space))
	)
	v_x = car(M_xy)
	v_xs = list(car(M_xy))
	while(caar(keepinshape->bBox) < v_x
		v_x = v_x - ttSV
		v_xs = cons(v_x v_xs)
	)
	v_xs = reverse(v_xs)
	v_x = car(M_xy)
	while(caadr(keepinshape->bBox) > v_x
		v_x = v_x + ttSV
		v_xs = cons(v_x v_xs)
	)
	v_y = cadr(M_xy)
	v_ys = list(cadr(M_xy))
	while(cadr(car(keepinshape->bBox)) < v_y
		v_y = v_y - ttSV
		v_ys = cons(v_y v_ys)
	)
	v_ys = reverse(v_ys)
	v_y = cadr(M_xy)
	while(cadr(cadr(keepinshape->bBox)) > v_y
		v_y = v_y + ttSV
		v_ys = cons(v_y v_ys)
	)
	
	via_xys = nil
	foreach(n0 v_xs
		foreach(n1 v_ys
			when(axlGeoPointInShape(list(n0 n1) keepinshape)
				via_xys = cons(list(n0 n1) via_xys)
			)
		)
	)
	axlVisibleDesign(nil)	
	foreach(layer axlSubclasses("ETCH")
    axlVisibleLayer(strcat("ETCH/" layer) t)
    axlVisibleLayer(strcat("PIN/" layer) t)
    axlVisibleLayer(strcat("VIA CLASS/" layer) t)
    axlVisibleLayer(strcat("ROUTE KEEPOUT/" layer) t)
    axlVisibleLayer(strcat("VIA KEEPOUT/" layer) t)
	)
	axlVisibleLayer("ROUTE KEEPOUT/ALL" t)
	axlVisibleLayer("VIA KEEPOUT/ALL" t)
	axlSetFindFilter(?enabled '("noall" "vias" "pins" "clinesegs" "shapes") ?onButtons '("ALLTYPES"))
	tt = cadr(assoc(form->var->viasel form->viaids))
	tt = axlMXYSub(cadr(tt->bBox) car(tt->bBox))
	M_xy = axlMXYAdd(axlMXYMult(tt 0.5) ttSP:ttSP)
	foreach(n0 via_xys
		axlSingleSelectBox(list(axlMXYSub(n0 M_xy) axlMXYAdd(n0 M_xy)))
		sels = axlGetSelSet()
		axlClearSelSet()
		sels = setof(x0 sels ((x0->objType == "shape" && x0->net->name == form->var->gndname) == nil))
		if(sels then
			tt = list(car(n0)-car(M_xy) cadr(n0))
			mypath = axlPathStart(list(tt))
			mypath = axlPathArcCenter(mypath 0 tt t n0)
			viapoly = axlPolyFromDB(mypath)
			foreach(n1 sels
				polysels = axlPolyFromDB(n1)
				when(n1->net->prop->LINE_TO_THRUVIA_SPACING
					polysels = axlPolyExpand(polysels axlMKS2UU(n1->net->prop->LINE_TO_THRUVIA_SPACING) 'ALL_ARC)
				)
				when(axlPolyOperation(polysels viapoly 'AND)
					via_xys = remd(n0 via_xys)
				)
			)
		)
	)
	foreach(n0 via_xys
		axlDBCreateVia(form->var->viasel n0 form->var->gndname)
	)
	axlVisibleSet(visfirst)
)
)

procedure( gtopen_AutoVia_Side(form)
let((tt)
	t
)
)

axlCmdRegister("gtopen_CutClines_Lines" 'gtopen_CutClines_Lines ?cmdType "general")
procedure( gtopen_CutClines_Lines()
let((tt tt0 minleng mypopup sels mypath poly0 linesets poly1 mark)
	axlCancelEnterFun()
	mark = axlDBTransactionStart()
	minleng = expt(0.1 cadr(axlDBGetDesignUnits()))
	mypopup = axlUIPopupDefine(nil;axlUIGetUserData()->popupId
		list(
			list("Done" "axlDBTransactionCommit(mark) axlUIPopupSet(nil) axlFinishEnterFun()")
	    list("Oops" "axlDBTransactionOops(mark)")
	    list("Cancel" "axlDBTransactionRollback(mark) axlUIPopupSet(nil) axlCancelEnterFun()")
		)
	)
	axlSetFindFilter(?enabled '("NOALL" "CLINESEGS" "LINESEGS") ?onButtons '("all"))
	axlClearSelSet()
	axlUIPopupSet(mypopup)
	while(selbox = axlEnterBox()
		axlUIPopupSet(mypopup)
		axlDBTransactionMark(mark)
	  axlSingleSelectBox(selbox)
	  sels = axlGetSelSet()
		axlClearSelSet()
		foreach(n0 sels
			mypath = axlMakeDynamicsPath(list(
				list(xCoord(selbox) list(xCoord(xCoord(selbox)) yCoord(yCoord(selbox))) 0.)
				list(list(xCoord(xCoord(selbox)) yCoord(yCoord(selbox))) yCoord(selbox) 0.)
				list(yCoord(selbox) list(xCoord(yCoord(selbox)) yCoord(xCoord(selbox))) 0.)
				list(list(xCoord(yCoord(selbox)) yCoord(xCoord(selbox))) xCoord(selbox) 0.)
			))
			poly0 = axlPolyFromDB(mypath)
			linesets = nil
			poly1 = axlPolyFromDB(n0)
			foreach(n1 axlPolyOperation(poly1 poly0 'ANDNOT)
				tt = setof(x0 n1->vertices (member(x0 car(poly1)->vertices) == nil))
				tt0 = setof(x0 n1->vertices (member(x0 car(poly1)->vertices) != nil))
				when(tt0
					linelang = axlDistance(caar(tt) caar(tt0))
					tt = axlMXYSub(car(n0->startEnd) caar(tt0))
					when(abs(car(tt)) + abs(cadr(tt)) <= minleng*2 + n0->width
						linexy0 = car(n0->startEnd)
						linexy1 = axlMUniVector(linexy0 cadr(n0->startEnd) linelang)
						linesets = cons(list(linexy0 linexy1) linesets)
					)
					tt = axlMXYSub(cadr(n0->startEnd) caar(tt0))
					when(abs(car(tt)) + abs(cadr(tt)) <= minleng*2 + n0->width
						linexy0 = cadr(n0->startEnd)
						linexy1 = axlMUniVector(linexy0 car(n0->startEnd) linelang)
						linesets = cons(list(linexy0 linexy1) linesets)
					)
				)
			)
			tt = ncons(nil)
			tt->width = n0->width
			tt->layer = n0->layer
			tt->netname = n0->net->name
			axlDeleteObject(n0)
			unless(tt->parent->?
				tt->parent = nil
			)
			foreach(n1 linesets
				axlDBCreateLine(n1 tt->width tt->layer tt->netname tt->parent)
			)
		)
	)
	axlDBRefreshId(nil)
	axlDBTransactionCommit(mark)
	axlUIPopupSet(nil)
)
)

