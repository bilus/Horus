function __receiveEvents(url, onmessage) {
	var es = new EventSource(url) ;
	es.onmessage = function (event) {
		  onmessage(event.data);
		};		
	return es;
};

function __appendGameId(url, gameId) {
	return $.appendParams(url, 'id=' + gameId);
};

function receiveGameEvents(gameId, onTile) {
	// Global object -- this function cannot be used with multiple feeds.
	this.gameEventSource = __receiveEvents(__appendGameId('/game', gameId), onTile);
};

function addTile(gameId, tile) {
	$.ajax({
		url: __appendGameId('/game', gameId),
		type: 'PUT',
		data: {tile: tile}
	});
};
