import re
import subprocess
from packaging import version

def check_program_version(program: str, min_version: str) -> None:
  try:
    if program == "zig":
      result = subprocess.run([program, "version"], capture_output=True, text=True, check=True)
    else:
      result = subprocess.run([program, "--version"], capture_output=True, text=True, check=True)
    
    out = result.stdout.strip()
    # print(f"{program} version: {out}")

    version_match = re.search(r"(\d+\.\d+\.\d+)", out)
    if version_match:
      current_version = version_match.group(1)
      if version.parse(current_version) >= version.parse(min_version):
        print(f"{program} is version {current_version}, which meets or exceeds {min_version}")
      else:
        print(f"{program} version {current_version} is lower than the expected {min_version}")

    else:
      print(f"Could not determine {program} version.")

  except FileNotFoundError:
    print(f"{program} is not installed or not in the PATH.")
    exit(1)
  except subprocess.CalledProcessError as e:
    print(f"Error checking {program} version: {e}")

program_versions = {
  "cmake": "3.20.8",
  "ninja": "1.12.1",
  "zig": "0.14.0",
  "rustc": "1.85.0"
}

def main():
  pass

if __name__ == '__main__':
  for key, val in program_versions.items():
    check_program_version(program=key, min_version=val)
