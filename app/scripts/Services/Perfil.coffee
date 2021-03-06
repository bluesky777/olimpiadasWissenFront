angular.module('WissenSystem')

.factory('Perfil', ['Restangular', 'App', '$q', '$cookies', '$rootScope', 'AUTH_EVENTS', '$http', (Restangular, App, $q, $cookies, $rootScope, AUTH_EVENTS, $http) ->

	user = {}
	resourceId = 0

	setUser: (usuario) ->
		user = usuario

	User: ->
		return user

	id: ->
		user.user_id
	idioma: ->
		user.idioma_main_id

	setImagen: (imagen_id, imagen_nombre)->
		user.imagen_id = imagen_id
		user.imagen_nombre = imagen_nombre

	setResourceId: (resId)->
		resourceId = resId

	getResourceId: ()->
		resourceId

	setRegistered: (registered_boolean)->
		user.registered = registered_boolean

	getRegistered: ()->
		user.registered

	deleteUser: ()->
		user = {}

])