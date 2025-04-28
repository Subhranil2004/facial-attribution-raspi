## Human facial attribution via Raspberry Pi-based Video Surveillance with Low-Cost Webcams

### Features extracted
- Gender
- Age
- Emotion

> Check the `RPi_Mini_Project.pdf` for more details

## Backup-Restore environment Script Usage Guide

> Check the `backups` directory

### 1. Restore on Another System:
```bash
bash restore_env.sh
```

### 2. Backup Current Environment:
```bash
bash backup_env.sh
```



---

🧠 Things to Watch Out For while restoring the environment:

| **Issue**                          | **How to Handle**                                                                 |
|------------------------------------|-----------------------------------------------------------------------------------|
| Different Raspberry Pi OS versions | Prefer using the same OS version (e.g., Raspberry Pi OS Lite 64-bit).             |
| Packages needing compilation (e.g., OpenCV) | Either install from `apt` or recompile carefully.                              |
| Python version mismatch            | Install the matching version via `pyenv` or source compilation.                   |


🛠️ In Short, Your Reproduction Workflow:
- Install Python and pip.
- Create a virtual environment with `--system-site-packages`.
- Activate the virtual environment.
- Install packages from `venv-requirements.txt` using `pip install -r venv-requirements.txt`.
- Reinstall system packages if required (e.g., OpenCV).
- Restore environment variables if applicable.
- Verify the setup by checking Python version and installed packages.

<details>
<summary><strong>Prefer manual backup and restoration? Expand for detailed steps!</strong></summary>

### Backup steps
✨ **Step 1: List venv installed packages**  
Normal:

```bash
pip freeze > venv-requirements.txt
```

✅ Captures whatever was installed directly into venv.

---

✨ **Step 2: List system-site-packages (that your venv can see)**  
First, find where the system-site-packages are located:

```bash
python -c "import site; print(site.getsitepackages())"
```
Example output:
```
['/usr/lib/python3.10/site-packages', '/usr/local/lib/python3.10/dist-packages']
```

Then, list all packages installed there using:

```bash
pip list --path /usr/lib/python3.10/site-packages > system-site-packages.txt
pip list --path /usr/local/lib/python3.10/dist-packages >> system-site-packages.txt
```

✅ This way you get everything available via system-site-packages separately.

---

✨ **Step 3: Capture environment variables too (optional)**  
This sometimes matters because OpenCV can behave differently based on `LD_LIBRARY_PATH`, `PATH`, etc.

```bash
printenv > environment-variables.txt
```

✅ Useful for reproducing runtime behavior.

---

✨ **Step 4: Save Python Version**  
Remember: small version differences (3.10.12 vs 3.10.14) can break things like OpenCV.

Save:

```bash
python --version > python-version.txt
```

✅ Ensures you know the exact Python version needed.

---

✨ **Step 5: Final backup**  
You now have:
```
venv-requirements.txt
system-site-packages.txt
environment-variables.txt
python-version.txt
```

Put all of these into a folder and zip it:

```bash
mkdir env-backup
mv venv-requirements.txt system-site-packages.txt environment-variables.txt python-version.txt env-backup/
tar -czvf env-backup.tar.gz env-backup
```

---

### Restore steps

[Assuming you have the `env-backup.tar.gz` saved.]

✅ **Step 1: Setup the Target System**  
First, on your new Raspberry Pi or any Linux machine:

Install Python (same version as saved in `python-version.txt`):

```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

If you want the exact version (say Python 3.9.2), you may need to install manually or via `pyenv`.

Install pip if not already installed:

```bash
sudo apt install python3-pip
```

---

✅ **Step 2: Create a Virtual Environment (with system-site-packages)**  
Remember you originally created the venv with `--system-site-packages`?  
So recreate it exactly:

```bash
python3 -m venv --system-site-packages myenv
```

✅ This ensures your venv can also see the system's pre-installed packages (like OpenCV, etc.).

---

✅ **Step 3: Activate the Virtual Environment**  
```bash
source myenv/bin/activate
```

---

✅ **Step 4: Restore Python Packages**  
Assume you have your backup archive `env-backup.tar.gz`.

Extract it:

```bash
tar -xzvf env-backup.tar.gz
```

Now you'll have an `env-backup/` folder containing:
```
venv-requirements.txt
system-site-packages.txt
environment-variables.txt
```

Install the packages:

```bash
pip install --no-cache-dir -r env-backup/venv-requirements.txt
```

[Optional but Recommended] If some packages were only available in the system (`system-site-packages.txt`) and are not yet installed (say OpenCV was preinstalled manually), install them using `apt`:

Example:

```bash
sudo apt install python3-opencv
```

Or if you installed OpenCV manually earlier from source, you might need to do it again.

---

✅ **Step 5: Restore Environment Variables (if you had any)**  
If you had saved environment variables (`environment-variables.txt`), you can reload them:

```bash
set -o allexport
source env-backup/environment-variables.txt
set +o allexport
```

This will export all those environment variables into your current session.  
(Or you can put them into `~/.bashrc` if you want them permanently available.)

---

✅ **Step 6: Verify Everything**  
You can check:

```bash
python --version
pip list
```

✅ Compare it to your backup's `venv-requirements.txt` and `python-version.txt` to ensure they match!

Optionally, you can install `pipdeptree` and check the dependency tree:

```bash
pip install pipdeptree
pipdeptree
```

</details>
