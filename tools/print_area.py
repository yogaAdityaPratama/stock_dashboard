path = r'd:\stockID\lib\screens\analysis_screen.dart'
start = 360
end = 480
with open(path, encoding='utf-8') as f:
    for i, line in enumerate(f, start=1):
        if i < start:
            continue
        if i > end:
            break
        print(f"{i:4}: {line.rstrip()}")
