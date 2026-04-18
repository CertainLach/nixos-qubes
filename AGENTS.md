This is a re-packaging of Qubes Dom0/DomU packages for NixOS

Use `jj` (jujutsu vcs) for commits, and make sure to include prompt/feedback/requirements in such commit messages.
Only use `nix` (nix flakes) command to call to nix, avoid legacy commands such as `nix-build`/`nix-shell`/`nix-instantiate`
If Nix can't find some file ("Path ... in the repository ... is not tracked by Git"), use `jj status` to sync the worktree with jj-colocated git repo.

When moving package outputs around (usr/lib/ => lib/ etc) follow same defensive patterns used everywhere, no file
should be skipped from packaging for no reason.

When updating patches:
Clone the original repo, apply existing patches using `git am -3 --no-gpg-sign`, fixing failures in the process, and then regenerate patches using `git format-patch`.
Do not try to edit patch files manually, this process is too fragile and error-prone.

For commits use NixOS commit convention:
For updates: PACKAGE: vOLD -> vNEW
For other changes (e.g patch updates): PACKAGE: CHANGE
For NixOS module changes: nixos/MODULE: CHANGE
For non-package changes (flake, overlay, CI): build: CHANGE

Do not merge changes to multiple packages in the same commit, you can use `jj split` to do that.

But suffix your commit messages with (slop) so LLM-generated commits can be identified in jj log, also never forget
Co-Authored-With: trailer with your model name.
