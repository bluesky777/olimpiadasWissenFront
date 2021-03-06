angular.module('WissenSystem')

.controller('NivelesCtrl', ['$scope', 'Restangular', 'toastr', '$uibModal', 'App', '$filter',  ($scope, Restangular, toastr, $modal, App, $filter)->


	$scope.creando = false




	$scope.traer_niveles = ()->
		Restangular.all('niveles/niveles-usuario').getList().then((r)->

			for nivel in r
				nivel.idiomasEdit = [$scope.eventoactual.idioma_principal_id]

			$scope.nivelesking = r

		, (r2)->
			toastr.warning 'No se trajeron las niveles', 'Problema'
			console.log 'No se trajo niveles ', r2
		)
	$scope.traer_niveles()

	$scope.$on 'cambio_evento_user', ()->
		$scope.traer_niveles()



	$scope.crear_nivel = ()->
		$scope.creando = true

		Restangular.one('niveles/store').customPOST().then((r)->
			r.editando    = true
			r.idiomasEdit = [$scope.eventoactual.idioma_principal_id]
			$scope.nivelesking.push r
			$scope.creando = false
			console.log(r)
		, (r2)->
			toastr.warning 'No se creó el nivel', 'Problema'
			$scope.creando = false
		)


	$scope.cerrar_edicion = (nivelking)->
		nivelking.editando = false


	$scope.editarNivel = (nivelking)->
		nivelking.editando = true


	$scope.eliminarNivel = (nivelking)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'categorias/removeNivel.tpl.html'
			controller: 'RemoveNivelCtrl'
			resolve:
				elemento: ()->
					nivelking
		})
		modalInstance.result.then( (elem)->
			dato = {}
			if elem.rowid
				dato.rowid = elem.rowid
			else
				dato.id = elem.id

			$scope.nivelesking = $filter('filter')($scope.nivelesking, dato, (actual, expected)=> return (actual != expected))

		)


	$scope.finalizar_edicion = (nivelking)->
		$scope.guardando(nivelking)
		nivelking.editando = false

	$scope.guardando = (nivelking)->
		Restangular.all('niveles/guardar').customPUT(nivelking).then((r)->
			toastr.success 'Nivel guardada.'
			console.log 'Nivel guardada: ', r
		, (r2)->
			toastr.warning 'No se pudo guardar el nivel', 'Problema'
			console.log 'No se pudo guardar el nivel ', r2
		)


])



.controller('RemoveNivelCtrl', ['$scope', '$uibModalInstance', 'elemento', 'Restangular', 'toastr', ($scope, $modalInstance, elemento, Restangular, toastr)->
	$scope.elemento = elemento
	console.log 'elemento', elemento

	$scope.ok = ()->
		ele_id  = if elemento.rowid then elemento.rowid else elemento.id
		prome   = {};

		if elemento.rowid
			prome = Restangular.all('niveles/destroy').customPUT({rowid: ele_id})
		else
			prome = Restangular.all('niveles/destroy').customDELETE(ele_id)

		prome.then((r)->
			toastr.success 'Nivel eliminado con éxito.', 'Eliminado'
			$modalInstance.close(elemento)
		, (r2)->
			toastr.warning 'No se pudo eliminar al elemento.', 'Problema'
			$modalInstance.dismiss('Error')
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



