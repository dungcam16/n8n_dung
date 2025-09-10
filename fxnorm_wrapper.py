# fxnorm_wrapper.py
#!/usr/bin/env python3
import sys
import json
import argparse
import tempfile
import shutil
import os

# Thêm FxNorm-Automix vào path
sys.path.append('/opt/FxNorm-automix')

# Import module inference (tuỳ repo structure)
try:
    from inference import run_inference
except ImportError as e:
    print(f"Error importing FxNorm modules: {e}", file=sys.stderr)
    sys.exit(1)

def process_multitrack(input_files, output_path, model_name):
    """
    Mix nhiều track sử dụng FxNorm-Automix
    """
    try:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_input = os.path.join(temp_dir, "input")
            os.makedirs(temp_input, exist_ok=True)
            tracks = []
            for i, f in enumerate(input_files):
                if os.path.isfile(f):
                    dest = os.path.join(temp_input, f"track_{i:02d}.wav")
                    shutil.copy(f, dest)
                    tracks.append(dest)
            if not tracks:
                raise ValueError("No valid input files")
            result = run_inference(
                multitrack_path=temp_input,
                output_path=output_path,
                model_path=f"/opt/FxNorm-automix/training/results/{model_name}",
                config_path=f"/opt/FxNorm-automix/configs/ISMIR/{model_name}/config.py"
            )
            return {'success': True, 'output_file': output_path, 'model_used': model_name}
    except Exception as e:
        return {'success': False, 'error': str(e)}

def main():
    parser = argparse.ArgumentParser(description='FxNorm-Automix Wrapper')
    parser.add_argument('--input-files', nargs='+', required=True, help='List of WAV files')
    parser.add_argument('--output', required=True, help='Output mixed WAV')
    parser.add_argument('--model', default='ours_S_pretrained', help='Model name')
    parser.add_argument('--format', choices=['json','simple'], default='json')
    args = parser.parse_args()

    res = process_multitrack(args.input_files, args.output, args.model)
    if args.format == 'json':
        print(json.dumps(res))
    else:
        if res.get('success'):
            print(f"SUCCESS: {res['output_file']}")
        else:
            print(f"ERROR: {res.get('error')}", file=sys.stderr)
    sys.exit(0 if res.get('success') else 1)

if __name__ == '__main__':
    main()
