XCODEBUILD := xcodebuild
WORKSPACE = Tinylog.xcworkspace
BUILD_FLAGS = -workspace $(WORKSPACE) -scheme $(SCHEME) -destination $(DESTINATION)
SCHEME ?= $(TARGET)
TARGET ?= Tinylog
PLATFORM ?= iOS
OS ?= 12.0
RELEASE ?= release
BRANCH ?= master
DIST_BRANCH = $(RELEASE)-dist

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
	brew update || brew update
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

.PHONY: test clean dependencies lint deploy cocoapods
