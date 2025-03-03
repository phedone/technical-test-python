setup:
	uv sync --all-extras --prerelease=allow --dev

format:
	black document_manager

lint:
	pylama document_manager

local_run: setup
	dotenvx run -f .env.ci  -- uv run --prerelease=allow document_manager/app.py

test: setup
	dotenvx run -f .env.ci  -- uv run --prerelease=allow pytest --cov document_manager

coverage: setup
	dotenvx run -f .env.ci  -- uv run --prerelease=allow pytest --cov --cov-report html document_manager

test_unit: setup
	dotenvx run -f .env.ci  -- uv run --prerelease=allow pytest -m "unit" document_manager

TIMESTAMP := $(shell date +%Y%m%d%H%M%S)
COMMIT_HASH := $(shell git rev-parse --short HEAD)
STAGE_TAG := "rg.fr-par.scw.cloud/k8s-ai-registry-stage/ai-training-database:$(COMMIT_HASH)-$(TIMESTAMP)"
PROD_TAG := "rg.fr-par.scw.cloud/k8s-ai-registry/ai-training-database:$(COMMIT_HASH)-$(TIMESTAMP)"

build_and_push_stage_image_using_depot:
	dotenvx run -f .env.depot -- depot build --push -f k8s/stage/Dockerfile --platform linux/amd64 --progress=plain --build-arg UV_INDEX_INTERNAL_PYPI_USERNAME  --build-arg UV_INDEX_INTERNAL_PYPI_PASSWORD -t "rg.fr-par.scw.cloud/k8s-ai-registry-stage/ai-training-database:latest" -t $(STAGE_TAG) .

build_and_push_production_image_using_depot:
	dotenvx run -f .env.depot -- depot build --push -f k8s/prod/Dockerfile --platform linux/amd64 --progress=plain --build-arg UV_INDEX_INTERNAL_PYPI_USERNAME  --build-arg UV_INDEX_INTERNAL_PYPI_PASSWORD -t "rg.fr-par.scw.cloud/k8s-ai-registry/ai-training-database:latest" -t "rg.fr-par.scw.cloud/k8s-ai-registry/ai-training-database:$(COMMIT_HASH)-$(TIMESTAMP)" .

update_image_tag_for_deployment:
	@echo "Updating image tag to $(IMAGE_TAG) in $(FILE_PATH)" && \
	yq e -i '( select(.kind == "Deployment") | .spec.template.spec.containers[0].image ) = env(IMAGE_TAG)' $(FILE_PATH)

commit_apply_rollout_stage:
	make update_image_tag_for_deployment IMAGE_TAG=${uri} FILE_PATH=k8s/stage/stage_document_manager_database_deployment.yaml
	@git add k8s/stage/stage_document_manager_database_deployment.yaml
	@git commit --allow-empty -m "apply-rollout(stage): $(uri)"
	@git push

commit_order_stage_deploy:
	@git commit --allow-empty -m "deploy(stage): $(uri)"
	@git push

# To make a commit for CI to build image
commit_build:
	./bump_version.sh --push

# To make a commit for CI to build image then deploy it
commit_build_deploy:
	./bump_version.sh --push --deploy

extract_tag_from_build_logs:
	@sed -n 's/.*pushing manifest for \([^@]*\).*/\1/p' | awk 'length > max_length { max_length = length; longest = $$0 } END { print longest }'