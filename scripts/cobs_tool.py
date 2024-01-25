import argparse
import sys
# from cobs import cobsr
from cobs import cobs

def cobs_encode(input_bytes):
    return cobs.encode(input_bytes)

def cobs_decode(input_bytes):
    try:
        return cobs.decode(input_bytes)
    except cobs.DecodeError as e:
        print(f"COBS Decode Error: {e}", file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(description='COBS Encode/Decode CLI tool')
    parser.add_argument('mode', choices=['encode', 'decode'], help='Operation mode: encode or decode')
    parser.add_argument('-i', '--input', type=str, default='-', help='Input string or file path. Use "-" for stdin (default: stdin)')
    parser.add_argument('-o', '--output', type=str, help='Output file path. If not specified, stdout is used.')

    args = parser.parse_args()

    if args.input == '-':
        data = sys.stdin.buffer.read().strip(b'\x00')
    else:
        with open(args.input, 'rb') as f:
            data = f.read().strip(b'\x00')

    if args.mode == 'encode':
        result = cobs_encode(data)
    else:
        result = cobs_decode(data)

    if result is None:
        sys.exit(1)

    if args.output:
        with open(args.output, 'wb') as f:
            f.write(result)
    else:
        sys.stdout.buffer.write(result)

if __name__ == '__main__':
    main()
