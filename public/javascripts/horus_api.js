function __receiveEvents(url, onmessage) {
	var es = new EventSource(url) ;
	es.onmessage = function (event) {
		  onmessage(event.data);
		};		
	return es;
};

function startGame(nick, onStarted) {
	$.post('/game?nick=' + nick, function(data) {
		onStarted(jQuery.parseJSON(data).id);
	});
};

function linkToGame(gameId) {
	return '/game.html?game_id=' + gameId;
};

function receiveGameEvents(gameId, onTile, onOwner) {
	// Global object -- this function cannot be used with multiple feeds.
	this.gameEventSource = __receiveEvents('/game/' + gameId, function(event_json) {
		var event = jQuery.parseJSON(event_json);
		if (event.tile)
			onTile(event.tile);
		if (event.owner)
			onOwner(event.owner);
	});
};

function addTile(gameId, tile) {
	$.ajax({
		url: '/tile/' + gameId,
		type: 'POST',
		data: {tile: tile}
	});
};
