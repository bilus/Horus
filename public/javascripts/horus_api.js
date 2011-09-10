function startGame(nick, onStarted) {
	__horusRequest("/game?nick=" + nick, "POST", {}, function(data) {
		onStarted(data.id);	
	});
};

function joinGame(gameId, nick, onJoined) {
	__horusRequest('/game/' + gameId, "PUT", {join: nick}, function(data) {
		onJoined(data.id);	
	});
};

function linkToGame(gameId) {
	return '/game.html?game_id=' + gameId;
};

function receiveGameEvents(gameId, onTile, onOwner) {
	if (this.gameEventSource) {
		alert("The 'receiveGameEvents' function cannot be used with multiple feeds because it uses a global.");
		return;
	};

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

////////////////////////////////////////////////////////////////////////////////

function __receiveEvents(url, onmessage) {
	var es = new EventSource(url) ;
	es.onmessage = function (event) {
		  onmessage(event.data);
		};		
	return es;
};

function __handleError(message) {
	alert("Error: " + message); // TODO: Handle error results.
};

function __horusRequest(url, type, data, onOk) {
	$.ajax({
		url: url,
		type: type,
		data: data,
		success: function(data) {
			var response = jQuery.parseJSON(data);
			if (response.status == "ok")
				onOk(response);
			else
				__handleError(response.message);
		},
		error: function(response, message) {
			__handleError(message);
		}
	});
};