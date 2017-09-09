XCODEBUILD := xcodebuild
WORKSPACE = Tinylog.xcworkspace
BUILD_FLAGS = -workspace $(WORKSPACE) -scheme $(SCHEME) -destination $(DESTINATION)
SCHEME ?= $(TARGET)
TARGET ?= Tinylog
PLATFORM ?= iOS
OS ?= 10.3
RELEASE ?= release
BRANCH ?= master
DIST_BRANCH = $(RELEASE)-dist

ifeq ($(PLATFORM), iOS)
	DESTINATION ?= 'platform=iOS Simulator,name=iPhone 7,OS=10.3.1'
endif

XCPRETTY :=
ifneq ($(shell type -p xcpretty),)
	XCPRETTY += | xcpretty -c && exit $${PIPESTATUS[0]}
endif

build: dependencies
	$(XCODEBUILD) $(BUILD_FLAGS) $(XCPRETTY)

test:
	$(XCODEBUILD) test $(BUILD_FLAGS) $(XCPRETTY)

clean:
	$(XCODEBUILD) clean $(BUILD_FLAGS) $(XCPRETTY)

bootstrap: dependencies
	brew update || brew update
	brew unlink swiftlint || true
	brew install swiftlint
	brew link --overwrite swiftlint

lint:
		swiftlint lint --reporter json --strict

secrets:
		mkdir -p Tinylog/Configs \
		&& cp -n Configs/Secrets.swift.example Tinylog/Configs/Secrets.swift \
		|| true; \

deploy:
	@echo "Deploying $(BRANCH) to $(RELEASE)"

	@if test -n "`git rev-list $(BRANCH)..$(RELEASE)`"; \
	then \
		echo "There are commits in $(BRANCH) that are not in $(RELEASE). Please sync the remotes before deploying."; \
		exit 1; \
	fi
	@if test "$(RELEASE)" != "release" && test "$(RELEASE)" != "itunes"; \
	then \
		echo "RELEASE must be 'release' or 'itunes'."; \
		exit 1; \
	fi
	@if test "$(RELEASE)" = "itunes" && test "$(BRANCH)" != "master"; \
	then \
		echo "BRANCH must be 'master' for iTunes releases."; \
		exit 1; \
	fi

	@git branch -f $(DIST_BRANCH) $(BRANCH)
	@git push -f $(DIST_BRANCH)
	@git branch -d $(DIST_BRANCH)

	@echo "Deploy completed!"

.PHONY: test clean dependencies lint deploy
