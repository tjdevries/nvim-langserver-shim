#!/usr/bin/env python3
# Modified source code @tbelair
# https://github.com/tbelaire/lang-server-client

import json
import os
import re
import subprocess
import threading

import time


try:
    from Queue import Queue, Empty
except ImportError:
    from queue import Queue, Empty  # python 3.x


class LspClient:

    def __init__(self, binary_name, args, env, root_path, response_queue):
        args.insert(0, binary_name)
        self.server = subprocess.Popen(
            args,
            env=env,
            cwd=root_path,
            bufsize=0,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            close_fds=True,  # Possibly only useful on Posix
            universal_newlines=True)

        self.response_queue = response_queue
        self.notification_queue = Queue()
        self.io_thread = threading.Thread(
            target=self.response_handler)

        self.io_thread.daemon = True  # thread dies with the program
        self.io_thread.start()

        self.header_regex = re.compile("(?P<header>(\w|-)+): (?P<value>\d+)")
        # The first unused id.  Incremented with every request.
        self.next_id = 1

        # id -> callback_args map
        self.in_flight_ids = {}

    def response_handler(self):
        while True:
            response = self.read_response()
            if response is None:
                break
            elif response.get("id") is not None:
                assert response["id"] in self.in_flight_ids
                callback_args = self.in_flight_ids[response["id"]]
                # We know this is a response to a request we sent
                del self.in_flight_ids[response["id"]]
                self.response_queue.put((response, callback_args))
            else:
                # It's a notification
                self.notification_queue.put(response)

    def read_headers(self):
        """Reads in the headers for a response"""
        result = {}
        while True:
            line = self.server.stdout.readline()
            if line == "\n":
                break
            m = self.header_regex.match(line)
            if m:
                result[m.group("header")] = m.group("value")
            else:
                break
        return result

    def read_response(self):
        headers = self.read_headers()
        if "Content-Length" not in headers:
            return None
        size = int(headers["Content-Length"])
        # TODO(uforic) figure out why this is off by one
        # I think a \n is being left from the previous line
        content = self.server.stdout.read(size + 1)
        # content = content + "}"
        return json.loads(content)

    def _format_request(self, request):
        """Converts the request into json and adds the Content-Length header"""
        content = json.dumps(request, indent=2)
        content_length = len(content)

        result = "Content-Length: {}\r\n\r\n{}".format(content_length, content)
        return result

    def request(self, callback_args, method, **params):
        # TODO(tbelaire) more methods.
        assert method in [
            "initialize",
            "textDocument/hover",
            "textDocument/definition",
            "textDocument/documentSymbol",
            "textDocument/references",
            "shutdown",
            "exit"]
        request = {
            "jsonrpc": "2.0",
            "id": self.next_id,
            "method": method,
            "params": params,
        }
        callback_args['request'] = request
        self.in_flight_ids[self.next_id] = callback_args
        self.next_id += 1
        formatted_req = self._format_request(request)
        # TODO(tbelaire) log
        self.server.stdin.write(formatted_req)
        self.server.stdin.flush()

    def initialize(self, callback_args, root_path):
        self.request(callback_args,
                     "initialize",
                     processId=os.getpid(),
                     rootPath=root_path,
                     capabilities={})
        response = self.response_queue.get(True)
        return response

    def hover(self, callback_args, text_document, position):
        self.request(callback_args,
                     "textDocument/hover",
                     textDocument=text_document,
                     position=position)
        return

    def definition(self, callback_args, text_document, position):
        self.request(callback_args,
                     "textDocument/definition",
                     textDocument=text_document,
                     position=position)
        return

    def documentSymbol(self, callback_args, text_document):
        self.request(callback_args,
                     "textDocument/documentSymbol",
                     textDocument=text_document)
        return

    def references(
            self,
            callback_args,
            text_document,
            position,
            include_declaration):
        self.request(callback_args,
                     "textDocument/references",
                     textDocument=text_document,
                     position=position,
                     includeDeclaration=include_declaration)

    def shutdown(self):
        self.request("shutdown")
        response = self.response_queue.get(True)
        self.request("exit")
        self.server.wait()
        assert self.server.returncode == 0
        return response


# def __init__(self, binary_name, args, env, root_path, response_queue):
rls = LspClient(
    '/home/tj/bin/langserver-go',
    ['-trace', '-logfile', 'temp.log'],
    None,
    os.getcwd(),
    Queue())


print("First thing")
print("Response:")
response = rls.initialize()
print(response)
print('After response')
# print(json.dumps(response, indent=2))

# print("Notification:")
# response = rls.notification_queue.get(True)
# print(response)
# print(json.dumps(response, indent=2))

time.sleep(1)
count = 0
while True:
    any_non_empty = False

    # my_choice = input('Choice')

    # if my_choice == 'y':
    print('sending my json')
    if count == 0:
        rls.request('textDocument/didOpen', **{
            "uri": "file://tests/test.go",
            "version": 1,
            "languageId": "go",
            "text": """
// In Go, _variables_ are explicitly declared and used by
// the compiler to e.g. check type-correctness of function
// calls.

package main

import "fmt"

func main() {

    // `var` declares 1 or more variables.
    var a string = "initial"
    fmt.Println(a)

    // You can declare multiple variables at once.
    var b, c int = 1, 2
    fmt.Println(b, c)

    // Go will infer the type of initialized variables.
    var d = true
    fmt.Println(d)

    // Variables declared without a corresponding
    // initialization are _zero-valued_. For example, the
    // zero value for an `int` is `0`.
    var e int
    fmt.Println(e)

    // The `:=` syntax is shorthand for declaring and
    // initializing a variable, e.g. for
    // `var f string = "short"` in this case.
    f := "short"
    fmt.Println(f)
}
}
"""})

        count += 1
    elif count == 1:
        rls.request('textDocument/definition',
                    **{'textDocument':
                        {
                            # "uri": "file://tests/test.go",
                            "uri": "file:///home/tj/.vim/plugged/nvim-langserver-shim/tests/test.go",
                        },
                       'position':
                        {'character': 16, 'line': 12}}
                    )

    # rls.server.stdin.write(my_json)
    # rls.server.stdin.flush()

    try:
        response = rls.response_queue.get_nowait()
        print("Response:")
        print(json.dumps(response, indent=2))
        any_non_empty = True
    except Empty:
        pass

    try:
        notification = rls.notification_queue.get_nowait()
        print("Notification:")
        print(json.dumps(notification, indent=2))
        any_non_empty = True
    except Empty:
        pass

    my_val = input()

    if my_val == 'q':
        break

print("Done")
