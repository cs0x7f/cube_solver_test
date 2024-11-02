import face  # though not used in this module we get circular when we omit the import
from cubie import CubieCube
import solver as sv

def main():
    while True:
        cc = CubieCube()
        scramble = ""
        curFace, curPow = None, 0
        try:
            scramble = input()
        except EOFError:
            break
        for ch in scramble:
            if ch in set("URFDLB"):
                if curPow > 0:
                    for _ in range(curPow):
                        cc.move(curFace * 3)
                curFace, curPow = "URFDLB".find(ch), 1
            elif ch in set("123"):
                curPow = curPow * int(ch) % 4
            elif ch == "'":
                curPow = (4 - curPow) % 4
            else:
                pass
        if curPow > 0:
            for _ in range(curPow):
                cc.move(curFace * 3)
        print(sv.solve(cc.to_facelet_cube().to_string()))

if __name__ == '__main__':
    main()