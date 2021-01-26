arreglo = #()
objeto = #()
rollout gridMaker "Grid Maker v0" width:232 height:384
(
	GroupBox 'planeCreator' "Plane Creator" pos:[8,8] width:216 height:168 align:#left
	button 'crear' "Create" pos:[24,144] width:56 height:24 align:#left
	button 'volver' "Undo" pos:[152,144] width:56 height:24 align:#left
	label 'labelDistancia' "Distance between planes:" pos:[16,40] width:128 height:16 align:#left
	label 'labelAltura' "Plane Height:" pos:[16,64] width:128 height:16 align:#left
	label 'labelAncho' "Plane Width:" pos:[16,88] width:120 height:16 align:#left
	spinner 'largoSpinner' "" pos:[152,64] width:64 height:16 range:[0,1000,200] align:#left
	spinner 'anchoSpinner' "" pos:[152,88] width:64 height:16 range:[0,1000,200] align:#left
	label 'labelCantidadPlanos' "Number of planes per axis:" pos:[16,112] width:144 height:16 align:#left
	spinner 'numero' "" pos:[152,111] width:64 height:16 range:[0,200,10] type:#integer align:#left
	spinner 'distanciaSpinner' "" pos:[152,40] width:63 height:16 range:[0,200,10] type:#integer align:#left
	button 'seleccionarTodo' "Select All" pos:[88,144] width:56 height:24 align:#left
	GroupBox 'gridCreator' "Grid Creator" pos:[8,184] width:216 height:192 align:#left
	button 'gridCreate' "Create grid on current object" pos:[32,312] width:168 height:22 align:#left
		
		
	listbox 'testList' "" pos:[112,208] width:104 height:4 align:#left
	button 'addToList' "Select object" pos:[16,208] width:88 height:24 align:#left
	
	label 'labelRadio' "Radio:" pos:[24,280] width:42 height:24 align:#left
	spinner 'radioSplineSpinner' "" pos:[64,280] width:72 height:16 range:[0,10,1.5] type:#float align:#left
	button 'deselectBtn' "Deselect object" pos:[16,240] width:88 height:24 align:#left

	button 'gridMeshCreate' "Create grid mesh" pos:[32,344] width:168 height:24 align:#left
	
	on crear pressed do
	(	
		/*discancia en mm entre planos*/ 
		/*distancia = 10*/ 
		/*largo=100*/
		/*ancho=100*/
		distancia = distanciaSpinner.value
		largo = largoSpinner.value
		ancho = anchoSpinner.value
		
		for i = 0 to numero.value do(
			
			join arreglo #(Plane length:largo width:ancho transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,distancia*i,0]) isSelected:off)
			join arreglo #(Plane length:largo width:ancho transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,-distancia*i,0]) isSelected:off)
			join arreglo #(Plane length:largo width:ancho transform:(matrix3 [0,-1,0] [0,0,1] [-1,0,0] [distancia*i,0,0]) isSelected:off)
			join arreglo #(Plane length:largo width:ancho transform:(matrix3 [0,-1,0] [0,0,1] [-1,0,0] [-distancia*i,0,0]) isSelected:off)
			join arreglo #(Plane length:largo width:ancho pos:[0,0,distancia*i] isSelected:off)
			join arreglo #(Plane length:largo width:ancho pos:[0,0,-distancia*i] isSelected:off)
		)
	)
	on volver pressed do
	(
		select arreglo
		actionMan.executeAction 0 "40020"
		arreglo = #()
	)
	on seleccionarTodo pressed do
	(
		select arreglo
		print arreglo
	)
	on gridCreate pressed do
	(
		if objeto.count >0 do(
		print objeto[1]
		ProBoolean.SetOperandA objeto[1]
		ProBoolean.SetBoolOp objeto[1] 1
		ProBoolean.SetImprint objeto[1] true
		for j = 1 to arreglo.count do(
			ProBoolean.setOperandB objeto[1] arreglo[j] 1 0
			)
		)
	)
	on addToList pressed do
	(
		objeto = Selection as array
		/*print objeto[1]*/
		if objeto.count >0 do(
		objName = selection[1].name
		if testList.items[1] != objName do(
			testList.items = append testList.items (selection[1].name as string)
			)
		)
	)
	on deselectBtn pressed do
	(
			objeto = #()
			  if testList.items.count > 0 and testList.selection > 0 do (
				testList.items = deleteItem testList.items testList.selection
				)
			)
	on gridMeshCreate pressed do
	(
			select objeto[1]
			max modify mode
			modPanel.addModToSelection (Edit_Poly ()) ui:on
			subobjectLevel = 2
			$.modifiers[#Edit_Poly].ButtonOp #CreateShape
			$.modifiers[#Edit_Poly].CreateShape "grilla"
			subobjectLevel = 0
			select $Shape
			actionMan.executeAction 0 "40020"
			select $grilla
			convertToSplineShape $grilla
			$grilla.render_displayRenderMesh = true
			$grilla.render_thickness = radioSplineSpinner.value
			$grilla.render_sides = 6
			convertTo $grilla PolyMeshObject
			clearSelection()
			)
)

CreateDialog gridMaker width:232 height:384