"""Package the mod source without UE4SS binaries or local development data."""
import hashlib
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VERSION = "0.1.3"
FILES = ("config.ini", "Scripts/main.lua", "Scripts/catalog.lua", "Scripts/messages.lua")
target = ROOT / "dist" / f"OT1AutoResolve-{VERSION}-mod-only.zip"
target.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as archive:
    for name in FILES:
        source = ROOT / "mod/OT1AutoResolve" / name
        archive.write(source, "Win64/Mods/OT1AutoResolve/" + name)
    archive.write(ROOT / "README.md", "README.md")
    archive.write(ROOT / "NOTICE.md", "NOTICE.md")
with zipfile.ZipFile(target) as archive:
    assert archive.testzip() is None
    assert len(archive.namelist()) == len(FILES) + 2
    for name in FILES:
        assert archive.read("Win64/Mods/OT1AutoResolve/" + name) == (ROOT / "mod/OT1AutoResolve" / name).read_bytes()
checksum = hashlib.sha256(target.read_bytes()).hexdigest()
target.with_suffix(".zip.sha256").write_text(f"{checksum}  {target.name}\n")
print(target)
