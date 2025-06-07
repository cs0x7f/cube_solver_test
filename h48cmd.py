import nissy_python_module as nissy
import sys
import re
import time

def main():
	if len(sys.argv) < 3 or not re.match(r'^h48h[0-9]{1,2}k[0-9]$', sys.argv[1]) or not re.match(r'^[0-9]*$', sys.argv[2]):
		print("usage: python3 cmd.py h48h?k? n_thread")
		return
	solver = sys.argv[1]
	n_thread = int(sys.argv[2])
	solver_data = None
	try:
		with open("tables/" + solver, "rb") as f:
			solver_data = bytearray(f.read())
	except IOError:
		print("table not exist, generate...")
		solver_data = nissy.gendata(solver)
		with open("tables/" + solver, "wb") as f:
			f.write(solver_data)

	while True:
		scramble = ""
		try:
			scramble = input()
		except EOFError:
			break
		scramble = scramble.replace('1', '')
		print (scramble)
		tt = time.time()
		nissy.solve(nissy.applymoves(nissy.solved_cube, scramble), solver, nissy.nissflag_normal, 0, 20, 1, 0, n_thread, solver_data)
		print('Time: %0.6f s' % (time.time() - tt, ))

if __name__ == '__main__':
	main()
