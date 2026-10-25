"""Build a small OT1 reward catalog from hash-verified local game tables.

The development-only table reader comes from MarvinXLII/OctopathTravelerJobRandomizer.
Its unused hjson import and tagged-property skipping were adjusted for this PC build.
"""

import json
import pathlib
import re
import sys
import struct

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "reference/ot1-randomizer"))
from Data import DATA


class ExtractedFiles:
    def extractFile(self, name):
        return bytearray((ROOT / "evidence/assets" / pathlib.Path(name).name).read_bytes())


def load(name):
    table = DATA(ExtractedFiles(), name)
    assert table.footer == bytes.fromhex("c1832a9e"), f"Incomplete table: {name}"
    fields = {key.split("_")[0]: key for key in next(iter(table.table.values()))}
    return table, fields


def main():
    enemy_table, ef = load("EnemyDB")
    group_table, gf = load("EnemyGroupData")
    item_table, _ = load("ItemDB")
    enemies, groups = {}, {}
    for label in enemy_table.table:
        if not label.startswith("ENE_") or enemy_table.readBool(label, ef["NPCFlag"]):
            continue
        events = enemy_table.readArray(label, ef["BattleEvent"])
        if any(enemy_table.uasset.getName(event) != "None" for event in events):
            continue
        values = {
            key: enemy_table.readInt(label, ef[field])
            for key, field in (("level", "EnemyLevel"), ("exp", "Exp"),
                               ("jp", "JobPoint"), ("money", "Money"),
                               ("drop", "DropProbability"))
        }
        if not 1 <= values["level"] <= 99:
            continue
        assert 0 <= values["drop"] <= 100
        assert all(0 <= values[key] <= 999999999 for key in ("exp", "jp", "money"))
        item = enemy_table.readName(label, ef["HaveItemID"])
        if item != "None":
            assert item in item_table.table, item
            values["item"] = item
        enemies[label] = values
    for label in group_table.table:
        if not re.match(r"^ENG_(Mou|Sno|Sea|Cli|For|Pla|Riv|Des)_", label):
            continue
        if group_table.readBool(label, gf["BossBattle"]):
            continue
        members = [group_table.uasset.getName(value)
                   for value in group_table.readArray(label, gf["EnemyID"])]
        members = [member for member in members if member != "None"]
        if members and all(member in enemies for member in members):
            groups[label] = members
    assert enemies and groups
    lines = ["-- Generated from Windows Steam build 5272616; do not substitute OT2 data.", "return {", "  enemies = {"]
    for label, values in sorted(enemies.items()):
        fields = ", ".join(f"{key}={json.dumps(value)}" for key, value in values.items())
        lines.append(f"    [{json.dumps(label)}] = {{{fields}}},")
    lines += ["  },", "  groups = {"]
    for label, members in sorted(groups.items()):
        lines.append(f"    [{json.dumps(label)}] = {{{','.join(json.dumps(m) for m in members)}}},")
    lines += ["  },", "  reward_items = {"]
    for label, row in item_table.table.items():
        data = row[next(k for k in row if k.startswith('Ailment_'))]
        for ailment, stat in (("EXPUP", "exp"), ("JPUP", "jp")):
            marker = struct.pack('<q', item_table.uasset.getIndex(ailment))
            if marker not in data:
                continue
            position = data.index(marker)
            assert item_table.uasset.getName(struct.unpack_from('<q', data, position - 25)[0]).startswith('AilmentName_')
            assert item_table.uasset.getName(struct.unpack_from('<q', data, position + 8)[0]).startswith('InvocationValue_')
            assert item_table.uasset.getName(struct.unpack_from('<q', data, position + 16)[0]) == 'IntProperty'
            value = struct.unpack_from('<i', data, position + 33)[0]
            assert value >= 100
            lines.append(f'    ["{label}"] = {{{stat}={value / 100 - 1}}},')
    lines += ["  },", "}", ""]
    output = ROOT / "mod/OT1AutoResolve/Scripts/catalog.lua"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines))
    print(f"Verified catalog: {len(enemies)} enemies, {len(groups)} ordinary groups; drop IDs checked against {len(item_table.table)} items.")


if __name__ == "__main__":
    main()
