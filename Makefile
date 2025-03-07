.PHONY: docs typestubs pre watch dist settings-schema clean

clean:
	echo clean
	rm -rf docs/_build/
	rm -rf docs/api/napari*.rst
	rm -rf docs/gallery/*
	rm -rf docs/_tags

docs-install:
	pip install -qr docs/requirements.txt

docs-build:
	python docs/_scripts/prep_docs.py
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 sphinx-build -b html docs/ docs/_build

docs: clean docs-install docs-build

html: clean docs-build

html-noplot: clean
	python -qr docs/_scripts/prep_docs.py
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 sphinx-build -D plot_gallery=0 -b html docs/ docs/_build

typestubs:
	python -m napari.utils.stubgen

# note: much faster to run mypy as daemon,
# dmypy run -- ...
# https://mypy.readthedocs.io/en/stable/mypy_daemon.html
typecheck:
	mypy napari/settings napari/types.py napari/plugins

check-manifest:
	pip install -U check-manifest
	check-manifest

dist: typestubs check-manifest
	pip install -U build
	python -m build

settings-schema:
	python -m napari.settings._napari_settings

pre:
	pre-commit run -a

# If the first argument is "watch"...
ifeq (watch,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "watch"
  WATCH_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(WATCH_ARGS):;@:)
endif

# examples:
# make watch ~/Desktop/Untitled.png
# make watch -- -w animation  # -- is required for passing flags to napari

watch:
	@echo "running: napari $(WATCH_ARGS)"
	@echo "Save any file to restart napari\nCtrl-C to stop..\n" && \
		watchmedo auto-restart -R \
			--ignore-patterns="*.pyc*" -D \
			--signal SIGKILL \
			napari -- $(WATCH_ARGS) || \
		echo "please run 'pip install watchdog[watchmedo]'"

linkcheck-files:
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 sphinx-build -b linkcheck -D plot_gallery=0 --color docs/ docs/_build