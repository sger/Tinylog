XCODEBUILD := xcodebuild
WORKSPACE = Tinylog.xcworkspace
BUILD_FLAGS = -workspace $(WORKSPACE) -scheme $(SCHEME) -destination $(DESTINATION)
SCHEME ?= $(TARGET)
TARGET ?= Tinylog
PLATFORM ?= iOS
OS ?= 12.0
RELEASE ?= release
BRANCH ?= develop
MASTER_BRANCH = $(RELEASE)-dist

ifeq ($(PLATFORM), iOS)
	DESTINATION ?= 'platform=iOS Simulator,name=iPhone X,OS=12.2'
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
	brew update
	brew unlink swiftlint || true
	brew install swiftlint
	brew link --overwrite swiftlint

dependencies: cocoapods

cocoapods:
	pod repo update
	pod install

lint:
	swiftlint lint --reporter json --strict

secrets:
	mkdir -p Tinylog/Configs \
	&& cp -n Configs/Secrets.swift.example Tinylog/Configs/Secrets.swift \
	|| true; \

deploy:
	@echo "Deploying $(BRANCH) to $(RELEASE) branch"

	@git fetch origin develop

	@if test "$(RELEASE)" != "release"; \
	then \
		echo "RELEASE branch must be 'release'."; \
		exit 1; \
	fi
	@if test "$(RELEASE)" = "release" && test "$(BRANCH)" != "develop"; \
	then \
		echo "BRANCH must be 'develop' for TestFlight releases."; \
		exit 1; \
	fi

	@git branch -f $(MASTER_BRANCH) $(BRANCH)
	@git push -f origin $(MASTER_BRANCH)
	@git branch -d $(MASTER_BRANCH)

	@echo "Deploy has been sent to Travis CI!"

.PHONY: test clean dependencies lint deploy cocoapods
