angular.module('WissenSystem')

.controller('ViewPreguntaExamenCtrl', ['$scope', 'Restangular', 'toastr', '$filter', '$rootScope', '$state', '$uibModal', 'App', 'MySocket', 'hotkeys', '$sce', ($scope, Restangular, toastr, $filter, $rootScope, $state, $modal, App, MySocket, hotkeys, $sce)->


	$scope.USER = $scope.$parent.USER

	$scope.idioma = $scope.USER.idioma_main_id

	$scope.examen_actual = $rootScope.examen_actual


	$scope.trustedHtml = (plainText)->
		return $sce.trustAsHtml(plainText);



	hotkeys.bindTo($scope)
		.add({
			combo: ['a', 'A', '1', 'b', 'B', '2', 'c', 'C', '3', 'd', 'D', '4', 'e', 'E', '5', 'f', 'F', '6'],
			description: 'Elegir opción',
			callback: (argu, argu2)->

				if $scope.modal_abierto
					return

				tecla = argu.key

				la_preg = $filter('porIdioma')($scope.preguntaking.preguntas_traducidas, $scope.idiomapreg)

				if la_preg
					if la_preg.length > 0
						la_preg = la_preg[0]

						for opci, indice in la_preg.opciones

							if (['a', 'A', '1'].indexOf(tecla) > -1) and (indice==0)
								$scope.elegirOpcion(la_preg, opci, indice)
							else if ((['b', 'B', '2'].indexOf(tecla) > -1) and (indice==1))
								$scope.elegirOpcion(la_preg, opci, indice)
							else if ((['c', 'C', '3'].indexOf(tecla) > -1) and (indice==2))
								$scope.elegirOpcion(la_preg, opci, indice)
							else if ((['d', 'D', '4'].indexOf(tecla) > -1) and (indice==3))
								$scope.elegirOpcion(la_preg, opci, indice)
							else if ((['e', 'E', '5'].indexOf(tecla) > -1) and (indice==4))
								$scope.elegirOpcion(la_preg, opci, indice)
							else if ((['f', 'F', '6'].indexOf(tecla) > -1) and (indice==5))
								$scope.elegirOpcion(la_preg, opci, indice)
		})


	$scope.elegirOpcion = (pregunta, opcion, indice)->

		$scope.modal_abierto = true

		angular.forEach pregunta.opciones, (opt)->
			opt.elegida = false

		opcion.elegida = true



		if $scope.examen_actual.one_by_one

			opcion.letra = $scope.indexChar(indice)

			modalInstance = $modal.open({
				animation: false
				templateUrl: App.views + 'examen_respuesta/seguroRespuesta.tpl.html'
				controller: 'SeguroRespuestaPregKingCtrl'
				resolve:
					preguntatop: ()->
						$scope.preguntaking
					pregunta_traduc: ()->
						pregunta
					opcion: ()->
						opcion
					examen_actual: ()->
						$scope.examen_actual
					agrupada: ()->
						return false
			})
			modalInstance.result.then( (option)->
				$scope.modal_abierto = false
				opcion.respondida = true

				#if option == 'Ya respondida'
					#toastr.warning('No guardada', 'Respondida anteriormente');

				if opcion.is_correct
					valor = 'correct'
					if option != 'Ya respondida'
						toastr.info('Respuesta CORRECTA');
				else
					valor = 'incorrect'
					if option != 'Ya respondida'
						toastr.info('Respuesta INCORRECTA', {
							iconClass: 'toast-pink'
						});

				$scope.$emit 'respuesta_elegida', indice, valor
				MySocket.sc_answered valor, $rootScope.tiempo, $scope.preguntaking.puntos


			)




	$scope.toggleMostrarAyuda = (pregunta)->
		pregunta.mostrar_ayuda = !pregunta.mostrar_ayuda



	$scope.indexChar = (index)->
		return String.fromCharCode(65 + index)




])




.directive('viewPreguntaExamen',['App', (App)->

	restrict: 'E'
	templateUrl: "#{App.views}examen_respuesta/viewPreguntaExamenDir.tpl.html"
	scope:
		preguntaking: 	"="
		indice: 		"="
		idiomapreg:		"="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: 'ViewPreguntaExamenCtrl'


])




.controller('SeguroRespuestaPregKingCtrl', ['$scope', '$uibModalInstance', 'opcion', 'Restangular', 'toastr', '$filter', 'examen_actual', 'preguntatop', 'pregunta_traduc', 'agrupada', '$rootScope', 'hotkeys', ($scope, $modalInstance, opcion, Restangular, toastr, $filter, examen_actual, preguntatop, pregunta_traduc, agrupada, $rootScope, hotkeys)->

	$scope.opcion 			= opcion
	$scope.examen_actual 	= examen_actual

	###
	hotkeys.bindTo($scope)
		.add({
			combo: 'enter',
			description: 'Aceptar respuesta',
			callback: ()->
				$scope.ok()
		})
	###



	$scope.ok = ()->
		if $scope.guardando
			return

		$scope.guardando 		= true
		$rootScope.pause_tiempo = true

		if $scope.start_to_save?
			# nada
		else
			$scope.start_to_save 	= Date.now()


		datos =
			examen_actual_id: 		examen_actual.examen_id
			pregunta_top_id: 		preguntatop.rowid         || preguntatop.id
			pregunta_sub_id: 		pregunta_traduc.rowid     || pregunta_traduc.id
			idioma_id: 				  pregunta_traduc.idioma_id
			tipo_pregunta: 			preguntatop.tipo_pregunta
			opcion_id: 				  opcion.rowid              || pregunta_traduc.id
			tiempo:					Date.now() - $rootScope.dt_start_preg


		pregking 	= 'examenes_respuesta/responder-pregunta'
		grupopreg 	= 'examenes_respuesta/responder-pregunta-agrupada'

		ruta = if agrupada then grupopreg else pregking

		Restangular.all(ruta).customPUT(datos).then((r)->
			$rootScope.pause_tiempo = false
			$rootScope.tiempo_preg 	= 0
			$scope.guardando 		= false

			diff_saving_preg = Date.now() - $scope.start_to_save

			$rootScope.dt_start_exam = $rootScope.dt_start_exam + diff_saving_preg 	# Sumamos el tiempo de espera para que el reloj continue correctamente
			$rootScope.dt_start_preg = Date.now()									# Reinicio el tiempo de pregunta


			$modalInstance.close(r)
		, (r2)->
			$rootScope.pause_tiempo = true
			$scope.guardando 		= false
			toastr.warning 'No se pudo guardar respuesta.', 'Problema'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



