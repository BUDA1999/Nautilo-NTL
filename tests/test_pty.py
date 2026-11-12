"""Testa navegação real no menu com um pseudo-terminal, sem rede."""
import os
import pty
import select
import sys
import time

base = sys.argv[1]
pid, fd = pty.fork()
if pid == 0:
    os.environ.update(TERM='xterm', HOME=os.path.dirname(base))
    os.execvp('bash', ['bash', base + '/ntl'])
data = b''
for key in (b'8', b'\n', b'0'):
    time.sleep(0.15)
    os.write(fd, key)
    deadline = time.monotonic() + 0.6
    while time.monotonic() < deadline:
        ready, _, _ = select.select([fd], [], [], 0.1)
        if ready:
            try:
                data += os.read(fd, 65536)
            except OSError:
                break
_, status = os.waitpid(pid, 0)
assert os.waitstatus_to_exitcode(status) == 0, 'menu não saiu normalmente'
assert b'Pedidos locais usados hoje:' in data, 'atalho quota não abriu'
assert b'\x1b[?25h' in data and b'\x1b[?1049l' in data, 'terminal não restaurado'
print('Pseudo-terminal: quota, regresso e saída verificados.')
