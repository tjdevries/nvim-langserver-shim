'use strict';
// Main for remote plugin
var cp = require('child_process');
var rpc = require('vscode-jsonrpc');
var childProcess = cp.spawn('$HOME/bin/langserver-go');
// Use stdin and stdout for communication:
var connection = rpc.createMessageConnection(new rpc.StreamMessageReader(childProcess.stdout), new rpc.StreamMessageWriter(childProcess.stdin));
var notification = { method: 'testNotification' };
connection.listen();
connection.sendNotification(notification, 'Hello World');
