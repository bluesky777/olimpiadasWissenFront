angular.module('WissenSystem')

.controller('EventosCtrl', ['$scope', 'Restangular', '$uibModal', '$filter', 'App', 'toastr',  ($scope, Restangular, $modal, $filter, App, toastr)->

	$scope.newEvent = {
		with_pay:         0
		es_idioma_unico:  1
		precio1: 					2000
		precio2: 					3000
		precio3: 					4000
		precio4: 					5000
		precio5: 					5000
		precio6: 					5000
	}
	$scope.currentEvent = {
		idiomas_extras: []
	}


	$scope.creando = false
	$scope.editando = false

	$scope.guardando_nuevo = false
	$scope.guardando_edit = false

	$scope.cambiarGranFinal = (currentEvent)->
		gran_final = 0

		if currentEvent.gran_final == false or currentEvent.gran_final == 'false' or currentEvent.gran_final == 0 or currentEvent.gran_final == '0'
			gran_final 	= 1

		id = if currentEvent.rowid then currentEvent.rowid else currentEvent.id
		Restangular.one('eventos/set-gran-final').customPUT({id: id, gran_final}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			toastr.warning 'No se pudo cambiar.', 'Problema'
		)




	$scope.guardar_evento = ()->

		$scope.guardando_nuevo = true

		Restangular.one('eventos/store').customPOST($scope.newEvent).then((r)->

			r.idiomas_extras = $scope.newEvent.idiomas_extras
			$scope.USER.eventos.push r
			$scope.guardando_nuevo = false
			$scope.creando = false
			toastr.success 'Evento guardado con éxito.', 'Creado'

			# Reiniciamos las variables del nuevo evento.
			$scope.newEvent = {
				with_pay: false
			}
		, (r2)->
			console.log('No se pudo guardar el evento', r2)
			toastr.warning 'No se pudo crear evento.', 'Problema'
			$scope.guardando_nuevo = false
		)
		# Actualizamos los datos por si es el evento actual
		$scope.el_evento_actual()



	$scope.setActual = (evento)=>
		Restangular.one('eventos/set-evento-actual').customPUT(evento).then((r)->
			toastr.success 'Ahora el Evento es actual.'

			for even in $scope.USER.eventos
				even.actual = false

			evento.actual = true

		(r2)->
			toastr.warning 'No se pudo establecer como actual. Actualice', 'Problema'
		)




	$scope.update_evento = ()->

		$scope.guardando_edit = true

		console.log $scope.currentEvent.gran_final

		Restangular.one('eventos/update').customPUT($scope.currentEvent).then((r)->
			console.log 'Evento editado', r
			$scope.guardando_edit = false
			toastr.success 'Evento actualizado con éxito.'
		(r2)->
			console.log 'El Evento no se pudo editar', r2
			toastr.warning 'No se pudo editar evento.', 'Problema'
			$scope.guardando_edit = false
		)
		# Actualizamos los datos por si es el evento actual
		$scope.el_evento_actual()



	$scope.crear_evento = ()->
		$scope.editando = false
		$scope.creando = true

	$scope.cancelar_newevento = ()->
		$scope.creando = false

	$scope.cancelar_currentEvento = ()->
		$scope.editando = false


	$scope.editarEvento = (evento)->
		$scope.editando = true
		$scope.currentEvent = evento
		console.log 'currentEvent', evento



	$scope.quitandoIdiomas = (item, model)->

		console.log item
		datos =
			evento_id: $scope.currentEvent.id
			idioma_id: item.id

		Restangular.one('idiomas/destroy').customDELETE('', datos).then((r)->
			toastr.success 'Idioma quitado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar idioma.', 'Problema'
			console.log 'Error eliminando idioma: ', r2
		)

		# Actualizamos los datos por si es el evento actual
		$scope.el_evento_actual()



	$scope.idiomasSelect = (item, model)->
		console.log item, $scope.currentEvent.idiomas_extras
		datos =
			evento_id: $scope.currentEvent.id
			idioma_id: item.id

		Restangular.one('idiomas/store').customPOST(datos).then((r)->
			toastr.success 'Idioma agregado con éxito.', 'Añadido'
		, (r2)->
			toastr.warning 'No se pudo agregar idioma.', 'Problema'
			console.log 'Error agregando idioma: ', r2
		)
		# Actualizamos los datos por si es el evento actual
		$scope.el_evento_actual()


	$scope.eliminarEvento = (evento)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'eventos/removeEvento.tpl.html'
			controller: 'RemoveEventoCtrl'
			resolve:
				elemento: ()->
					evento
		})
		modalInstance.result.then( (elem)->
			$scope.USER.eventos = $filter('filter')($scope.USER.eventos, {id: '!'+elem.id})
			console.log 'Resultado del modal: ', elem
		)
		# Actualizamos los datos por si es el evento actual
		$scope.el_evento_actual()


	# Actualizo los eventos con la función del controlador ApplicationController
	$scope.traerEventos()

])

.controller('RemoveEventoCtrl', ['$scope', '$uibModalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento

	$scope.elemento_id 	= if elemento.rowid then elemento.rowid else elemento.id

	$scope.ok = ()->

		Restangular.all('eventos/destroy').customDELETE($scope.elemento_id).then((r)->
			toastr.success 'Evento eliminado con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			console.log 'Error eliminando elemento: ', r2
			$modalInstance.dismiss('cancel')
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


