"""
Upload a local file to Google Cloud Storage using variables from .env (repository root).
"""

from __future__ import annotations

import logging
import os
from pathlib import Path

from dotenv import load_dotenv
from google.cloud import storage
from google.cloud.exceptions import GoogleCloudError

LOGGER = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parent.parent


def load_env() -> None:
    load_dotenv(REPO_ROOT / ".env")


def require_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise ValueError(
            f"Missing or empty environment variable: {name}. "
            "Copy .env.example to .env in the repo root and set values."
        )
    return value


def upload_file(
    project_id: str,
    bucket_name: str,
    blob_name: str,
    local_path: Path,
) -> None:
    local_path = local_path.expanduser()
    if not local_path.is_absolute():
        local_path = (REPO_ROOT / local_path).resolve()
    else:
        local_path = local_path.resolve()

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
    load_env()

    try:
        project_id = require_env("GCP_PROJECT_ID")
        bucket_name = require_env("GCS_BUCKET_NAME")
        blob_name = require_env("GCS_BLOB_NAME")
        local_file = Path(require_env("LOCAL_FILE_PATH"))
    except ValueError as e:
        LOGGER.error("%s", e)
        return 1

    try:
        upload_file(project_id, bucket_name, blob_name, local_file)
    except (FileNotFoundError, GoogleCloudError, OSError) as e:
        LOGGER.error("%s", e)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
