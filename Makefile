INSTALL_DIR = ./install

SONGS_DIR = ./data/raw/songs
ARTWORK_DIR = ./data/raw/artwork
METADATA_DIR = ./data/processed/01__metadata
ENCODE_DIR = ./data/processed/02__encode

METADATA_FILE = ./data/raw/metadata.tsv
SONG_FILES = $(wildcard $(SONGS_DIR)/*)
METADATA_FILES = $(addsuffix .txt, $(addprefix $(METADATA_DIR)/, $(basename $(notdir $(SONG_FILES)))))
ENCODE_FILES = $(addsuffix .flac, $(addprefix $(ENCODE_DIR)/, $(basename $(notdir $(SONG_FILES)))))

.PHONY: install all encode metadata clean

# **** Step 01 - Metadata Generation ****

metadata: $(METADATA_FILES)

$(METADATA_FILES): $(METADATA_FILE) ./src/01__metadata.sh
	@./src/01__metadata.sh \
		-i $(METADATA_FILE) \
		-o $(METADATA_DIR)

# **** Step 02 - Encode ****

encode: $(ENCODE_FILES)

$(ENCODE_FILES): $(ENCODE_DIR)/%.flac: $(SONGS_DIR)/% $(METADATA_FILES) ./src/02__encode.sh
	@./src/02__encode.sh \
		-i $< \
		-m $(addsuffix .txt, $(addprefix $(METADATA_DIR)/, $(basename $(notdir $<)))) \
		-a $(ARTWORK_DIR) \
		-o $@

# **** Step 03 - Install ****

install:
	@./src/install.sh \
		-r $(ENCODE_DIR) \
		-m $(METADATA_DIR) \
		-i "$(INSTALL_DIR)"

all: metadata encode

clean:
	rm -rf $(ENCODE_DIR)
	rm -rf $(METADATA_DIR)
	mkdir $(ENCODE_DIR)
	mkdir $(METADATA_DIR)
