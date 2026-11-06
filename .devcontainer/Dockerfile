FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# ---- LaTeX (toolchain d'origine du CV) + Python (scripts des skills) ----
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		latexmk \
		texlive-latex-base \
		texlive-latex-recommended \
		texlive-latex-extra \
		texlive-fonts-recommended \
		texlive-fonts-extra \
		texlive-lang-english \
		python3 \
		python3-pip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* /usr/share/locale/*

# ---- Node.js LTS 22 (build du site, Phase 1) ----
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
	&& apt-get install -y --no-install-recommends nodejs \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# ---- Neovim (dernière release stable au moment du build) ----
RUN curl -fsSL -o /tmp/nvim.tar.gz \
		https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz \
	&& mkdir -p /opt \
	&& tar -C /opt -xzf /tmp/nvim.tar.gz \
	&& ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
	&& rm /tmp/nvim.tar.gz

# ---- lazygit (dernière version au moment du build) ----
RUN TAG=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
		| grep -m1 '"tag_name"' | sed -E 's/.*"v([^"]*)".*/\1/') \
	&& curl -fsSL -o /tmp/lazygit.tgz \
		"https://github.com/jesseduffield/lazygit/releases/download/v${TAG}/lazygit_${TAG}_Linux_x86_64.tar.gz" \
	&& tar -C /usr/local/bin -xzf /tmp/lazygit.tgz lazygit \
	&& rm /tmp/lazygit.tgz

# ---- OpenCode (via npm officielle, même canal que l'hôte) ----
RUN npm install -g opencode-ai@latest

WORKDIR /work
