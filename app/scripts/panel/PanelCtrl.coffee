'use strict'

angular.module('WissenSystem')

.controller('PanelCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'toastr', '$translate', '$filter', '$uibModal', 'MySocket', 'Fullscreen' 
	($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user, toastr, $translate, $filter, $modal, MySocket, Fullscreen) ->


		$scope.USER = resolved_user
		#console.log '$scope.USER', $scope.USER
		$scope.imagesPath = App.images

		hoy = new Date().toJSON().slice(0,10)
		
		$scope.dataExport = {
			#fecha_ini: new Date(hoy + ' 00:00:0000')
			fecha_ini: new Date('2017-07-19 00:00:0000')
			fecha_fin: new Date(hoy + ' 23:59:0000')
		}

		AuthService.verificar_acceso()





		# Aquí exportaremos datos.
		$scope.floatingSidebar = false
		$scope.toggleFloatingSidebar = ()->
			$scope.floatingSidebar = if $scope.floatingSidebar then false else true
			$scope.cargarExamenesExport()

		$scope.cargarExamenesExport = ()->
			Restangular.one('exportar-importar/ver-cambios').customPUT({ fecha_ini: $scope.dataExport.fecha_ini, fecha_fin: $scope.dataExport.fecha_fin }).then((r)->
				$scope.export_participantes = r
			(r2)->
				toastr.warning 'No se trajeron datos para exportar '
			)

		$scope.exportarExcel = ()->
			Restangular.one('exportar-importar/exportar-excel').withHttpConfig({responseType: 'blob'}).customPUT({ fecha_ini: $scope.dataExport.fecha_ini, fecha_fin: $scope.dataExport.fecha_fin }).then((r)->
				blob = new Blob([r], {type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
				objectUrl = URL.createObjectURL(blob);
				window.open(objectUrl);
				toastr.success 'Exportado'
			(r2)->
				toastr.warning 'No se pudo exportar '
				console.log r2
			)





		$rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
			$scope.cambiarTema('theme-zero')


		$rootScope.$on 'categ_selected_change', (event, categsel)->
			$scope.USER.categsel = categsel

		
		$rootScope.reload = ()->
			$state.go $state.current, $stateParams, {reload: true}

		$scope.setFullScreen = ()->
			Fullscreen.toggleAll()


		$scope.openMenu = ($mdOpenMenu, ev)->
			originatorEv = ev
			$mdOpenMenu(ev)

		$scope.cambiarIdioma = (idioma)->
			

			Restangular.one('idiomas/cambiar-idioma').customPUT({idioma_id: idioma.id}).then((r)->
				$translate.use(idioma.abrev)
				$scope.USER.idioma_main_id = idioma.id

				$scope.idiomas_del_sistema()

				for idiom in $scope.idiomas_usados
					idiom.actual = if idiom.abrev == idioma.abrev then true else false


				toastr.success 'Idioma cambiado por ' + idioma.abrev
			(r2)->
				console.log 'No se pudo cambiar el idioma.', r2
			)
			


			
		$scope.set_system_event = (evento)->
			Restangular.one('eventos/set-evento-actual').customPUT({'id': evento.id}).then((r)->
				console.log 'Evento cambiado: ', r

				angular.forEach $scope.USER.eventos, (eventito, key) ->
					eventito.actual = false

				evento.actual = true
				
				toastr.success 'Evento actual cambiado por ' + evento.alias

			, (r2)->
				console.log 'Error conectando!', r2
				toastr.warning 'No se pudo cambiar el evento actual.'

			)



		$scope.evento_actual = {}

		# Función para establecer en el frontend el evento actual del usuario
		$scope.el_evento_actual = ()->

			if $scope.USER
				if AuthService.isAuthorized('can_work_like_admin') or AuthService.isAuthorized('like_asesor')
					try

						$scope.evento_actual = $filter('filter')($scope.USER.eventos, {id: $scope.USER.evento_selected_id})[0]

					catch
						$scope.evento_actual = {}
					finally
						$rootScope.$broadcast 'cambia_evento_actual'
				else
					$scope.evento_actual = $scope.USER.evento_actual

		$scope.el_evento_actual()


			
		$scope.set_user_event = (evento)->
			Restangular.one('eventos/set-user-event').customPUT({'evento_id': evento.id}).then((r)->
				console.log 'Evento cambiado: ', r

				$scope.USER.evento_selected_id = evento.id
				$scope.el_evento_actual() # Actualizamos el modelo del evento actual
				toastr.success 'Evento actual cambiado por ' + evento.alias

				$rootScope.$broadcast 'cambio_evento_user' # Anunciamos el cambio de evento.

			, (r2)->
				console.log 'Error conectando!', r2
				toastr.warning 'No se pudo cambiar el evento actual.'

			)

		$scope.logout = ()->
			MySocket.unregister()
			AuthService.logout()
			$scope.in_evento_actual = {}

			Restangular.one('login/logout').customPUT().then((r)->
				console.log 'Desconectado con éxito: ', r
			, (r2)->
				console.log 'Error desconectando!', r2
			)

			#$state.go 'login'




		# Traemos los eventos
		$scope.traerEventos = ()->
			Restangular.all('eventos').getList().then((r)->
				$scope.USER.eventos = r
				$scope.el_evento_actual()
			(r2)->
				console.log 'No se trajeron los eventos.'
			)


				
		return
	]
)


