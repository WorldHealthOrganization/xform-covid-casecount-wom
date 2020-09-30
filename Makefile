###############################################################################
# run-workflow
###############################################################################
.PHONY: run-workflow
run-workflow:
	make run-xform && make run-validate-csv && make run-git-push


###############################################################################
# run-xform
###############################################################################
.PHONY: run-xform
run-xform:
	make -C .github/actions/run-xform dc-up


.PHONY: run-xform-build
run-xform-build:
	make -C .github/actions/run-xform dc-up-build


.PHONY: run-xform-build-no-cache
run-xform-build-no-cache:
	make -C .github/actions/run-xform dc-build-no-cache


###############################################################################
# validate-csv
###############################################################################
.PHONY: run-validate-csv
run-validate-csv:
	make -C .github/actions/validate-csv dc-up


.PHONY: run-validate-csv-build
run-validate-csv-build:
	make -C .github/actions/validate-csv dc-up-build


.PHONY: run-validate-csv-build-no-cache
run-validate-csv-build-no-cache:
	make -C .github/actions/validate-csv dc-build-no-cache


###############################################################################
# git-push
###############################################################################
.PHONY: run-git-push
run-git-push:
	make -C .github/actions/git-push dc-up


.PHONY: run-git-push-build
run-git-push-build:
	make -C .github/actions/git-push dc-up-build


.PHONY: run-git-push-build-no-cache
run-git-push-build-no-cache:
	make -C .github/actions/git-push dc-build-no-cache

