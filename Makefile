NAME = quay.io/baselibrary/postgres
REPO = git@github.com:baselibrary/docker-postgres.git
TAGS = 9.0 9.1 9.2 9.3 9.4

all: build

build: $(TAGS)

release: $(TAGS)
	docker push ${NAME}

sync-branches:
	git fetch $(REPO) master
	@$(foreach tag, $(TAGS), git branch -f $(tag) FETCH_HEAD;)
	@$(foreach tag, $(TAGS), git push $(REPO) $(tag);)
	@$(foreach tag, $(TAGS), git branch -D $(tag);)

.PHONY: $(TAGS)
$(TAGS):
	docker build -t $(NAME):$@ $@
