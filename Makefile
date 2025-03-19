setup:
	uv sync --all-extras --prerelease=allow --dev

format:
	black document_manager

lint:
	pylama document_manager

local_run: setup
	uv run --prerelease=allow document_manager/app.py

test: setup
	uv run --prerelease=allow pytest --cov document_manager

coverage: setup
	uv run --prerelease=allow pytest --cov --cov-report html document_manager

test_unit: setup
	uv run --prerelease=allow pytest -m "unit" document_manager