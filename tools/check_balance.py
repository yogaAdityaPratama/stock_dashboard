import sys
from collections import defaultdict

path = r"d:\stockID\lib\screens\analysis_screen.dart"
text = open(path, encoding='utf-8').read()

pairs = {'(':')','[':']','{':'}'}
opens = set(pairs.keys())
closes = set(pairs.values())
stack = []
line = 1
col = 0
line_starts = [0]
for i,ch in enumerate(text):
    if ch == '\n':
        line += 1
        line_starts.append(i+1)

line = 1
stack = []
for i,ch in enumerate(text):
    if ch == '\n':
        line += 1
        col = 0
        continue
    col += 1
    if ch in opens:
        stack.append((ch,line,col,i))
    elif ch in closes:
        if not stack:
            print(f"Unmatched closing '{ch}' at line {line}, col {col}")
            sys.exit(0)
        last, lline, lcol, idx = stack[-1]
        if pairs[last] == ch:
            stack.pop()
        else:
            print(f"Mismatched closing '{ch}' at line {line}, col {col}; expected '{pairs[last]}' for opening at line {lline}, col {lcol}")
            sys.exit(0)

if stack:
    for ch,line,col,idx in stack:
        print(f"Unclosed opening '{ch}' at line {line}, col {col}")
    sys.exit(0)

print('All brackets balanced')
