'use strict'

###
$(window).load(()->
    tiempo = setInterval(()->
        console.log "h"
        #$(".fr-box:not(.fr-wrapper .fr-toolbar)")[0].remove()
    , 1000);
)
###


angular.module("WissenSystem")

.controller('MainCtrl', ['$scope', ($scope)->

	console.log 'A cambiar desde main'
	#$window.location.href = 'http://localhost/myvc/public';

	return
])


.controller('LandingCtrl', ['$scope', ($scope)->

	#console.log 'A cambiar desde main'
	#$window.location.href = 'http://localhost/myvc/public';

	return
])