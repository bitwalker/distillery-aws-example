/*jshint eqeqeq:false */
(function (window) {
	'use strict';

    function get(url, callback) {
        var xhr = new XMLHttpRequest();

        xhr.open('GET', url, true);

        xhr.onload = function() {
            if (xhr.status == 200) {
                if (callback) {
                    callback(xhr.responseText);
                }
            } else {
                console.log('Received ' + xhr.status + 'in response to GET ' + url);
                console.log('Response', xhr.responseText)
            }
        };

        xhr.send()
    }

    function put(url, data, callback) {
        var xhr = new XMLHttpRequest();

        xhr.open('PUT', url, true);

        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onload = function() {
            if (xhr.status == 200) {
                if (callback) {
                    callback();
                }
            } else {
                console.log('Received ' + xhr.status + 'in response to PUT ' + url);
                console.log('Sent', data)
            }
        };

        xhr.send(JSON.stringify(data));
    }

    function post(url, data, callback) {
        var xhr = new XMLHttpRequest();

        xhr.open('POST', url, true);

        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if (this.readyState == XMLHttpRequest.DONE && this.status == 200) {
                if (callback) {
                    callback(xhr.responseText);
                }
            } else if (this.readyState == XMLHttpRequest.DONE) {
                console.log('Received ' + xhr.status + 'in response to POST ' + url);
                console.log('Response', xhr.responseText);
            }
        };

        xhr.send(JSON.stringify(data)); 
    }

    function del(url, callback) {
        var xhr = new XMLHttpRequest();

        xhr.open('DELETE', url, true);

        xhr.onload = function() {
            if (xhr.status == 200) {
                if (callback) {
                    callback();
                }
            } else {
                console.log('Received ' + xhr.status + 'in response to DELETE ' + url);
            }
        };

        xhr.send()
    }

	/**
	 * Creates a new client side storage object and will create an empty
	 * collection if no collection already exists.
	 */
	function Store(name) {
        this.__name = name
        this.__todos = [];

        var self = this;

        get('/api/todos', function (result) {
            self.__todos = JSON.parse(result);
        });
	}

	/**
	 * Finds items based on a query given as a JS object
	 *
	 * @param {object} query The query to match against (i.e. {foo: 'bar'})
	 * @param {function} callback	 The callback to fire when the query has
	 * completed running
	 *
	 * @example
	 * db.find({foo: 'bar', hello: 'world'}, function (data) {
	 *	 // data will return any items that have foo: bar and
	 *	 // hello: world in their properties
	 * });
	 */
	Store.prototype.find = function (query, callback) {
		if (!callback) {
			return;
		}

		var todos = this.__todos;

		callback.call(this, todos.filter(function (todo) {
			for (var q in query) {
				if (query[q] !== todo[q]) {
					return false;
				}
			}
			return true;
		}));
	};

	/**
	 * Will retrieve all data from the collection
	 *
	 * @param {function} callback The callback to fire upon retrieving data
	 */
	Store.prototype.findAll = function (callback) {
		callback = callback || function () {};
        var self = this;
        get('/api/todos', function(result) {
            self.__todos = JSON.parse(result);
            callback.call(self, self.__todos);
        });
	};

	/**
	 * Will save the given data to the DB. If no item exists it will create a new
	 * item, otherwise it'll simply update an existing item's properties
	 *
	 * @param {object} updateData The data to save back into the DB
	 * @param {function} callback The callback to fire after saving
	 * @param {number} id An optional param to enter an ID of an item to update
	 */
	Store.prototype.save = function (updateData, callback, id) {
		var todos = JSON.parse(localStorage.getItem(this._dbName));

		callback = callback || function() {};

        var self = this;
        if (id) {
            put('/api/todos/' + id, updateData, function() {
                get('/api/todos', function(result) {
                    self.__todos = JSON.parse(result);
                    if (callback) {
                        callback.call(self, self.__todos);
                    }
                });
            });
        } else {
            updateData["id"] = id;
            post('/api/todos', updateData, function() {
                get('/api/todos', function(result) {
                    self.__todos = JSON.parse(result);
                    if (callback) {
                        callback.call(self, self.__todos);
                    }
                });
            });
        }
	};

	/**
	 * Will remove an item from the Store based on its ID
	 *
	 * @param {number} id The ID of the item you want to remove
	 * @param {function} callback The callback to fire after saving
	 */
	Store.prototype.remove = function (id, callback) {
        var self = this;

        del('/api/todos/' + id, function() {
            get('/api/todos', function(result) {
                self.__todos = JSON.parse(result);
                if (callback) {
                    callback.call(self, self.__todos);
                }
            });
        });
	};

	/**
	 * Will drop all storage and start fresh
	 *
	 * @param {function} callback The callback to fire after dropping the data
	 */
	Store.prototype.drop = function (callback) {
        del('/api/todos', function() {
            get('/api/todos', function(result) {
                self.__todos = JSON.parse(result);
                if (callback) {
                    callback.call(self, self.__todos);
                }
            });
        });
	};

	// Export to window
	window.app = window.app || {};
	window.app.Store = Store;
})(window);
