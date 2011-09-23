function startGame(nick, onStarted, failure) {
	__horusRequest("/game?nick=" + nick, "POST", {}, function(data) {
		onStarted(__makeGameHandle(data.id, data.public_id));	
	}, failure);
};

function joinGame(publicGameId, nick, onJoined, failure) {
	__horusRequest('/game/' + publicGameId, "PUT", {join: nick}, function(data) {
		onJoined(__makeGameHandle(data.id, publicGameId));	
	}, failure);
};

function linkToGame(gameHandle) {
	return '/game.html?game_id=' + gameHandle.privateId + '&public=' + gameHandle.publicId;
};

function linkToWatchGame(publicGameId) {
	return '/game.html?game_id=' + publicGameId;
};


// TODO: Use game handle.
function receiveGameEvents(gameId, handlers) {
	if (this.gameEventSource) {
		alert("The 'receiveGameEvents' function cannot be used with multiple feeds because it uses a global.");
		return;
	};

	this.gameEventSource = __receiveEvents('/game/' + gameId, function(event_json) {
		var event = jQuery.parseJSON(event_json);
		if (event.tile && handlers.onTile)
			handlers.onTile(event.tile);
		if (event.owner && handlers.onJoin)
			handlers.onJoin(event.owner);
		if (event.join && handlers.onJoin)
			handlers.onJoin(event.join);
		if (event.next_turn && handlers.onNextTurn)
			handlers.onNextTurn(event.next_turn);
	});
};

// TODO: Use game handle.
function addTile(gameId, tile, success, failure) {
	__horusRequest('/tile/' + gameId, "POST", {tile: tile}, success, failure);
};

////////////////////////////////////////////////////////////////////////////////

function __receiveEvents(url, onmessage) {
	var es = new EventSource(url) ;
	es.onmessage = function (event) {
		  onmessage(event.data);
		};		
	return es;
};

function __logError(message) {
	if (typeof(console) != 'undefined')
		console.log("Error: " + message);
};

function __handleError(message, optionalHandler) {
	__logError(message);
	if (optionalHandler)
		optionalHandler(message);
};

function __horusRequest(url, type, data, success, failure) {
	$.ajax({
		url: url,
		type: type,
		data: data,
		success: function(data) {
			var response = jQuery.parseJSON(data);
			if (response.status == "ok") {
				if (typeof(success) != 'undefined') {
					success(response);
				}
			}
			else {
				__handleError(response.message, failure);
			}
		},
		error: function(response, message) {
			__handleError(message, failure);
		}
	});
};

function __makeGameHandle(privateGameId, publicGameId) {
	return {privateId: privateGameId, publicId: publicGameId};
};