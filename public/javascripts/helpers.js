// Retrieve params from current page's url.
$.extend({
	currentUrlParams: function(){
		var map = {};
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
			map[key] = value;
		});
		return map;
	},
	currentUrlParam: function(name){
		return $.currentUrlParams()[name];
	},

	appendParams: function(url, params) {
		return url + (url.indexOf('?') != -1 ? '&' : '?') + params;
	}
});