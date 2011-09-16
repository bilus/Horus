function startGame(nick, onStarted) {
	__horusRequest("/game?nick=" + nick, "POST", {}, function(data) {
		onStarted(__makeGameHandle(data.id, data.public_id));	
	});
};

function joinGame(publicGameId, nick, onJoined) {
	__horusRequest('/game/' + publicGameId, "PUT", {join: nick}, function(data) {
		onJoined(__makeGameHandle(data.id, publicGameId));	
	});
};

function linkToGame(gameHandle) {
	return '/game.html?game_id=' + gameHandle.privateId + '&public=' + gameHandle.publicId;
};

function linkToWatchGame(publicGameId) {
	return '/game.html?game_id=' + publicGameId;
};


// TODO: Use game handle.
function receiveGameEvents(gameId, onTile, onJoin) {
	if (this.gameEventSource) {
		alert("The 'receiveGameEvents' function cannot be used with multiple feeds because it uses a global.");
		return;
	};

	this.gameEventSource = __receiveEvents('/game/' + gameId, function(event_json) {
		var event = jQuery.parseJSON(event_json);
		if (event.tile)
			onTile(event.tile);
		if (event.owner)
			onJoin(event.owner);
		if (event.join)
			onJoin(event.join);
	});
};

// TODO: Use game handle.
function addTile(gameId, tile) {
	__horusRequest('/tile/' + gameId, "POST", {tile: tile});
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
	console.log("Error: " + message);
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

function __makeGameHandle(privateGameId, publicGameId) {
	return {privateId: privateGameId, publicId: publicGameId};
};