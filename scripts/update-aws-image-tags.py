import re
import sys
from pathlib import Path

if len(sys.argv) != 2:
    raise SystemExit("Usage: python update-aws-image-tags.py IMAGE_TAG")

image_tag = sys.argv[1]
values_file = Path("helm/ecommerce-platform/values-aws.yaml")

content = values_file.read_text()

sections = ["frontend", "admin", "backend", "auditService"]

for section in sections:
    pattern = (
        rf"(?ms)^({section}:\s*\n.*?)"
        rf"(?=^[A-Za-z][A-Za-z0-9]*:\s*$|\Z)"
    )

    match = re.search(pattern, content)

    if not match:
        raise SystemExit(f"Could not find '{section}' in {values_file}")

    block = match.group(1)

    updated_block, replacements = re.subn(
        r"(?m)^(\s+tag:\s*).*$",
        lambda tag_match: tag_match.group(1) + image_tag,
        block,
        count=1,
    )

    if replacements != 1:
        raise SystemExit(f"Could not update image tag for '{section}'")

    content = content[:match.start(1)] + updated_block + content[match.end(1):]

values_file.write_text(content)
print(f"Updated application image tags to: {image_tag}")
