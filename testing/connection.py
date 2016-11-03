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

# Local config options
# import config

my_json = """
{"id": 0,
"jsonrpc": "2.0",
"method": "textDocument/didOpen",
"params": {"uri": "file://tests/test.go",
    "version": 0, "languageId": "go",
    "text": "// In Go, _variables_ are explicitly declared and used by
    \n// the compiler to e.g. check type-correctness of function
    \n// calls.\n
    \npackage main\n
    \nimport \"fmt\"\n
    \nfunc main() {\n
    \n    // `var` declares 1 or more variables.\n    var a string = \"initial\"
    \n    fmt.Println(a)\n\n    // You can declare multiple variables at once.
    \n    var b, c int = 1, 2\n    fmt.Println(b, c)\n
    \n    // Go will infer the type of initialized variables.
    \n    var d = true\n    fmt.Println(d)
    \n\n    // Variables declared without a corresponding
    \n    // initialization are _zero-valued_. For example, the
    \n    // zero value for an `int` is `0`.
    \n    var e int\n    fmt.Println(e)\n
    \n    // The `:=` syntax is shorthand for declaring and
    \n    // initializing a variable,
    e.g. for\n    // `var f string = \"short\"` in this case.
    \n    f := \"short\"\n    fmt.Println(f)\n}"}}"""


class LangServer:
    def __init__(self):
        # self.server = subprocess.Popen(
        #     [config.cargo_path, "run", "-q"],
        #     env={ "RUST_BACKTRACE": "1",
        #          "SYS_ROOT": config.sys_root,
        #          "TMPDIR": config.tmpdir },
        #     cwd=config.rustls_dir,
        #     bufsize=0,
        #     stdin=subprocess.PIPE,
        #     stdout=subprocess.PIPE,
        #     stderr=subprocess.DEVNULL,
        #     close_fds=True,  # Possibly only useful on Posix
        #     universal_newlines=True)
        self.server = subprocess.Popen(['/home/tj/go/bin/langserver-python', '-log', 'temp.log'],
                                       stdin=subprocess.PIPE,
                                       stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE,
                                       close_fds=True,
                                       universal_newlines=True)

        self.response_queue = Queue()
        self.notification_queue = Queue()
        self.io_thread = threading.Thread(
            target=self.response_handler)

        # thread dies with the program
        self.io_thread.daemon = True
        self.io_thread.start()

        self.header_regex = re.compile("(?P<header>(\w|-)+): (?P<value>\d+)")
        # The first unused id.  Incremented with every request.
        self.next_id = 1

        self.in_flight_ids = set()

    def response_handler(self):
        while True:
            response = self.read_response()
            if response is None:
                break
            elif isinstance(response, str):
                print(response)
            elif response.get("id") is not None:
                assert response["id"] in self.in_flight_ids
                # We know this is a response to a request we sent
                self.in_flight_ids.remove(response["id"])
                self.response_queue.put(response)
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
        print('Reading response')
        headers = self.read_headers()
        if "Content-Length" not in headers:
            return None
        size = int(headers["Content-Length"])
        content = self.server.stdout.read(size)
        try:
            return json.loads(content)
        except:
            return content

    def _format_request(self, request):
        """Converts the request into json and adds the Content-Length header"""
        content = json.dumps(request, indent=2)
        content_length = len(content)

        result = "Content-Length: {}\r\n\r\n{}".format(content_length, content)
        return result

    def request(self, method, **params):
        # TODO(tbelaire) more methods.
        assert method in ["initialize", "shutdown", "exit", "textDocument/didOpen", "textDocument/definition"]
        request = {
            "jsonrpc": "2.0",
            "id": self.next_id,
            "method": method,
            "params": params,
        }
        self.in_flight_ids.add(self.next_id)
        self.next_id += 1
        formatted_req = self._format_request(request)
        # TODO(tbelaire) log
        self.server.stdin.write(formatted_req)
        self.server.stdin.flush()
        print(formatted_req)

    def initialize(self):
        self.request("initialize",
                     processId=os.getpid(),
                     # rootPath=config.project_dir,
                     rootPath='file:///home/tj/.vim/plugged/nvim-langserver-shim/tests/',
                     capabilities={})
        # response = self.response_queue.get(True)
        # return response

    def shutdown(self):
        self.request("shutdown")
        response = self.response_queue.get(True)
        self.request("exit")
        self.server.wait()
        assert self.server.returncode == 0
        return response


rls = LangServer()


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
    if count == -1:
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
    elif count == -1:
        rls.request('textDocument/definition',
                    **{
                        'textDocument': {
                            # "uri": "file://tests/test.go",
                            "uri": "file:///home/tj/.vim/plugged/nvim-langserver-shim/tests/test.go",
                        },
                        'position': {'character': 16, 'line': 12},
                        'includeDeclaration': True
                    }
                    )
    elif count == 0:
        rls.request('textDocument/didOpen', **{
            "uri": "file://tests/test.go",
            "version": 1,
            "languageId": "python",
            "text": """
hello = 'world'

print(hello)
"""})
        count += 1
    elif count == 1:
        rls.request('textDocument/definition',
                    **{
                        'textDocument': {
                            # "uri": "file://tests/test.go",
                            "uri": "file:///home/tj/.vim/plugged/nvim-langserver-shim/tests/test.py",
                        },
                        'position': {'character': 6, 'line': 2},
                        'includeDeclaration': True
                    }
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
