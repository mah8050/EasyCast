import http.server
import socketserver
import os

PORT = 8000

class FolderHandler(http.server.SimpleHTTPRequestHandler):
    """
    A request handler that lists all files in the folder and serves them.
    """
    def do_GET(self):
        # Get the requested path relative to current directory
        requested_path = self.path.lstrip("/")

        # If no file is specified, show folder listing
        if requested_path == "":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()

            files = os.listdir(".")
            self.wfile.write(b"<html><body><h2>Files in directory:</h2><ul>")
            for f in files:
                # Make each file a clickable link
                self.wfile.write(f'<li><a href="/{f}">{f}</a></li>'.encode())
            self.wfile.write(b"</ul></body></html>")
        else:
            # Serve the requested file if it exists
            if os.path.isfile(requested_path):
                self.send_response(200)
                self.send_header("Content-type", "application/octet-stream")
                self.send_header("Content-Disposition", f"attachment; filename={requested_path}")
                self.send_header("Content-Length", str(os.path.getsize(requested_path)))
                self.end_headers()

                with open(requested_path, 'rb') as f:
                    self.wfile.write(f.read())
                
                print(f"File {requested_path} served.")
            else:
                # 404 Not Found for non-existent files
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"404 Not Found")

# Start the server
with socketserver.TCPServer(("", PORT), FolderHandler) as httpd:
    print(f"Serving files from {os.getcwd()} at port {PORT}")
    httpd.serve_forever()
