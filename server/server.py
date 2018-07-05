import socket
import threading

HOST = "localhost"
PORT = 5001
BUFFER_SIZE = 2048

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind((HOST, PORT))
sock.listen(5)

print("Server start, listening {}".format(PORT))

def getdata(conn, addr):
    while True:
        data = conn.recv(BUFFER_SIZE)
        print("接收信息 {}: ".format(addr) + data.decode('utf-8'))

def senddata(conn, addr):
    while True:
        message = input()
        if message:
            msg = bytes(message, encoding='utf8')
            conn.send(msg)

def start(conn, addr):
    try:
        threads = []
        t1 = threading.Thread(target=senddata, args=(conn, addr))
        threads.append(t1)
        t2 = threading.Thread(target=getdata, args=(conn, addr))
        threads.append(t2)

        for t in threads:
            t.setDaemon(True)
            t.start()

        for t in threads:
            t.join()

        print("----- end -----")
    except Exception as e:
        conn.close()
        print("Exception: %s"%str(e))

while True:
    conn, addr = sock.accept()
    t = threading.Thread(target=start, args=(conn, addr))
    t.start()

sock.close()