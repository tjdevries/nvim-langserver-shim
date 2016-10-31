'use strict';

// Main for remote plugin
import * as cp from 'child_process';
import * as rpc from 'vscode-jsonrpc';

let childProcess = cp.spawn('$HOME/bin/langserver-go');

// Use stdin and stdout for communication:
let connection = rpc.createMessageConnection(
    new rpc.StreamMessageReader(childProcess.stdout),
    new rpc.StreamMessageWriter(childProcess.stdin));

let notification: rpc.NotificationType<string> = { method: 'testNotification' };

connection.listen();

connection.sendNotification(notification, 'Hello World');