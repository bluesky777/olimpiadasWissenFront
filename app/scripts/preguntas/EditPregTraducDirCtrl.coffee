angular.module('WissenSystem')

.controller('EditPregTraducDirCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'toastr', '$filter', '$uibModal', 'App',
	($scope, $http, Restangular, $state, $cookies, $rootScope, toastr, $filter, $modal, App) ->


		txtNewOpcion = 'Agregar nueva opción'

		if !$scope.pregunta_traduc
			$scope.pregunta_traduc = $scope.preguntaEdit

		$scope.inicializar = ()->

			for opci in $scope.pregunta_traduc.opciones
				if opci.nueva
					return

			newOpcion =
				id: -1
				definicion: txtNewOpcion
				nueva: true
				is_correct: false

			$scope.pregunta_traduc.opciones.push newOpcion

		$scope.inicializar()


		# Configuración para el sortable
		$scope.sortableOptions =
			'ui-floating': true

			update: (e, ui)->
				# console.log e, ui

				sortHash = []

				for opcion, index in $scope.pregunta_traduc.opciones
					if opcion.id != -1
						hashEntry = {}
						hashEntry["" + opcion.id] = index
						sortHash.push(hashEntry)

				datos =
					pregunta_traduc_id: $scope.pregunta_traduc.id
					sortHash: sortHash

				Restangular.one('opciones/update-orden').customPUT(datos).then((r)->
					console.log('Orden guardado')
				, (r2)->
					console.log('No se pudo guardar el orden', r2)
					#ui.item.sortable.cancel() # Cancelamos el intento de ordenar
				)




		$scope.addButtonNewOpcion = (preg, opt)->

			opt.creando = true

			if opt.nueva

				opt.definicion = 'Opción ' + preg.opciones.length
				opt.preg_traduc_id = preg.pg_traduc_id
				opt.orden = preg.opciones.length - 1

				if preg.opciones.length == 1
					opt.is_correct = true


				Restangular.one('opciones/store').customPOST(opt).then((r)->
					console.log('Opción guardada')

					opt.id        = r.id
					opt.rowid     = r.rowid
					opt.nueva     = false
					opt.creando   = false


					# Agregamos la nueva opción para que sea el botón NUEVA OPCIÓN
					tempOpcion =
						id: -1
						definicion: txtNewOpcion
						nueva: true # Inicialmente es true para que sea una especie de botón, NUEVA OPCIÓN
						is_correct: false
					preg.opciones.push tempOpcion

				, (r2)->
					console.log('No se pudo guardar la opción', r2)
					opt.definicion = txtNewOpcion # Volvemos a poner el texto de tipo botón
					opt.creando = false
					toastr.warning('No se pudo crear nueva opción')
				)




		$scope.setAsCorrect = (preg, opt)->
			if $scope.preguntaEdit.tipo_pregunta == 'Test'
				angular.forEach preg.opciones, (opcion)->  # Solo puede haber una correcta, así que quitamos las otras.
					opcion.is_correct = 0

				opt.is_correct = 1


			if $scope.preguntaEdit.tipo_pregunta == 'Multiple'
				opt.is_correct = 1  # Pueden haber muchas correctas, así que simplemente la estrablecemos correcta sin importar si hay alguna otra como correcta.


		$scope.deleteOption = (preg, opt, indice)->
			ele_id  = if opt.rowid then opt.rowid else opt.id
			prome   = {};

			if opt.rowid
				prome = Restangular.all('opciones/destroy').customPUT({rowid: ele_id})
			else
				prome = Restangular.all('opciones/destroy').customDELETE(ele_id)

			prome.then((r)->
				elem_id = if opt.rowid then opt.rowid else opt.id
				dato = {}

				if opt.rowid
					dato.rowid = '!'+elem_id
				else
					dato.id = '!'+elem_id

				preg.opciones = $filter('filter')(preg.opciones, dato)
			, (r2)->
				console.log('No se pudo eliminar la opción', r2)
				toastr.warning 'No se pudo eliminar la opción'
			)


		$scope.$on 'cambiaTipoPregunta', ()->

			if $scope.preguntaEdit.tipo_pregunta == 'Test'

				for preg_trad in $scope.preguntaEdit.preguntas_traducidas
					correctas = 0
					for opcion in preg_trad.opciones  # Solo puede haber una correcta, así que quitamos todas menos una.

						if opcion.is_correct
							if correctas > 0
								opcion.is_correct = 0
							else
								correctas = correctas + 1


		$scope.misImagenes = ()->

			modalInstance = $modal.open({
				templateUrl: App.views + 'preguntas/misImagenes.tpl.html'
				controller: 'MisImagenes'
				size: 'lg',
				resolve:
					resolved_user: ()->
						$scope.USER
			})
			modalInstance.result.then( (elem)->
				console.log 'Fin mis imágenes'
			)

	]
)




