# ---- Project Settings --------------------------------------------------------

B2_BUCKET    =
PROJECT_NAME =

INSTALL_DIR =

B2_TRACKS  = $(B2_BUCKET)/$(PROJECT_NAME)/tracks
B2_ARTWORK = $(B2_BUCKET)/$(PROJECT_NAME)/artwork

# ---- Makefile Settings -------------------------------------------------------

TRACK_LIST := $(notdir $(shell b2 ls $(B2_TRACKS)))
FLAC_FILES := $(addprefix out/flac/, $(addsuffix .flac, $(TRACK_LIST)))

GREEN = \e[32m
CYAN  = \e[36m
END   = \e[0m

.PHONY: all install
.PRECIOUS: out/flac/%.flac

# ---- Pipeline ----------------------------------------------------------------

all: $(FLAC_FILES)

install:
	@mamba run -n Instrumental_Music_Collection python src/install.py \
		-td out/flac \
		-m  data/metadata.csv \
		-d  $(INSTALL_DIR)

data/tracks/%.track:
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Download" "$(notdir $@)"
	@b2 file download --no-progress \
		$(B2_BUCKET)/$(PROJECT_NAME)/tracks/$(basename $(notdir $@)) \
		$@ > /dev/null
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Download" "$(notdir $@)"

data/artwork:
	@printf "%b\n" "$(CYAN)[ > ]$(END) Download Artwork"
	@mkdir -p $@
	@b2 sync --no-progress \
		$(B2_ARTWORK) \
		$@ > /dev/null
	@printf "%b\n" "$(GREEN)[ ✓ ]$(END) Download Artwork"

out/flac/%.flac: data/tracks/%.track data/metadata.csv | data/artwork
	@printf "%b %s\n" "$(CYAN)[ > ]$(END) Encode" "$(notdir $@)"
	@mamba run -n Instrumental_Music_Collection python src/encode.py \
		-t  $< \
		-id $(basename $(notdir $@)) \
		-m  data/metadata.csv \
		-a  data/artwork \
		-o  $@
	@printf "%b %s\n" "$(GREEN)[ ✓ ]$(END) Encode" "$(notdir $@)"
