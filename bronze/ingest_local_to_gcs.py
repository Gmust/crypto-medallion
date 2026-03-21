"""
Upload a local file to Google Cloud Storage using settings from a JSON config file.
"""

from __future__ import annotations

import json
import logging
import sys
from pathlib import Path

from google.cloud import storage
from google.cloud.exceptions import GoogleCloudError

LOGGER = logging.getLogger(__name__)

DEFAULT_CONFIG = Path(__file__).resolve().parent / "config.json"


def load_config(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(
            f"Config not found: {path}. Copy config.example.json to config.json and edit."
        )
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def upload_file(
    project_id: str,
    bucket_name: str,
    blob_name: str,
    local_path: Path,
) -> None:
    local_path = local_path.expanduser().resolve()
    if not local_path.is_file():
        raise FileNotFoundError(f"Local file does not exist: {local_path}")

    client = storage.Client(project=project_id)
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)

    LOGGER.info("Uploading %s -> gs://%s/%s", local_path, bucket_name, blob_name)
    blob.upload_from_filename(str(local_path))
    LOGGER.info("Upload finished.")


def main() -> int:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    config_path = Path(
        sys.argv[1] if len(sys.argv) > 1 else DEFAULT_CONFIG
    ).expanduser()

    try:
        cfg = load_config(config_path)
        project_id = cfg["project_id"]
        bucket_name = cfg["bucket_name"]
        blob_name = cfg["gcs_blob_name"]
        local_file = Path(cfg["local_file_path"])
    except (KeyError, json.JSONDecodeError) as e:
        LOGGER.error("Invalid config: %s", e)
        return 1

    try:
        upload_file(project_id, bucket_name, blob_name, local_file)
    except (FileNotFoundError, GoogleCloudError, OSError) as e:
        LOGGER.error("%s", e)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
